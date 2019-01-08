//
//  DrawImageView.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 03.08.16.
//
//

#import "DrawImageView.h"

#import "DrawImageCanvasView.h"
#import "DrawImageMenuView.h"
#import "DrawImageShareOverlayView.h"
#import "DrawImageSaveOverlayView.h"
#import "DrawImageConfig.h"
#import "Masonry.h"
#import "PasteboardManager.h"
#import "ImagesLoadingAndSavingManager.h"
#import "HProgressHUD.h"
#import "AWSS3.h"
#import "GifConverter.h"
#import "UIImage+Resize.h"

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

// TODO: Generate AWSS3 class on twice used
NSString *const kS3BucketName = @"hyperkeydrawgifs";
NSString *const kS3EndPointName = @"https://s3-us-west-2.amazonaws.com";

NSString *const kDrawImageFileFormat = @"temp_frame_%ld.gif";
NSString *const kDrawImageFileOutput = @"draw_image.gif";
NSString *const kDrawImageVideoOutput = @"draw_image_video.mp4";
NSTimeInterval const kDrawImageAnimationFramesInterval = 0.07;
NSTimeInterval const kDrawImageAnimationImagesInterval = kDrawImageAnimationFramesInterval * 2;
NSTimeInterval const kDrawImageAnimationRepeatInterval = kDrawImageAnimationFramesInterval * 5;
NSUInteger const kDrawImageMaxFramesCount = 99;

@interface DrawImageView () <DrawImageMenuViewDelegate, DrawImageCanvasViewDelegate, DrawImageShareOverlayViewDelegate, DrawImageSaveOverlayViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *menuContentView;
@property (weak, nonatomic) IBOutlet DrawImageCanvasView *canvasView;
@property (weak, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet HProgressHUD *progressView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *canvasRatioConstraint;

@property (strong, nonatomic) DrawImageMenuView *menuView;
@property (strong, nonatomic) DrawImageShareOverlayView *shareOverlayView;
@property (strong, nonatomic) DrawImageSaveOverlayView *saveOverlayView;
@property (strong, nonatomic) NSTimer *showMenuTimer;
@property (strong, nonatomic) NSTimer *animationTimer;
@property (strong, nonatomic) NSTimer *framesTimer;

@property (weak, nonatomic) AWSS3TransferManagerUploadRequest *uploadRequest;

@property (strong, nonatomic) NSMutableArray *imageFrameIndexes;
@property (assign, nonatomic) NSUInteger currentFrameIndex;
@property (assign, nonatomic) NSUInteger animateFrameIndex;
@property (assign, nonatomic) BOOL isAnimating;
@property (assign, nonatomic) BOOL isBackgroundImage;

@end

@implementation DrawImageView

- (void)dealloc {
    if (self.uploadRequest) {
        [self.uploadRequest cancel];
    }
    
    [self removeShowMenuTimer];
    [self removeAnimationTimer];
    [self removeFramesTimer];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [AWSLogger defaultLogger].logLevel = AWSLogLevelError;
    
    self.menuView = [[[NSBundle bundleForClass:DrawImageMenuView.class] loadNibNamed:NSStringFromClass([DrawImageMenuView class]) owner:self options:nil] firstObject];
    self.menuView.delegate = self;
    [self.menuContentView addSubview:self.menuView];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.progressView.sizeType = HProgressHUDSizeTypeSmallWhite;
    self.imageFrameIndexes = [[NSMutableArray alloc] init];
    self.canvasView.delegate = self;
    self.cancelButton.hidden = YES;
    self.isBackgroundImage = NO;
    
    [self removeAllImages];
}


#pragma mark - Property

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage) {
        self.cancelButton.hidden = NO;
        self.isBackgroundImage = YES;
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize aspectFillSize = self.canvasView.aspectFillSize;
        self.canvasView.image = [backgroundImage resizedImageToFitInSize:aspectFillSize resizeUp:YES scale:scale];
        [self saveImage:self.canvasView.image toFileWithIndex:0];
        
        CGSize imageSize = self.canvasView.image.size;
        CGFloat multiplied = imageSize.width / imageSize.height;
        [self.canvasView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.canvasView.mas_height).multipliedBy(multiplied).with.priority(999);
        }];
    } else {
        self.cancelButton.hidden = YES;
        self.isBackgroundImage = NO;
    }
}

- (UIImage *)backgroundImage {
    return [self imageFromFileWithIndex:0];
}


#pragma mark - Public

- (void)hideShareOverlayView {
    if (self.shareOverlayView) {
        [self.shareOverlayView stopAnimatingWithCompetion:^{
            [self.shareOverlayView removeFromSuperview];
            self.shareOverlayView = nil;
        }];
    }
}


#pragma mark - Actions

- (IBAction)actionCancel {
    if ([self.delegate respondsToSelector:@selector(drawImageViewDidCancel)]) {
        [self.delegate drawImageViewDidCancel];
    }
}


#pragma mark - Private

- (void)showShareOverlayView {
    if (!self.shareOverlayView) {
        self.shareOverlayView = [[[NSBundle bundleForClass:DrawImageShareOverlayView.class] loadNibNamed:NSStringFromClass([DrawImageShareOverlayView class]) owner:self options:nil] firstObject];
        self.shareOverlayView.alpha = 0;
        self.shareOverlayView.delegate = self;
        [self addSubview:self.shareOverlayView];
        [self.shareOverlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    
    if (self.shareOverlayView.alpha < 1) {
        [self.shareOverlayView startAnimatingWithCompetion:nil];
    }
}

- (void)showSaveOvelayView {
    if (!self.saveOverlayView) {
        self.saveOverlayView = [[[NSBundle bundleForClass:DrawImageSaveOverlayView.class] loadNibNamed:NSStringFromClass([DrawImageSaveOverlayView class]) owner:self options:nil] firstObject];
        self.saveOverlayView.alpha = 0;
        self.saveOverlayView.delegate = self;
        [self addSubview:self.saveOverlayView];
        [self.saveOverlayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    
    if (self.saveOverlayView.alpha < 1) {
        [self.saveOverlayView startAnimatingWithCompetion:nil];
    }
}

- (void)hideSaveOverlayView {
    if (self.saveOverlayView) {
        [self.saveOverlayView stopAnimatingWithCompetion:^{
            [self.saveOverlayView removeFromSuperview];
            self.saveOverlayView = nil;
        }];
    }
}

- (void)showProgressView {
    [self bringSubviewToFront:self.progressBackgroundView];
    self.progressBackgroundView.alpha = 1;
    [self.progressView showAnimated:YES];
}

- (void)hideProgressView {
    self.progressBackgroundView.alpha = 0;
    [self.progressView hideAnimated:NO];
}

- (void)showMenu {
    [self removeShowMenuTimer];
    
    if (self.menuContentView.alpha < 1) {
        self.menuBottomConstraint.constant = 0;
        
        [UIView animateWithDuration:kDrawImageShowHideMenuAnimationDuration animations:^{
            self.menuContentView.alpha = 1;
            [self layoutIfNeeded];
        }];
    }
}

- (void)hideMenu {
    [self removeShowMenuTimer];
    
    if (self.menuContentView.alpha > 0) {
        self.menuBottomConstraint.constant = -self.menuContentView.frame.size.height;
        
        [UIView animateWithDuration:kDrawImageShowHideMenuAnimationDuration animations:^{
            self.menuContentView.alpha = 0;
            [self layoutIfNeeded];
        }];
    }
}


#pragma mark - Private Storage Images

- (void)captureDrawImageFrame {
    if (self.canvasView.image) {
        self.currentFrameIndex ++;
        [self saveImage:self.canvasView.image toFileWithIndex:self.currentFrameIndex];
    }
}

- (void)saveImage:(UIImage *)image toFileWithIndex:(NSUInteger)index {
    NSString *fileName = [NSString stringWithFormat:kDrawImageFileFormat, (unsigned long)index];
    NSString *filePath = [ImagesLoadingAndSavingManager pathToFileName:fileName forServiceType:ServiceTypeImageDrawing];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], kUTTypeJPEG, 1, NULL);
        CGImageDestinationAddImage(destination, image.CGImage, nil);
        if (!CGImageDestinationFinalize(destination)) {
            NSLog(@"Erorr: failed to finalize image destination");
        }
        CFRelease(destination);
    });
}

- (UIImage *)imageFromFileWithIndex:(NSUInteger )index {
    NSString *fileName = [NSString stringWithFormat:kDrawImageFileFormat, (unsigned long)index];
    NSData *data = [ImagesLoadingAndSavingManager dataByFilePath:fileName serviceType:ServiceTypeImageDrawing];
    return [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
}

- (void)removeAllImages {
    [ImagesLoadingAndSavingManager clearCacheForServiceType:ServiceTypeImageDrawing];
    
    [self.imageFrameIndexes removeAllObjects];
    self.currentFrameIndex = 0;
}

- (void)removeImageFileWithIndex:(NSUInteger)index {
    if (self.currentFrameIndex > 0) {
        NSString *fileName = [NSString stringWithFormat:kDrawImageFileFormat, (unsigned long)index];
        [ImagesLoadingAndSavingManager removeDataByFilePath:fileName serviceType:ServiceTypeImageDrawing];
        
        self.currentFrameIndex --;
    }
}

- (void)animateNextFrame {
    if (self.isAnimating && self.currentFrameIndex > 0) {
        NSTimeInterval animationInterval = kDrawImageAnimationFramesInterval;
        
        self.animateFrameIndex ++;
        NSUInteger lastIndex = MIN(self.currentFrameIndex, kDrawImageMaxFramesCount);
        if (self.animateFrameIndex > lastIndex) {
            return;
        } else if (self.animateFrameIndex == lastIndex) {
            self.canvasView.image = [self imageFromFileWithIndex:self.currentFrameIndex];
            
            if (self.menuContentView.alpha == 0) {
                [self showMenu];
            }
        } else {
            self.canvasView.image = [self imageFromFileWithIndex:self.animateFrameIndex];
            
            if ([self.imageFrameIndexes containsObject:@(self.animateFrameIndex)]) {
                animationInterval = kDrawImageAnimationImagesInterval;
            }
            [self createAnimationTimerWithInterval:animationInterval];
        }
    }
}

- (void)startPlayAnimation {
    [self stopPlayAnimation];
    
    if (self.currentFrameIndex > 1) {
        self.animateFrameIndex = 0;
        self.isAnimating = YES;
        
        [self animateNextFrame];
    }
}

- (void)stopPlayAnimation {
    if (self.isAnimating) {
        self.isAnimating = NO;
        
        [self.canvasView clear];
        if (self.currentFrameIndex > 0) {
            self.canvasView.image = [self imageFromFileWithIndex:self.currentFrameIndex];
        }
    }
}


#pragma mark - Private Timer Menu

- (void)createShowMenuTimer {
    [self removeShowMenuTimer];
    
    self.showMenuTimer = [NSTimer scheduledTimerWithTimeInterval:kDrawImageShowMenuAnimationDelay target:self selector:@selector(actionShowMenuTimer) userInfo:nil repeats:NO];
}

- (void)removeShowMenuTimer {
    if (self.showMenuTimer) {
        [self.showMenuTimer invalidate];
        self.showMenuTimer = nil;
    }
}

- (void)actionShowMenuTimer {
    [self showMenu];
}


#pragma mark - Private Timer Animation

- (void)createAnimationTimerWithInterval:(NSTimeInterval)interval {
    [self removeAnimationTimer];
    
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(actionAnimationTimer) userInfo:nil repeats:NO];
}

- (void)removeAnimationTimer {
    if (self.animationTimer) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
}

- (void)actionAnimationTimer {
    [self animateNextFrame];
}


#pragma mark - Private Timer Frames

- (void)createFramesTimer {
    [self removeFramesTimer];
    
    if (self.currentFrameIndex < kDrawImageMaxFramesCount) {
        self.framesTimer = [NSTimer scheduledTimerWithTimeInterval:kDrawImageAnimationFramesInterval target:self selector:@selector(actionFramesTimer) userInfo:nil repeats:YES];
    }
}

- (void)removeFramesTimer {
    if (self.framesTimer) {
        [self.framesTimer invalidate];
        self.framesTimer = nil;
    }
}

- (void)actionFramesTimer {
    if (self.currentFrameIndex < kDrawImageMaxFramesCount) {
        [self captureDrawImageFrame];
    } else {
        [self removeFramesTimer];
    }
}


#pragma mark - DrawImageMenuViewDelegate

- (void)drawImageMenuDidUndoAction {
    [self stopPlayAnimation];
    
    if (self.currentFrameIndex > 0) {
        NSUInteger previousImageIndex = 0;
        if (self.imageFrameIndexes.count > 0) {
            previousImageIndex = [[self.imageFrameIndexes lastObject] integerValue];
            [self.imageFrameIndexes removeLastObject];
        }
        
        for (NSUInteger i = self.currentFrameIndex; i > previousImageIndex; i --) {
            [self removeImageFileWithIndex:self.currentFrameIndex];
        }
        self.currentFrameIndex = previousImageIndex;
        
        if (self.currentFrameIndex > 0) {
            self.canvasView.image = [self imageFromFileWithIndex:self.currentFrameIndex];
        } else {
            [self.canvasView clear];
        }
    } else if (self.isBackgroundImage) {
        self.canvasView.image = [self imageFromFileWithIndex:0];
    }
}

- (void)drawImageMenuDidPlayAction {
    [self hideMenu];
    [self startPlayAnimation];
}

- (void)drawImageMenuDidSaveGifAction {
    if (self.currentFrameIndex > 1) {
        [self stopPlayAnimation];
        
        [self showProgressView];
        
        NSString *filePath = [ImagesLoadingAndSavingManager pathToFileName:kDrawImageFileOutput forServiceType:ServiceTypeImageDrawing];
        NSUInteger lastIndex = MIN(self.currentFrameIndex, kDrawImageMaxFramesCount);
        
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            NSDictionary *gifProperties = @{(__bridge id)kCGImagePropertyGIFLoopCount: @(0),
                                            (__bridge id)kCGImagePropertyGIFHasGlobalColorMap: @(NO)};
            NSDictionary *fileProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: gifProperties};
            
            CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], kUTTypeGIF, lastIndex, nil);
            CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
            
            CGRect drawRect = CGRectMake(0, 0, self.canvasView.image.size.width, self.canvasView.image.size.height);
            
            NSUInteger animatedIndex = self.isBackgroundImage ? 0 : 1;
            for (; animatedIndex <= lastIndex; animatedIndex ++) {
                @autoreleasepool {
                    NSTimeInterval animationInterval = kDrawImageAnimationFramesInterval;
                    if (animatedIndex == lastIndex) {
                        animatedIndex = self.currentFrameIndex;
                        animationInterval = kDrawImageAnimationRepeatInterval;
                    } else if ([self.imageFrameIndexes containsObject:@(animatedIndex)]) {
                        animationInterval = kDrawImageAnimationImagesInterval;
                    }
                    
                    NSDictionary *frameProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: @{(__bridge id)kCGImagePropertyGIFDelayTime: @(animationInterval)}};
                    
                    UIImage *image = [strongSelf imageFromFileWithIndex:animatedIndex];
                    
                    UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, 1.0f);
                    [image drawInRect:drawRect];
                    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    CGImageDestinationAddImage(destination, newImage.CGImage, (__bridge CFDictionaryRef)frameProperties);
                }
            }
            
            if (!CGImageDestinationFinalize(destination)) {
                NSLog(@"Error: failed to finalize image destination");
            }
            
            CFRelease(destination);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
                [PasteboardManager setGIF:data];
                
                [strongSelf hideProgressView];
                [strongSelf showShareOverlayView];
                

                if ([strongSelf.delegate respondsToSelector:@selector(drawImageViewDidShareGif)]) {
                    [strongSelf.delegate drawImageViewDidShareGif];
                }
            });
        });
    }
}


#pragma mark - Private Photo Album

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self hideProgressView];
    [self hideShareOverlayView];
    [self showSaveOvelayView];
    
    if ([self.delegate respondsToSelector:@selector(drawImageViewDidShareWhatsApp)]) {
        [self.delegate drawImageViewDidShareWhatsApp];
    }
}


#pragma mark - DrawImageCanvasViewDelegate

- (void)drawImageCanvasViewDidTapField {
    if (self.menuContentView.alpha > 0) {
        [self hideMenu];
    } else {
        [self showMenu];
    }
}

- (void)drawImageCanvasViewDidStartDraw {
    [self stopPlayAnimation];
    [self hideMenu];
    [self createFramesTimer];
    
    if (self.currentFrameIndex > 0) {
        [self.imageFrameIndexes addObject:@(self.currentFrameIndex)];
    }
    
    [self captureDrawImageFrame];
}

- (void)drawImageCanvasViewDidFinishDraw {
    [self removeFramesTimer];
    [self createShowMenuTimer];
    
    [self captureDrawImageFrame];
}


#pragma mark - DrawImageMenuViewDelegate

- (void)drawImageMenuDidSelectColor:(UIColor *)color {
    self.canvasView.color = color;
}


#pragma mark - DrawImageShareOverlayViewDelegate

- (void)drawImageShareOverlayViewDidTap {
    [self hideShareOverlayView];
}

- (void)drawImageShareOverlayViewDidLinkAction {
    NSString *filePath = [ImagesLoadingAndSavingManager pathToFileName:kDrawImageFileOutput forServiceType:ServiceTypeImageDrawing];
    if (!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self hideShareOverlayView];
        return;
    }
    
    [self showProgressView];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.gif", [NSUUID UUID].UUIDString];
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = [NSURL fileURLWithPath:filePath];
    uploadRequest.key = fileName;
    uploadRequest.bucket = kS3BucketName;
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    uploadRequest.contentType = @"image/gif";
    
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    __weak __typeof(self)weakSelf = self;
    [[transferManager upload:uploadRequest] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (task.error) {
                    NSLog(@"ERROR: %@", [task.error localizedDescription]);
                } else if (task.result) {
                    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", kS3EndPointName, kS3BucketName, fileName];
                    
                    if ([strongSelf.delegate respondsToSelector:@selector(drawImageViewDidUploadImageToURLString:)]) {
                        [strongSelf.delegate drawImageViewDidUploadImageToURLString:urlString];
                    }
                }
            
                [strongSelf hideProgressView];
                [strongSelf hideShareOverlayView];
            });
        }
        
        return nil;
    }];
    
    self.uploadRequest = uploadRequest;
}

- (void)drawImageShareOverlayViewDidWhatsAppAction {
    NSString *gifPath = [ImagesLoadingAndSavingManager pathToFileName:kDrawImageFileOutput forServiceType:ServiceTypeImageDrawing];
    if (!gifPath || ![[NSFileManager defaultManager] fileExistsAtPath:gifPath]) {
        [self hideShareOverlayView];
        return;
    }
    
    NSString *filePath = [ImagesLoadingAndSavingManager pathToFileName:kDrawImageVideoOutput forServiceType:ServiceTypeImageDrawing];
    
    [self showProgressView];
    
    __weak __typeof(self)weakSelf = self;
    [GifConverter convertGifFromPath:gifPath toVideoFilePath:filePath competion:^(BOOL success) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            if (success) {
                UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            } else {
                [strongSelf hideProgressView];
                [strongSelf hideShareOverlayView];
            }
        }
    }];
}

- (void)drawImageShareOverlayViewDidImageAction {
    if (self.currentFrameIndex > 0) {
        [self stopPlayAnimation];
        
        [PasteboardManager clearPasteboard];
        
        if (self.canvasView.image) {
            [PasteboardManager setJPEG:self.canvasView.image];
            if ([self.delegate respondsToSelector:@selector(drawImageViewDidShareImage)]) {
                [self.delegate drawImageViewDidShareImage];
            }
        }
    }
    
    [self hideShareOverlayView];
}


#pragma mark - DrawImageSaveOverlayViewDelegate

- (void)drawImageSaveOverlayViewDidTap {
    [self hideSaveOverlayView];
}

@end

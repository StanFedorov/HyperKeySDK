//
//  GifStripeViewController.m
//  Better Word
//
//  Created by Sergey Vinogradov on 11.07.17.
//  Copyright © 2017 Hyperkey. All rights reserved.
//

#import "GifStripeViewController.h"
#import "HProgressHUD.h"
#import "GifCell.h"

#import "ReachabilityManager.h"

#import "GifAPIClient.h"

#import "ImagesLoadingAndSavingManager.h"

#import "PasteboardManager.h"
#import "KeyboardConfig.h"

#define kGifItemsLimit 50
#define kGifItemPreviewMaxFileSize 500000
#define kGifItemFullMaxFileSize 2000000
#define kDefaultEmptyLabel @"Load gifs..."

@interface GifStripeViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ImagesLoadingAndSavingManagerDelegate>

@property (assign, nonatomic) KBTheme theme;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet HProgressHUD *progressView;

@property (strong, nonatomic) NSMutableArray *currentLoadingImagesUrlsArray;

@property (strong, nonatomic) GifAPIClient *gifAPIClient;
@property (strong, nonatomic) NSString *offset;


@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;
@property (strong, nonatomic) NSIndexPath *currentCopyingImageIndexPath;

@property (strong, nonatomic) NSMutableArray *itemsList;
@property (strong, nonatomic) NSString *contentString;

@property (assign, nonatomic) CGSize cellSize;

@end

@implementation GifStripeViewController

#pragma mark - Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.itemsList = [NSMutableArray array];
    
    self.currentLoadingImagesUrlsArray = [NSMutableArray array];
    
    self.fileManager = [[ImagesLoadingAndSavingManager alloc] init];
    self.fileManager.delegate = self;
    self.fileManager.serviceType = ServiceTypeGifCamera;
    [self.fileManager cancelAllAsynchronicalWithProgressObservingDownloads];
    
    self.gifAPIClient = [[GifAPIClient alloc] init];

    NSString *cellName = NSStringFromClass([GifCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    KBTheme theme = ((NSNumber *)[userDefaults objectForKey:kUserDefaultsKeyboardTheme]).integerValue;
    [self setTheme:theme];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:kKeyboardNotificationActionUpdateText object:nil];
}

// it starts from parent VC
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = floor(self.collectionView.frame.size.width / (IS_IPHONE ? 2.0 : 4.0)) - 1;
    self.cellSize = CGSizeMake(width, width/352*227);
    
    [self.collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - Public

- (void)updateContentForString:(NSString *)string {
    self.emptyLabel.text = (self.contentString && self.contentString.length) ? [NSString stringWithFormat:@"Loading gifs for %@", string] : kDefaultEmptyLabel;
    
    if (![self.contentString isEqualToString:string]) {
        self.contentString = string;
        
        self.offset = nil;
        [self.itemsList removeAllObjects];
        
        [self updateEmptyView];
        [self.collectionView reloadData];
        
        [self loadItemsWithSearch:string];
        
    }
}


#pragma mark - Private

- (void)updateEmptyView {
    self.emptyView.hidden = (self.itemsList.count > 0 ? YES : NO);
}

- (void)loadItemsWithSearch:(NSString *)searchString {
    if ([REA_MANAGER reachabilityStatus] == NotReachable) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [self.gifAPIClient getGifsWithSearch:searchString offset:self.offset limit:kGifItemsLimit completion:^(NSError *error, NSArray *gifs, NSString *offset) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.emptyLabel.text = gifs.count ? kDefaultEmptyLabel : [NSString stringWithFormat:@"There is no gif for %@",strongSelf.contentString];
        
        if (!error && gifs.count > 0) {
            strongSelf.offset = offset;
            
            [strongSelf addDataFromArray:gifs];
            [strongSelf updateEmptyView];
        } else {
            if (strongSelf.itemsList.count == 0) {
                strongSelf.collectionView.contentOffset = CGPointZero;
                [strongSelf.collectionView reloadData];
                
                [strongSelf updateEmptyView];
            }
        }
    }];
}

- (void)addDataFromArray:(NSArray *)data {
    [self addToItemsFilteredItemsFromArray:data];
    
    [self.collectionView reloadData];
}

- (void)addToItemsFilteredItemsFromArray:(NSArray *)items {
    //randomize order
    NSMutableArray *array = [NSMutableArray arrayWithArray:items];
    int count = (int)array.count;
    for (int i = 0; i < count; ++i) {
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    for (MGif *mGif in array) {
        if ((mGif.previewFileSize > 0) && (mGif.previewFileSize < kGifItemPreviewMaxFileSize) && (mGif.fullFileSize < kGifItemFullMaxFileSize)) {
            [self.itemsList addObject:mGif];
        }
    }
}
     
- (void)textDidChangeNotification:(NSNotification *)notification {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    if (![userDefaults boolForKey:kUserDefaultsSettingAllowGifStripe]) {
        return;
    }
    
    NSDictionary *userInfo = notification.userInfo;
    NSString *text = userInfo[@"text"];
    
    if (text.length > 1) {
        __weak __typeof(self)weakSelf = self;
        [text enumerateSubstringsInRange:NSMakeRange(0, text.length) options:NSStringEnumerationReverse|NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            [weakSelf performSelectorOnMainThread:@selector(updateContentForString:) withObject:substring waitUntilDone:NO];
            
            *stop = YES;
        }];
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [collectionView.collectionViewLayout invalidateLayout];
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemsList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GifCell class]) forIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCell *cell = (GifCell *)aCell;
    MGif *mGif = self.itemsList[indexPath.item];
    cell.gifImageView.animatedImage = nil;
    __block NSString *urlString = mGif.previewURLString;
    NSData *cachedData = [self.fileManager getDataByPath:urlString andServiceType:ServiceTypeGIFs];
    
    if (cachedData) {
        FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:cachedData];
        image.frameCacheSizeMax = 1;
        cell.gifImageView.animatedImage = image;
    } else if (![self.currentLoadingImagesUrlsArray containsObject:urlString]) {
        [self.currentLoadingImagesUrlsArray addObject:urlString];
        
        __weak __typeof(self)weakSelf = self;
        [self.fileManager loadDataWithURLString:urlString completion:^(NSData *data, BOOL fromCache) {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
            image.frameCacheSizeMax = 3;
            cell.gifImageView.animatedImage = image;
            
            // !!!: currentLoadingImagesUrlsArray - check everywhere
            [weakSelf.currentLoadingImagesUrlsArray removeObject:urlString];
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    ((GifCell *)cell).gifImageView.animatedImage = nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCell *cell = (GifCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if ((indexPath.item < self.itemsList.count) && (cell.gifImageView.animatedImage)) {
        MGif *mGif = self.itemsList[indexPath.item];
        
        [PasteboardManager clearPasteboard];
        
        self.currentCopyingImageIndexPath = indexPath;
        
        NSData *data = [self.fileManager loadDataIfItNotExistsByPath:mGif.fullURLString byServiceType:ServiceTypeGifCamera andSelectedIndex:indexPath andType:ImageAsynchronicallWithProgressDownload];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(addActionAnimationToView:type:options:)]) {
            [self.delegate addActionAnimationToView:cell.gifImageView type:ActionViewTypeCopy options:(data ? ActionViewOptionsEmpty : ActionViewOptionsProgress)];
        }
        
        [PasteboardManager clearPasteboard];
        
        if (data) {
            [PasteboardManager setGIF:data];
        } else {
            [PasteboardManager setGIF:cell.gifImageView.animatedImage.data];
        }
                
        if (self.delegate ) {
            [self.delegate gifImageDidSelected];
        }
    }
}


#pragma mark - ImagesLoadingAndSavingManagerDelegate

- (void)imageAtIndexPath:(NSIndexPath *)indexPath downloadingProgressChangedTo:(float)progressValue {
    BOOL isVisible = indexPath ? [self.collectionView.indexPathsForVisibleItems containsObject:indexPath] : NO;
    if (isVisible && self.delegate && [self.delegate respondsToSelector:@selector(updateActionAnimationProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate updateActionAnimationProgress:progressValue];
        });
    }
}

- (void)imageData:(NSData *)data wasLoadedByIndexPath:(NSIndexPath *)path {
    if ((!path) || ((self.currentCopyingImageIndexPath) && ([path compare:self.currentCopyingImageIndexPath] == NSOrderedSame))) {
        BOOL isVisible = [self.collectionView.indexPathsForVisibleItems containsObject:self.currentCopyingImageIndexPath];
        
        if (isVisible && self.delegate && [self.delegate respondsToSelector:@selector(updateActionAnimationProgress:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate updateActionAnimationProgress:1];
            });
        }
        
        if (path.item < self.itemsList.count) {
            MGif *mGif = self.itemsList[path.item];
            
            [PasteboardManager clearPasteboard];
            [PasteboardManager setGIF:data];
            
            NSData *previewData = [self.fileManager getDataByPath:mGif.previewURLString andServiceType:ServiceTypeGifCamera];
           
            self.currentCopyingImageIndexPath = nil;
        }
    }
}


#pragma mark - Themes

- (void)setTheme:(KBTheme)theme {
    _theme = theme;
    BOOL needDark = (theme != KBThemeClassic);
    self.view.backgroundColor = needDark ? RGB(37, 37, 37) : RGB(226, 229, 233);
}

@end

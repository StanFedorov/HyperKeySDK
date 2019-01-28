//
//  PhotoAlbumsVC.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "PhotoAlbumsVC.h"

#import "PhotoAlbumsCell.h"
#import "Macroses.h"
#import "UIImage+Resize.h"
#import "PasteboardManager.h"
#import "Config.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "DrawImageView.h"
#import "Masonry.h"

@import Photos;

CGFloat const kPAScrollMaxSpeed = 2.5;
CGFloat const kPAScrollSpeedDownOffset = 250;

@interface PhotoAlbumsVC () <PHPhotoLibraryChangeObserver, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CHTCollectionViewDelegateWaterfallLayout, DrawImageViewDelegate, PhotoAlbumsCellDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *copiedView;
@property (weak, nonatomic) IBOutlet UIView *autorizedView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) DrawImageView *drawImageView;

@property (strong, nonatomic) PHCachingImageManager *imageManager;
@property (strong, nonatomic) PHImageRequestOptions *imageRequestOptions;
@property (strong, nonatomic) NSArray *allPhotos;
@property (strong, nonatomic) NSCache *cache;

@property (assign, nonatomic) BOOL isFlowLayout;

@end

@implementation PhotoAlbumsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.autorizedView.hidden = NO;
    self.copiedView.hidden = YES;
    self.shouldReloadInfo = NO;
    self.isFlowLayout = NO;
    self.cache = [NSCache new];
    
    [self makeCollection];
    [self loadInfoLogic];
}

- (void)makeCollection {
    self.collectionView.layer.drawsAsynchronously = YES;
    self.collectionView.layer.shouldRasterize = YES;
    self.collectionView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSString *cellName = NSStringFromClass([PhotoAlbumsCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle bundleForClass:PhotoAlbumsCell.class]] forCellWithReuseIdentifier:cellName];

    [self makeFlowLayout];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)makeWaterfallLayout {
    self.isFlowLayout = NO;
    
    CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 0, 0);
    layout.headerHeight = 0;
    layout.footerHeight = 0;
    layout.minimumColumnSpacing = 3;
    layout.minimumInteritemSpacing = 3;
    layout.columnCount = (IS_IPAD ? 3 : 2);
    
    [self.collectionView setCollectionViewLayout:layout animated:YES];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)makeFlowLayout {
    self.isFlowLayout = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(2, 0, 0, 0);
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    [self.collectionView setCollectionViewLayout:layout animated:YES];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if (self.shouldReloadInfo) {
        self.shouldReloadInfo = NO;
        [self loadInfoLogic];
    }
}

- (IBAction)allowPhotos:(id)sender {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self loadInfoLogic];
            }
            else if (status == PHAuthorizationStatusDenied) {
                [self openURL:UIApplicationOpenSettingsURLString];
            }
        }];
    }
}

- (void)openURL:(NSString*)url{
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        NSLog(@"responder = %@", responder);
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:)
                            withObject:[NSURL URLWithString:url]];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideHoverView];
    
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [PasteboardManager clearPasteboard];
    
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (PhotoAlbumsCell *cell in visibleCells) {
        if (cell.tag) {
            [self.imageManager cancelImageRequest:(PHImageRequestID)cell.tag];
        }
    }
}

- (void)dealloc {
    [self.cache removeAllObjects];
    
    NSArray *visibleCells = [self.collectionView visibleCells];
    for (PhotoAlbumsCell *cell in visibleCells) {
        if (cell.tag) {
            [self.imageManager cancelImageRequest:(PHImageRequestID)cell.tag];
        }
    }
    
    self.allPhotos = nil;
}


#pragma mark - Photos

- (void)loadInfoLogic {
    __weak __typeof(self)weakSelf = self;
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                    strongSelf.shouldReloadInfo = YES;
                    strongSelf.autorizedView.hidden = NO;
                    return;
                }else {
                    strongSelf.autorizedView.hidden = YES;
                }
                
                strongSelf.imageManager = [[PHCachingImageManager alloc] init];
                
                strongSelf.imageRequestOptions = [[PHImageRequestOptions alloc] init];
                strongSelf.imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
                strongSelf.imageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
                strongSelf.imageRequestOptions.synchronous = YES;
                strongSelf.imageRequestOptions.networkAccessAllowed = YES;
                
                [strongSelf takeAllPhotos];
                [strongSelf reloadCollection];
            }
        });
    }];
}

- (void)reloadCollection {
    [self.imageManager stopCachingImagesForAllAssets];
    
    [self.collectionView reloadData];
}

- (void)takeAllPhotos {
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    self.allPhotos = [result objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(result.count, 30))]];
    
    [self.cache setObject:result forKey:@"fetch result"];
}

- (IBAction)functionButton:(id)sender {
    [self.delegate functionButton:sender];
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:[self.cache objectForKey:@"fetch result"]];
    if (collectionChanges == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self takeAllPhotos];
        [self reloadCollection];
    });
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoAlbumsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PhotoAlbumsCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(PhotoAlbumsCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAsset *__weak asset = self.allPhotos[indexPath.item];
    cell.representedAssetIdentifier = asset.localIdentifier;
    
    [self removeActionAnimation];
    
    __weak typeof(cell) weakCell = cell;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGSize size = weakCell.imageView.frame.size;
        
        weakCell.tag = [weakSelf.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:weakSelf.imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            __weak typeof(weakCell) strongCell = weakCell;
            if (strongCell && result && [strongCell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                UIImage *image = result;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongCell setImage:image animated:NO];
                    [strongCell.indicatorView hideAnimated:NO];
                });
            }
        }];
    });
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if ([self actionAnimated]) {
        return;
    }
    
    PhotoAlbumsCell *cell = (PhotoAlbumsCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    PHAsset *__weak asset = self.allPhotos[indexPath.item];
    cell.representedAssetIdentifier = asset.localIdentifier;
    CGSize size = [UIImage getImageSizeForHighestSideLenght:kPasteboardImageLongSidePixelsValue withImageSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
    
    [PasteboardManager clearPasteboard];
    [self addActionAnimationToView:cell.imageView type:ActionViewTypeCopy];
    
    __weak __typeof(self)weakSelf = self;
    __weak __typeof(cell)weakCell = cell;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block PHImageRequestID requestID = [weakSelf.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:weakSelf.imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            __strong __typeof(weakCell)strongCell = weakCell;
            if (strongSelf && strongCell) {
                UIImage *previewImage = strongCell.imageView.image;
                UIImage *image = result != nil ? result : strongCell.imageView.image;
                
                [strongSelf.imageManager cancelImageRequest:requestID];
                
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PasteboardManager setJPEG:image];
                    });
                }
            }
        }];
    });
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(PhotoAlbumsCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag) {
        [self.imageManager cancelImageRequest:(PHImageRequestID)cell.tag];
    }
    
    cell.imageView.image = nil;
}


#pragma mark - CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isFlowLayout) {
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)collectionViewLayout;
        CGFloat size = self.collectionView.frame.size.height - layout.sectionInset.top - layout.sectionInset.bottom;
        return CGSizeMake(size, size);
    }
    
    PHAsset *asset = self.allPhotos[indexPath.item];
    return CGSizeMake(asset.pixelWidth, asset.pixelHeight);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.collectionView) {
        if (fabs(velocity.x) > kPAScrollMaxSpeed) {
            int multiply = velocity.x >= 0 ? 1 : -1;
            *targetContentOffset = CGPointMake(scrollView.contentOffset.x + multiply * kPAScrollSpeedDownOffset, targetContentOffset->y);
            [self.collectionView setContentOffset:CGPointMake(scrollView.contentOffset.x + multiply * kPAScrollSpeedDownOffset, targetContentOffset->y) animated:YES];
        } else if (fabs(velocity.y) > kPAScrollMaxSpeed) {
            int multiply = velocity.y >= 0 ? 1 : -1;
            *targetContentOffset = CGPointMake(targetContentOffset->x, scrollView.contentOffset.y + multiply * kPAScrollSpeedDownOffset);
        }
    }
}


#pragma mark - Change layout

- (IBAction)changeLayout:(id)sender {
    if (self.isFlowLayout) {
        [self makeWaterfallLayout];
    } else {
        [self makeFlowLayout];
    }
}


#pragma mark - Additional

- (void)hideCopiedView {
    self.copiedView.hidden = YES;
}


#pragma mark - PhotoAlbumsCellDelegate

- (void)photoAlbumsCellDidEdit:(PhotoAlbumsCell *)photoAlbumsCell {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:photoAlbumsCell];
    DrawImageView *drawImageView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DrawImageView class]) owner:self options:nil] firstObject];
    drawImageView.delegate = self;
    drawImageView.featureType = self.featureType;
    [self.view addSubview:drawImageView];
    [drawImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.drawImageView = drawImageView;
    
    PHAsset *__weak asset = self.allPhotos[indexPath.item];
    CGSize size = [UIImage getImageSizeForHighestSideLenght:kPasteboardImageLongSidePixelsValue withImageSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)];
    
    __weak __typeof(self)weakSelf = self;
    __weak __typeof(photoAlbumsCell)weakCell = photoAlbumsCell;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block PHImageRequestID requestID = [weakSelf.imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:weakSelf.imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            __strong __typeof(weakCell)strongCell = weakCell;
            if (strongSelf && strongCell) {
                UIImage *image = result != nil ? result : strongCell.imageView.image;
                
                [strongSelf.imageManager cancelImageRequest:requestID];
                
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [strongSelf.drawImageView setBackgroundImage:image];
                    });
                }
            }
        }];
    });
}


#pragma mark - DrawImageViewDelegate

- (void)drawImageViewDidUploadImageToURLString:(NSString *)urlString {
    if (urlString) {
        [self insertLinkWithURLString:urlString title:nil featureType:self.featureType completion:nil];
    }
}

- (void)drawImageViewDidCancel {
    [self.drawImageView removeFromSuperview];
}

@end

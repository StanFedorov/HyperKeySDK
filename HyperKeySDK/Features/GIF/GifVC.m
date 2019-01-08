//
//  GifVC.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "GifVC.h"

#import "GifAPIClient.h"
#import "GifCell.h"
#import "GifCategoryCell.h"
#import "PasteboardManager.h"
#import "KeyboardConfig.h"
#import "ImagesLoadingAndSavingManager.h"
#import "FLAnimatedImage.h"
#import "HProgressHUD.h"
#import "UIScreen+Orientation.h"

#ifdef kFabricEnabled
#import <Crashlytics/Crashlytics.h>
#endif

CGFloat const kGifVCPreviewMaxFileSize = 500000;
CGFloat const kGifVCFullMaxFileSize = 2000000;
NSInteger const kGifVCLimit = 50;
CGFloat const kGifVCNextDataFactor = 0.3;
NSInteger const kGifVCScrollDeceleratingRate = 0.994;

@interface GifVC () <UICollectionViewDataSource, UICollectionViewDelegate, ImagesLoadingAndSavingManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *itemsCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *searchDetailButton;
@property (weak, nonatomic) IBOutlet UIView *searchBackgroundView;
@property (weak, nonatomic) IBOutlet HProgressHUD *progressView;

@property (strong, nonatomic) NSMutableArray *currentLoadingImagesUrlsArray;
@property (strong, nonatomic) NSOperationQueue *imagesLoadingQueue;
@property (strong, nonatomic) NSIndexPath *currentCopyingImageIndexPath;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) NSArray *categoriesArray;

@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;
@property (strong, nonatomic) GifAPIClient *gifAPIClient;

@property (assign, nonatomic) NSInteger columnsCount;
@property (assign, nonatomic) NSInteger rowsCount;
@property (assign, nonatomic) BOOL existNextData;
@property (assign, nonatomic) BOOL isLoadingData;
@property (strong, nonatomic) NSString *offset;
@property (strong, nonatomic) NSString *previousSearchString;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) NSUInteger trimDataCount;

@end

@implementation GifVC


#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateItemSide];
    
    self.rowsCount = 2;
    self.existNextData = YES;
    self.offset = nil;
    self.trimDataCount = 0;
    self.previousSearchString = nil;
    
    NSString *cellName = NSStringFromClass([GifCell class]);
    [self.itemsCollectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];
    self.itemsCollectionView.decelerationRate = kGifVCScrollDeceleratingRate;
    
    cellName = NSStringFromClass([GifCategoryCell class]);
    [self.categoriesCollectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];

    self.currentLoadingImagesUrlsArray = [[NSMutableArray alloc] init];
    self.imagesLoadingQueue = [[NSOperationQueue alloc] init];
    self.imagesLoadingQueue.maxConcurrentOperationCount = 2;
    self.imagesLoadingQueue.qualityOfService = NSQualityOfServiceBackground;
    
    self.dataArray = [[NSMutableArray alloc] init];
    
    self.categoriesArray = @[@" All ", @"Angry", @"Good Night", @"Win", @"Hello", @"OMG", @"Bye", @"Good Luck", @"Loser", @"LOL", @"Ok", @"Agree", @"Cool", @"Love You", @"Slap", @"Creep", @"Thank You", @"Ouch", @"Wow", @"Sorry", @"Dance", @"Stop", @"Facepalm", @"Crazy", @"Happy", @"Yes", @"No", @"Lazy", @"Smile", @"Kisses", @"Waiting"];
    
    self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Gifs" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    
    [self updateColumnCount];
    
    self.gifAPIClient = [[GifAPIClient alloc] init];
    
    self.fileManager = [[ImagesLoadingAndSavingManager alloc] init];
    self.fileManager.delegate = self;
    self.fileManager.serviceType = ServiceTypeGIFs;
    [self.fileManager cancelAllAsynchronicalWithProgressObservingDownloads];
    
    [self loadItemsWithSearch:@""];
    [self setSearchFieldHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.shouldReloadInfo) {
        self.shouldReloadInfo = NO;
        [self loadItemsWithSearch:@""];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionSearch) name:kKeyboardNotificationActionSearchButton object:nil];
    
    // ALL should select by default
    [self.categoriesCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    
    self.itemsCollectionView.backgroundColor = RGB(226, 229, 233);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateItemSide];
    
    [self.itemsCollectionView.collectionViewLayout invalidateLayout];
    [self.categoriesCollectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - Override Custom

- (void)keyboardDidDisappear {
    [self setSearchFieldHidden:YES];
    [self.showKeyboardButton setImage:[UIImage imageNamed:@"search_round_button"] forState:UIControlStateNormal];
}

- (void)showKeyboardButtonTap:(id)sender {
    BOOL searchShouldHidden = !self.searchField.hidden;
    
    [self setSearchFieldHidden:searchShouldHidden];
    
    if (!searchShouldHidden) {
        [self.searchField becomeFirstResponder];
    } else {
        [self.delegate hideKeyboard];
    }
    
    UIImage *image = [UIImage imageNamed:searchShouldHidden ? @"search_round_button" : kSearchFieldImageNameHide];
    [self.showKeyboardButton setImage:image forState:UIControlStateNormal];
}


#pragma mark - Actions

- (IBAction)actionIcon:(id)sender {
    [self.delegate functionButton:sender];
}

- (IBAction)actionSearch {
    [self.delegate hideKeyboard];
    [self loadItemsWithSearch:self.searchField.text];
}


#pragma mark - Private

- (void)updateItemSide {
    [self updateColumnCount];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.itemsCollectionView.collectionViewLayout;
    
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    UIEdgeInsets contentInset = self.itemsCollectionView.contentInset;
    CGFloat cellSpacing = collectionViewLayout.minimumInteritemSpacing;
    CGFloat lineSpacing = collectionViewLayout.minimumLineSpacing;
    
    CGSize size = CGSizeZero;
    size.width = ceilf((self.itemsCollectionView.bounds.size.width - sectionInset.left - sectionInset.right - cellSpacing * (self.columnsCount - 1)) / self.columnsCount);
    size.height = floorf((self.itemsCollectionView.bounds.size.height - contentInset.top - contentInset.bottom - sectionInset.top - sectionInset.bottom - lineSpacing ) / self.rowsCount);
    self.cellSize = size;
}

- (void)updateColumnCount {
    self.columnsCount = (ACInterfaceOrientationIsLandscape ? 3 : 2);
}

- (void)setSearchFieldHidden:(BOOL)hidden {
    self.searchField.hidden = hidden;
    self.searchDetailButton.hidden = hidden;
    self.searchBackgroundView.hidden = hidden;
}

- (void)loadItemsWithSearch:(NSString *)searchString {
    if ([REA_MANAGER reachabilityStatus] == 0) {
        [self setupHoverViewByType:HoverViewTypeNoInternet];
        [self.progressView hideAnimated:NO];
        self.shouldReloadInfo = YES;
        [self.currentLoadingImagesUrlsArray removeAllObjects];
        [self.imagesLoadingQueue cancelAllOperations];
        
        self.existNextData = YES;
        self.isLoadingData = NO;
        self.offset = nil;
        self.trimDataCount = 0;
        self.previousSearchString = nil;
    } else {
        if (![searchString isEqualToString:self.previousSearchString]) {
            [self.currentLoadingImagesUrlsArray removeAllObjects];
            [self.imagesLoadingQueue cancelAllOperations];
            
            self.previousSearchString = searchString;
            self.existNextData = YES;
            self.isLoadingData = NO;
            self.offset = nil;
            self.trimDataCount = 0;
            [self.dataArray removeAllObjects];
            [self.itemsCollectionView reloadData];
        }
        
        if (self.dataArray.count == 0) {
            [self.progressView showAnimated:NO];
        }
        
        self.isLoadingData = YES;
        
        __weak __typeof(self)weakSelf = self;
        [self.gifAPIClient getGifsWithSearch:searchString offset:self.offset limit:kGifVCLimit completion:^(NSError *error, NSArray *gifs, NSString *offset) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            
            if (!error && gifs.count > 0) {
                strongSelf.offset = offset;
                strongSelf.existNextData = YES;
                
                [strongSelf addDataFromArray:gifs];
                [strongSelf hideNoResultHoverView];
            } else {
                if (strongSelf.dataArray.count == 0) {
                    strongSelf.itemsCollectionView.contentOffset = CGPointZero;
                    [strongSelf.itemsCollectionView reloadData];
                    
                    [strongSelf showNoResultHoverViewAboveSubview:strongSelf.itemsCollectionView];
                }
                
                strongSelf.existNextData = NO;
                strongSelf.isLoadingData = NO;
            }
            
            [self.progressView hideAnimated:NO];
        }];
    }
}

- (void)addDataFromArray:(NSArray *)data {
    [self addToItemsFilteredItemsFromArray:data];
    
    self.trimDataCount = [self calculateTrimDataCount];
    
    [self.itemsCollectionView reloadData];
    self.isLoadingData = NO;
}

- (void)addToItemsFilteredItemsFromArray:(NSArray *)items {
    for (MGif *mGif in items) {
        if ((mGif.previewFileSize > 0) && (mGif.previewFileSize < kGifVCPreviewMaxFileSize) && (mGif.fullFileSize < kGifVCFullMaxFileSize)) {
            [self.dataArray addObject:mGif];
        }
    }
}

- (NSUInteger)calculateTrimDataCount {
    return self.dataArray.count - (self.dataArray.count % self.columnsCount);
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.itemsCollectionView == collectionView) {
        return self.trimDataCount;
    } else {
        return self.categoriesArray.count;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;

    if (collectionView == self.itemsCollectionView) {
        size = self.cellSize;
    } else {
        NSString *string = [self.categoriesArray objectAtIndex:indexPath.item];
        
        CGRect frame = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.categoriesCollectionView.frame.size.height)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}
                                            context:nil];
        size.width = frame.size.width + 29;
        size.height = collectionView.frame.size.height;
    }
    
    return size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (collectionView == self.itemsCollectionView) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GifCell class]) forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GifCategoryCell class]) forIndexPath:indexPath];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.itemsCollectionView) {
        GifCell *cell = (GifCell *)aCell;
        MGif *mGif = self.dataArray[indexPath.item];
        cell.gifImageView.animatedImage = nil;
                
        NSData *cachedData = [self.fileManager getDataByPath:mGif.previewURLString andServiceType:ServiceTypeGIFs];
        [cell updateBackgroundRandomColor:(cachedData == nil)];
        if (cachedData) {
            FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:cachedData];
            image.frameCacheSizeMax = 1;
            cell.gifImageView.animatedImage = image;
        } else if (![self.currentLoadingImagesUrlsArray containsObject:mGif.previewURLString]) {
            [self.currentLoadingImagesUrlsArray addObject:mGif.previewURLString];
            
            [self.imagesLoadingQueue addOperationWithBlock:^() {
                [self.fileManager loadDataIfItNotExistsByPath:mGif.previewURLString byServiceType:ServiceTypeGIFs andSelectedIndex:indexPath andType:ImageBlockingDownload];
            }];
        }
    } else if (collectionView == self.categoriesCollectionView) {
        GifCategoryCell *cell = (GifCategoryCell *)aCell;
        cell.titleLabel.text = [self.categoriesArray objectAtIndex:indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.itemsCollectionView) {
        ((GifCell *)cell).gifImageView.animatedImage = nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self actionAnimated]) {
        return;
    }
    
    if (collectionView == self.itemsCollectionView) {
        GifCell *cell = (GifCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
        if ((indexPath.item < self.dataArray.count) && (cell.gifImageView.animatedImage)) {
            MGif *mGif = self.dataArray[indexPath.item];
            
            [PasteboardManager clearPasteboard];
            
            self.currentCopyingImageIndexPath = indexPath;
            
            NSData *data = [self.fileManager loadDataIfItNotExistsByPath:mGif.fullURLString byServiceType:ServiceTypeGIFs andSelectedIndex:indexPath andType:ImageAsynchronicallWithProgressDownload];
            [self addActionAnimationToView:cell.gifImageView type:ActionViewTypeCopy options:(data) ? ActionViewOptionsEmpty : ActionViewOptionsProgress];
            
            if (data) {
                [PasteboardManager setGIF:data];
            } else {
                [PasteboardManager setGIF:cell.gifImageView.animatedImage.data];
            }
            
        }
    } else if (collectionView == self.categoriesCollectionView) {
        NSString *categoryText = [self.categoriesArray objectAtIndex:indexPath.item];
        
        [self loadItemsWithSearch:indexPath.item == 0 ? @"" : categoryText];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.itemsCollectionView && self.existNextData && !self.isLoadingData) {
        UICollectionViewFlowLayout *viewFlowLayout = (UICollectionViewFlowLayout *)self.itemsCollectionView.collectionViewLayout;
        
        CGFloat minimumInteritemSpacing = viewFlowLayout.minimumInteritemSpacing;
        CGSize cellSize = self.cellSize;
        CGFloat nextDataOffset = floorf(kGifVCLimit / self.rowsCount) * (cellSize.width + minimumInteritemSpacing) * kGifVCNextDataFactor;
        
        if ((scrollView.contentSize.width - (scrollView.contentOffset.x + self.itemsCollectionView.frame.size.width / 2)) < nextDataOffset) {
            [self loadItemsWithSearch:self.previousSearchString];
        }
    }
}


#pragma mark - ImagesLoadingAndSavingManagerDelegate

- (void)imageAtIndexPath:(NSIndexPath *)indexPath downloadingProgressChangedTo:(float)progressValue {
    BOOL isVisible = indexPath ? [self.itemsCollectionView.indexPathsForVisibleItems containsObject:indexPath] : NO;
    if (isVisible) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateActionAnimationProgress:progressValue];
        });
    }
}

- (void)imageData:(NSData *)data wasLoadedByIndexPath:(NSIndexPath *)path {
    if ((!path) || ((self.currentCopyingImageIndexPath) && ([path compare:self.currentCopyingImageIndexPath] == NSOrderedSame))) {
        BOOL isVisible = [self.itemsCollectionView.indexPathsForVisibleItems containsObject:self.currentCopyingImageIndexPath];
        if (isVisible) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateActionAnimationProgress:1];
            });
        }
        
        if (path.item < self.dataArray.count) {
            MGif *mGif = self.dataArray[path.item];
            
            [PasteboardManager clearPasteboard];
            [PasteboardManager setGIF:data];
            
            NSData *previewData = [self.fileManager getDataByPath:mGif.previewURLString andServiceType:ServiceTypeGIFs];
            
        }
    } else if (path) {
        BOOL isVisible = [self.itemsCollectionView.indexPathsForVisibleItems containsObject:path];
        if (isVisible) {
            GifCell *cell = (GifCell *)[self.itemsCollectionView cellForItemAtIndexPath:path];
            
            if (data) {
                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                image.frameCacheSizeMax = 1;
                cell.gifImageView.animatedImage = image;
            } else {
                cell.gifImageView.animatedImage = nil;
            }
            
            [cell updateBackgroundRandomColor:(data == nil)];
        }
        
        if (path.row < self.dataArray.count) {
            MGif *mGif = [self.dataArray objectAtIndex:path.row];
            [self.currentLoadingImagesUrlsArray removeObject:mGif.previewURLString];
        } else {
            NSLog(@"wasLoadedByIndexPath: smth going WRONG, %ld", (long)path.row);
        }
    }
}

@end

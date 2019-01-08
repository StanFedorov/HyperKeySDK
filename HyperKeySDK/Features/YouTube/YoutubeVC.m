//
//  YoutubeVC.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "YoutubeVC.h"

#import "Masonry.h"
#import "ImagesLoadingAndSavingManager.h"
#import "YoutubeCell.h"
#import "YoutubeAPI.h"
#import "KeyboardConfig.h"

@interface YoutubeVC () <UICollectionViewDataSource, UICollectionViewDelegate, ImagesLoadingAndSavingManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (strong, nonatomic) YoutubeAPI *api;
@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;
@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) NSString *lastSearchString;

@property (assign, nonatomic) BOOL isSearching;
@property (assign, nonatomic) BOOL cleanBeforeReload;

@end

@implementation YoutubeVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *cellName = NSStringFromClass([YoutubeCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = [YoutubeCell cellSizeWithSectionInsets:layout.sectionInset andCellSpacing:layout.minimumInteritemSpacing];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    self.lastSearchString = @"temp";
    self.isSearching = NO;
    self.cleanBeforeReload = NO;
    
    self.searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search video" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    
    self.fileManager = [[ImagesLoadingAndSavingManager alloc] init];
    self.fileManager.delegate = self;
    
    self.api = [[YoutubeAPI alloc] init];
    self.videos = [NSMutableArray new];
    
    [self loadInfoLogic];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionSearch) name:kKeyboardNotificationActionSearchButton object:nil];
    
    if (self.shouldReloadInfo) {
        self.shouldReloadInfo = NO;
        [self loadInfoLogic];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self hideHoverView];
}


#pragma mark - Actions

- (IBAction)actionYoutube:(id)sender {
    [self.delegate functionButton:sender];
}

- (IBAction)actionSearch {
    [self.delegate hideKeyboard];
        
    [self search];
}


#pragma mark - Private

- (void)loadInfoLogic {
    if ([REA_MANAGER reachabilityStatus] == 0) {
        [self setupHoverViewByType:HoverViewTypeNoInternet];
        self.shouldReloadInfo = YES;
    } else {
        [self search];
    }
}

- (NSString *)searchString {
    return [self.searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)search {
    NSString *searchString = [self searchString];
    if (![self.lastSearchString isEqualToString:searchString] && !self.isSearching) {
        [self loadDataFromSearch:searchString];
    }
}

- (void)loadDataFromSearch:(NSString *)search {
    if (![self.lastSearchString isEqualToString:search]) {
        self.cleanBeforeReload = YES;
    }
    
    self.lastSearchString = search;
    self.isSearching = YES;
    
    __weak __typeof(self)weakSelf = self;
    [self.api searchVideo:search completion:^(NSArray * _Nullable result, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        if (!error) {
            if (result.count > 0) {
                [strongSelf addVideosArray:result];
                [strongSelf hideNoResultHoverView];
            } else {
                [strongSelf.videos removeAllObjects];
                [strongSelf reloadCollectionOnMainThreadAndSetZeroOffset:YES];
                [strongSelf showNoResultHoverViewAboveSubview:strongSelf.collectionView];
                
                strongSelf.isSearching = NO;
            }
        } else {
            strongSelf.isSearching = NO;
        }
    }];
}

- (void)addVideosArray:(NSArray *)youtubes {
    if (youtubes.count == 0) {
        return;
    }
    
    BOOL zeroOffset = NO;
    
    if (self.cleanBeforeReload) {
        [self.videos removeAllObjects];
        self.cleanBeforeReload = NO;
        zeroOffset = YES;
    }
    [self.videos addObjectsFromArray:youtubes];
    
    [self reloadCollectionOnMainThreadAndSetZeroOffset:zeroOffset];
}

- (void)imageData:(NSData *)data wasLoadedByIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

- (void)reloadCollectionOnMainThreadAndSetZeroOffset:(BOOL)offset {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        [strongSelf.collectionView reloadData];
        if (offset) {
            [strongSelf.collectionView setContentOffset:CGPointZero animated:YES];
        }
        strongSelf.isSearching = NO;
    });
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YoutubeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YoutubeCell class]) forIndexPath:indexPath];
    
    [cell.indicatorView showAnimated:NO];
    
    YoutubeModel *model = self.videos[indexPath.item];
    
    cell.trackNameLabel.text = model.title;
    
    __weak __typeof(model)weakModel = model;
    __weak __typeof(cell)weakCell = cell;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [self.fileManager loadDataIfItNotExistsByPath:weakModel.imageUrl byServiceType:ServiceTypeYoutube andSelectedIndex:indexPath andType:ImageAsynchronicallySimpleDownload];
        if (imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakCell)strongCell = weakCell;
                if (!strongCell) {
                    return;
                }
                
                strongCell.imageView.image = [UIImage imageWithData:imageData];
                [strongCell.indicatorView hideAnimated:NO];
            });
         }
    });
    
    if (model.duration) {
        cell.trackLengthLabel.text = model.duration;
    } else {
        [self.api durationForVideo:model.videoId completion:^(NSString *_Nullable result, NSError * _Nullable error) {
            if (!result) {
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(weakModel)strongModel = weakModel;
                __strong __typeof(weakCell)strongCell = weakCell;
                if (!strongModel || !strongCell) {
                    return;
                }
                
                strongModel.duration = result;
                strongCell.trackLengthLabel.text = result;
            });
        }];
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self actionAnimated]) {
        return;
    }
    
    YoutubeModel *model = self.videos[indexPath.item];
    
    if (model.videoId) {
        YoutubeCell *cell = (YoutubeCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        [self insertLinkWithURLString:[self.api videoUrlById:model.videoId] title:model.title featureType:self.featureType completion:nil];
        
        // Temporarily hidden, need preview in main app for this feature
        //[RecentSharedManager addRecentSharedWithFeatureType:self.featureType preview:cell.imageView.image shared:nil sharedType:DataTypeURL sourceURLString:insertData.urlString];
        
        [self addActionAnimationToView:cell.imageContentView contentView:cell type:ActionViewTypePaste options:0];
        
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView && !self.isSearching) {
        if (scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height) {
            [self loadDataFromSearch:[self searchString]];
        }
    }
}


#pragma mark - UITextFieldIndirectDelegate

- (UITextField *)forceFindSearchTextField{
    return self.searchField;
}

@end

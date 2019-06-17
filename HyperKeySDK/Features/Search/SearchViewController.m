//
//  SearchViewController.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 11/05/2019.
//  Copyright © 2019 Hyperkey. All rights reserved.
//

#import "SearchViewController.h"
#import "GifAPIClient.h"
#import "GifCell.h"
#import "GifCategoryCell.h"
#import "ImagesLoadingAndSavingManager.h"
#import "PasteboardManager.h"
#import <YelpAPI/YelpAPI.h>
#import "JSONSessionManager.h"
#import "LocationManager.h"
#import "YelpCellSmall.h"
#import "YoutubeCell.h"
#import "YoutubeAPI.h"

@interface SearchViewController () <ImagesLoadingAndSavingManagerDelegate>
@property (weak,nonatomic) IBOutlet UICollectionView *gifsCollectionView;
@property (weak,nonatomic) IBOutlet UICollectionView *yelpCollectionView;
@property (weak,nonatomic) IBOutlet UICollectionView *youtubeCollectionView;
@property (weak,nonatomic) IBOutlet UIScrollView *mainScroll;
// Gifs
@property (assign, nonatomic) BOOL existNextData;
@property (assign, nonatomic) BOOL isLoadingData;
@property (strong, nonatomic) NSString *offset;
@property (strong, nonatomic) GifAPIClient *gifAPIClient;
@property (assign, nonatomic) NSUInteger trimDataCount;
@property (strong, nonatomic) NSOperationQueue *imagesLoadingQueue;
@property (strong, nonatomic) NSMutableArray *currentLoadingImagesUrlsArray;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) CGSize gifCellSize;
@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;
@property (strong, nonatomic) NSIndexPath *currentCopyingImageIndexPath;
// Yelp
@property (strong, nonatomic) NSMutableArray *placesArray;
@property (strong, nonatomic) YLPClient *yelp;
@property (strong, nonatomic) JSONSessionManager *sessionManager;
@property (assign, nonatomic) CGSize yelpCellSize;
// YouTube
@property (strong, nonatomic) YoutubeAPI *api;
@property (strong, nonatomic) NSMutableArray *videos;
@property (assign, nonatomic) CGSize youtubeCellSize;
@end

@implementation SearchViewController
@synthesize searchQuery,keyboardViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateGifItemSide];
    [self updateYelpItemSide];
    [self updateYoutubeItemSide];
    NSString *cellName = NSStringFromClass([GifCell class]);
    [self.gifsCollectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle bundleForClass:GifCell.class]] forCellWithReuseIdentifier:cellName];
    NSString *cellNameYelp = NSStringFromClass([YelpCellSmall class]);
    [self.yelpCollectionView registerNib:[UINib nibWithNibName:cellNameYelp bundle:[NSBundle bundleForClass:YelpCellSmall.class]] forCellWithReuseIdentifier:cellNameYelp];
    NSString *cellNameYotube = NSStringFromClass([YoutubeCell class]);
    [self.youtubeCollectionView registerNib:[UINib nibWithNibName:cellNameYotube bundle:[NSBundle bundleForClass:YoutubeCell.class]] forCellWithReuseIdentifier:cellNameYotube];
    self.gifAPIClient = [[GifAPIClient alloc] init];
    self.currentLoadingImagesUrlsArray = [[NSMutableArray alloc] init];
    self.imagesLoadingQueue = [[NSOperationQueue alloc] init];
    self.imagesLoadingQueue.maxConcurrentOperationCount = 2;
    self.imagesLoadingQueue.qualityOfService = NSQualityOfServiceBackground;
    self.fileManager = [[ImagesLoadingAndSavingManager alloc] init];
    self.fileManager.delegate = self;
    self.fileManager.serviceType = ServiceTypeGIFs;
    [self.fileManager cancelAllAsynchronicalWithProgressObservingDownloads];
    self.sessionManager = [JSONSessionManager new];
    self.yelp = [[YLPClient alloc] initWithAPIKey:@"1doZsU9hc0y3u0DMHYI08vV99-XIMS8Zr_bMngAlHZ1vy2Ol4HMVRpkECS9zo2ypymMYV1Q9vcEK7GMt17W8n3a82iyQNLAp8GvdhI4MmxSgJ3SJRmyG-2ScZbpPW3Yx"];
    if (!self.placesArray) {
        self.placesArray = [[NSMutableArray alloc] init];
    }
    self.api = [[YoutubeAPI alloc] init];
    self.videos = [NSMutableArray new];
    [self loadItemsWithSearch:searchQuery];
    [self loadPlacesBySearchText:self.searchQuery];
    [self loadYouTubeFromSearch:self.searchQuery];
    self.mainScroll.contentSize = CGSizeMake(self.view.frame.size.width, 600);
}

- (IBAction)gifSeeAll:(id)sender {
    [self.keyboardViewController switchToFeature:[KeyboardFeature featureWithType:FeatureTypeGif]];
}

- (IBAction)yelpSeeAll:(id)sender {
    [self.keyboardViewController switchToFeature:[KeyboardFeature featureWithType:FeatureTypeYelp]];
}

- (IBAction)youtubeSeeAll:(id)sender {
    [self.keyboardViewController switchToFeature:[KeyboardFeature featureWithType:FeatureTypeYoutube]];
}

- (void)updateGifItemSide {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.gifsCollectionView.collectionViewLayout;
    collectionViewLayout.minimumInteritemSpacing = 8;
    collectionViewLayout.minimumLineSpacing = 8;
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    UIEdgeInsets contentInset = self.gifsCollectionView.contentInset;
    CGFloat cellSpacing = collectionViewLayout.minimumInteritemSpacing;
    CGFloat lineSpacing = collectionViewLayout.minimumLineSpacing;
    CGSize size = CGSizeZero;
    size.width = ceilf(((self.gifsCollectionView.bounds.size.height) - sectionInset.left - sectionInset.right - cellSpacing * 0) / 1);
    size.height = floorf(((self.gifsCollectionView.bounds.size.height) - contentInset.top - contentInset.bottom - sectionInset.top - sectionInset.bottom - lineSpacing ) / 1);
    self.gifCellSize = size;
}

- (void)updateYelpItemSide {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.yelpCollectionView.collectionViewLayout;
    collectionViewLayout.minimumInteritemSpacing = 8;
    collectionViewLayout.minimumLineSpacing = 8;
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    UIEdgeInsets contentInset = self.yelpCollectionView.contentInset;
    CGFloat cellSpacing = collectionViewLayout.minimumInteritemSpacing;
    CGFloat lineSpacing = collectionViewLayout.minimumLineSpacing;
    CGSize size = CGSizeZero;
    size.width = ceilf(((self.yelpCollectionView.bounds.size.height) - sectionInset.left - sectionInset.right - cellSpacing * 0) / 1);
    size.height = floorf(((self.yelpCollectionView.bounds.size.height) - contentInset.top - contentInset.bottom - sectionInset.top - sectionInset.bottom - lineSpacing ) / 1);
    self.yelpCellSize = size;
}

- (void)updateYoutubeItemSide {
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.youtubeCollectionView.collectionViewLayout;
    collectionViewLayout.minimumInteritemSpacing = 8;
    collectionViewLayout.minimumLineSpacing = 8;
    UIEdgeInsets sectionInset = collectionViewLayout.sectionInset;
    UIEdgeInsets contentInset = self.youtubeCollectionView.contentInset;
    CGFloat cellSpacing = collectionViewLayout.minimumInteritemSpacing;
    CGFloat lineSpacing = collectionViewLayout.minimumLineSpacing;
    CGSize size = CGSizeZero;
    size.width = ceilf(((self.youtubeCollectionView.bounds.size.height) - sectionInset.left - sectionInset.right - cellSpacing * 0) / 1);
    size.height = floorf(((self.youtubeCollectionView.bounds.size.height) - contentInset.top - contentInset.bottom - sectionInset.top - sectionInset.bottom - lineSpacing ) / 1);
    self.youtubeCellSize = size;
}


- (void)loadItemsWithSearch:(NSString *)searchString {
    [self.currentLoadingImagesUrlsArray removeAllObjects];
    [self.imagesLoadingQueue cancelAllOperations];
    self.existNextData = YES;
    self.isLoadingData = NO;
    self.offset = nil;
    self.trimDataCount = 0;
    self.dataArray = [NSMutableArray new];
    [self.gifsCollectionView reloadData];
    [self.yelpCollectionView reloadData];
    __weak __typeof(self)weakSelf = self;
    [self.gifAPIClient getGifsWithSearch:searchString offset:self.offset limit:50 completion:^(NSError *error, NSArray *gifs, NSString *offset) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!error && gifs.count > 0) {
            strongSelf.offset = offset;
            strongSelf.existNextData = YES;
            [strongSelf addDataFromArray:gifs];
        } else {
            if (strongSelf.dataArray.count == 0) {
                strongSelf.gifsCollectionView.contentOffset = CGPointZero;
                [strongSelf.gifsCollectionView reloadData];
            }
            strongSelf.existNextData = NO;
            strongSelf.isLoadingData = NO;
        }
    }];
}

- (void)addDataFromArray:(NSArray *)data {
    [self addToItemsFilteredItemsFromArray:data];
    [self.gifsCollectionView reloadData];
    self.isLoadingData = NO;
}

- (void)addToItemsFilteredItemsFromArray:(NSArray *)items {
    for (MGif *mGif in items) {
        if ((mGif.previewFileSize > 0) && (mGif.previewFileSize < 500000) && (mGif.fullFileSize < 500000)) {
            [self.dataArray addObject:mGif];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.gifsCollectionView == collectionView) {
        return self.gifCellSize;
    } else if(self.yelpCollectionView == collectionView){
        return self.yelpCellSize;
    } else if(self.youtubeCollectionView == collectionView){
        return self.youtubeCellSize;
    }else {
        return CGSizeMake(0, 0);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.gifsCollectionView == collectionView) {
        return self.dataArray.count;
    } else if(self.yelpCollectionView == collectionView){
        return self.placesArray.count;
    }else if(self.youtubeCollectionView == collectionView){
        return self.videos.count;
    }else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.gifsCollectionView == collectionView) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GifCell class]) forIndexPath:indexPath];
        return cell;
    } else if(self.yelpCollectionView == collectionView){
        YelpCellSmall *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([YelpCellSmall class]) forIndexPath:indexPath];
        NSDictionary *yelpInfo = [self.placesArray objectAtIndex:indexPath.row];
      //  UIImage *avaImage = [self.fileManager loadImageIfItNotExistsByPath:yelpInfo[@"image_url"] byServiceType:ServiceTypeYelp andSelectedIndex:indexPath];
        NSData *imageData = [self.fileManager loadDataIfItNotExistsByPath:yelpInfo[@"image_url"] byServiceType:ServiceTypeYelp andSelectedIndex:indexPath andType:ImageAsynchronicallySimpleDownload];
        cell.avatarImage.image = [UIImage imageWithData:imageData];
        cell.layer.cornerRadius = 6;
        cell.nameLabel.text = yelpInfo[@"name"];
        NSArray *categoryArray = yelpInfo[@"categories"];
        NSString *finalString = @"";
        if (categoryArray.count > 0) {
            NSString *categoryString = finalString.length == 0 ? [NSString stringWithFormat:@"%@", categoryArray[0]] : [NSString stringWithFormat:@",%@", categoryArray[0]];
            finalString = [finalString stringByAppendingString:categoryString];
        }
        cell.descriptionLabel.text = finalString.length == 0 ? @"--" : finalString;
        return cell;
    } else if(self.youtubeCollectionView == collectionView){
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
        cell.layer.cornerRadius = 5;
        cell.layer.masksToBounds = YES;
        return cell;
    }
    else {
        return nil;
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.gifsCollectionView) {
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
                [self.fileManager loadDataIfItNotExistsByPath:mGif.previewURLString byServiceType:ServiceTypeGIFs andSelectedIndex:indexPath andType:ImageAsynchronicallySimpleDownload];
            }];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self actionAnimated]) {
        return;
    }
    if (collectionView == self.gifsCollectionView) {
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
    }else if(collectionView == self.yelpCollectionView) {
        NSDictionary *placeInfo = [self.placesArray objectAtIndex:indexPath.row];
        NSString *urlString = placeInfo[@"url"];
        NSString *address = (((NSArray*)placeInfo[@"location"][@"address"]).count > 0) ? placeInfo[@"location"][@"address"][0] : nil;
        NSString *title = address ? [NSString stringWithFormat:@"%@, %@", placeInfo[@"name"], address] : placeInfo[@"name"];
        [self insertLinkWithURLString:urlString title:title featureType:FeatureTypeYelp completion:nil];
    }else if(collectionView == self.youtubeCollectionView) {
        YoutubeModel *model = self.videos[indexPath.item];
        if (model.videoId) {
            YoutubeCell *cell = (YoutubeCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [self insertLinkWithURLString:[self.api videoUrlById:model.videoId] title:model.title featureType:self.featureType completion:nil];
            [self addActionAnimationToView:cell.imageContentView contentView:cell type:ActionViewTypePaste options:0];
        }
    }
}


#pragma mark - ImagesLoadingAndSavingManagerDelegate

- (void)imageAtIndexPath:(NSIndexPath *)indexPath downloadingProgressChangedTo:(float)progressValue {
    BOOL isVisible = indexPath ? [self.gifsCollectionView.indexPathsForVisibleItems containsObject:indexPath] : NO;
    if (isVisible) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateActionAnimationProgress:progressValue];
        });
    }
}


- (void)imageData:(NSData *)data wasLoadedByIndexPath:(NSIndexPath *)path andServiceType:(ServiceType)serviceType; {
    if(serviceType == ServiceTypeYoutube) {
        if ([self.youtubeCollectionView.indexPathsForVisibleItems containsObject:path]) {
            [self.youtubeCollectionView reloadItemsAtIndexPaths:@[path]];
        }
    }
    else if(serviceType == ServiceTypeYelp) {
        if ([self.yelpCollectionView.indexPathsForVisibleItems containsObject:path]) {
            [self.yelpCollectionView reloadItemsAtIndexPaths:@[path]];
        }
    } else if(serviceType == ServiceTypeGIFs) {
        if ((!path) || ((self.currentCopyingImageIndexPath) && ([path compare:self.currentCopyingImageIndexPath] == NSOrderedSame))) {
            BOOL isVisible = [self.gifsCollectionView.indexPathsForVisibleItems containsObject:self.currentCopyingImageIndexPath];
            if (isVisible) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateActionAnimationProgress:1];
                });
            }
            if (path.item < self.dataArray.count) {
                MGif *mGif = self.dataArray[path.item];
                
                [PasteboardManager clearPasteboard];
                [PasteboardManager setGIF:data];
                
            }
        } else if (path) {
            BOOL isVisible = [self.gifsCollectionView.indexPathsForVisibleItems containsObject:path];
            if (isVisible) {
                GifCell *cell = (GifCell *)[self.gifsCollectionView cellForItemAtIndexPath:path];
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
}

- (void)loadPlacesBySearchText:(NSString *)searchText {
    NSString *term = searchText;
    __weak typeof(self) weakSelf = self;
    if ([LOCATION_MANAGER currentLocation]) {
        [self googleGeocodeRequestByCoord:[LOCATION_MANAGER currentLocation].coordinate withResponceBlock:^(NSArray *resultInfo) {
            if (resultInfo.count > 0) {
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    NSString *city = resultInfo[0][@"city"];
                    [self.yelp searchWithLocation:city term:term limit:10 offset:0 sort:YLPSortTypeBestMatched completionHandler:^
                     (YLPSearch *search, NSError* error) {
                         if(!error) {
                             NSMutableArray *mutablePlacesArray = [NSMutableArray array];
                             NSArray *businesses = search.businesses;
                             for(YLPBusiness *b in businesses) {
                                 NSMutableDictionary *mutablePlace = [NSMutableDictionary new];
                                 CLLocation *myTestLocation = [LOCATION_MANAGER currentLocation];
                                 CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:b.location.coordinate.latitude longitude:b.location.coordinate.longitude];
                                 CLLocationDistance distance = [myTestLocation distanceFromLocation:placeLocation] / 1000;
                                 mutablePlace[@"distance"] = @(distance);
                                 mutablePlace[@"location"] = [NSMutableDictionary new];
                                 mutablePlace[@"location"][@"coordinate"] = [NSMutableDictionary new];
                                 mutablePlace[@"location"][@"coordinate"][@"latitude"] = [NSNumber numberWithDouble:b.location.coordinate.latitude];
                                 mutablePlace[@"location"][@"coordinate"][@"longitude"] = [NSNumber numberWithDouble:b.location.coordinate.longitude];
                                 mutablePlace[@"image_url"] = b.imageURL.absoluteString;
                                 mutablePlace[@"url"] = b.URL.absoluteString;
                                 mutablePlace[@"name"] = b.name;
                                 mutablePlace[@"review_count"] = [NSNumber numberWithInteger:b.reviewCount];
                                 mutablePlace[@"rating"] = [NSNumber numberWithDouble:b.rating];
                                 NSMutableArray *categories = [NSMutableArray new];
                                 for(YLPCategory *c in b.categories) {
                                     [categories addObject:c.name];
                                 }
                                 mutablePlace[@"categories"] = categories;
                                 mutablePlace[@"location"][@"address"] = b.location.address;
                                 [mutablePlacesArray addObject:mutablePlace];
                             }
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 weakSelf.placesArray = mutablePlacesArray;
                                 [weakSelf.yelpCollectionView reloadData];
                             });
                         }
                     }];
                });
            }
        }];
    }
}

- (void)googleGeocodeRequestByCoord:(CLLocationCoordinate2D)coordinate withResponceBlock:(void (^)(NSArray * resultInfo))completion {
    NSString *geocodingBaseUrl = @"https://maps.googleapis.com/maps/api/geocode/json?";
    NSString *urlString = [NSString stringWithFormat:@"%@latlng=%f,%f&sensor=false&language=en&key=AIzaSyCA1X4K_WwGfMLc1z8Z6mf5EyWgn26zQWI", geocodingBaseUrl, coordinate.latitude, coordinate.longitude];
#ifdef DEBUG
    // San Francisco Coordinate
    urlString = [NSString stringWithFormat:@"%@latlng=%f,%f&sensor=false&language=en&key=AIzaSyCA1X4K_WwGfMLc1z8Z6mf5EyWgn26zQWI", geocodingBaseUrl, 37.773972, -122.431297];
#endif
    [self.sessionManager sendDataTaskWithHTTPMethod:@"GET" URLString:urlString parameters:nil headers:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completion([self getInfoFromGoogleGeoResponce:responseObject]);
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        NSLog(@"error: %@", [error localizedDescription]);
        completion(nil);
    }];
}

- (NSArray *)getInfoFromGoogleGeoResponce:(id) responceObject {
    NSMutableArray *filteredResults = [NSMutableArray array];
    NSArray *results = [responceObject objectForKey:@"results"];
    if (results && results.count > 0) {
        for (NSDictionary *result in results) {
            NSString *address = [result objectForKey:@"formatted_address"];
            NSDictionary *geometry = [result objectForKey:@"geometry"];
            NSDictionary *location = [geometry objectForKey:@"location"];
            NSString *lat = [location objectForKey:@"lat"];
            NSString *lng = [location objectForKey:@"lng"];
            NSString *city = @"";
            NSString *country = @"";
            for (NSDictionary *componentInfo in result[@"address_components"]) {
                for (NSString *type in componentInfo[@"types"]) {
                    if ([type isEqualToString:@"locality"]) {
                        city = componentInfo[@"long_name"];
                    }
                    if ([type isEqualToString:@"country"]) {
                        country = componentInfo[@"long_name"];
                    }
                }
            }
            NSDictionary *gc = @{@"lat": lat,@"lng" : lng, @"address" : address, @"city" : city, @"country" : country};
            [filteredResults addObject:gc];
        }
    }
    return filteredResults;
}

- (void)locationUpdate {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [LOCATION_MANAGER startUpdateLocation];
            break;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(performPlacesRequest) name:kLocationManagerDidGetFirstLocation object:nil];
    [self locationUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    BOOL locationAllowed = status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways;
    if (locationAllowed) {
        [LOCATION_MANAGER stopUpdateLocation];
    }
}

- (void)performPlacesRequest {
    [self loadPlacesBySearchText:self.searchQuery];
}

- (void)loadYouTubeFromSearch:(NSString *)search {
    __weak __typeof(self)weakSelf = self;
    [self.api searchVideo:search completion:^(NSArray * _Nullable result, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (!error) {
            if (result.count > 0) {
                if(result.count >= 5) {
                    for(int i = 0; i < 5; i++) {
                        [self.videos addObject:[result objectAtIndex:i]];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf)strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    [strongSelf.youtubeCollectionView reloadData];
                    [strongSelf.youtubeCollectionView setContentOffset:CGPointZero animated:YES];
                });
            }
        }
    }];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

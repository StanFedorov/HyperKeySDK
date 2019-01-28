//
//  YelpVC.m
//  
//
//  Created by Oleg Mytsouda on 18.10.15.
//
//

#import "YelpVC.h"

#import "YelpCell.h"
#import "ImagesLoadingAndSavingManager.h"
#import "Macroses.h"
#import "HProgressHUD.h"
#import "KeyboardConfig.h"
#import "YPAPISample.h"
#import "JSONSessionManager.h"
#import "LocationManager.h"
#import "UIImage+Pod.h"

#import <Masonry/Masonry.h>
#import <YelpAPI/YelpAPI.h>

@interface YelpVC () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ImagesLoadingAndSavingManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *noLocationView;
@property (weak, nonatomic) IBOutlet UIButton *activeLocationButton;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;
@property (strong, nonatomic) UIButton *moreButton;

@property (strong, nonatomic) NSMutableArray *placesArray;
@property (strong, nonatomic) JSONSessionManager *sessionManager;
@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;

@property (assign, nonatomic) BOOL isFromDetails;
@property (assign, nonatomic) BOOL shouldLoadImages;
@property (strong, nonatomic) YLPClient *yelp;
@property (nonatomic) int offset;

@end

@implementation YelpVC

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [JSONSessionManager new];
    self.yelp = [[YLPClient alloc] initWithAPIKey:@"1doZsU9hc0y3u0DMHYI08vV99-XIMS8Zr_bMngAlHZ1vy2Ol4HMVRpkECS9zo2ypymMYV1Q9vcEK7GMt17W8n3a82iyQNLAp8GvdhI4MmxSgJ3SJRmyG-2ScZbpPW3Yx"];
    
    if (!self.placesArray) {
        self.placesArray = [[NSMutableArray alloc] init];
    }
    
    self.isFromDetails = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    NSString *cellName = NSStringFromClass([YelpCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle bundleForClass:YelpCell.class]] forCellReuseIdentifier:cellName];

    self.fileManager = [[ImagesLoadingAndSavingManager alloc] init];
    [self.fileManager setDelegate:self];
    [self.fileManager showContentsOfDirrectoryForServiceType:ServiceTypeYelp];
    
    self.activeLocationButton.layer.cornerRadius = 5.0;
    self.activeLocationButton.layer.masksToBounds = YES;
    self.noLocationView.hidden = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.shouldLoadImages = YES;
    [self.tableView reloadData];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(performSearch) name:kKeyboardNotificationActionSearchButton object:nil];
    [nc addObserver:self selector:@selector(performPlacesRequest) name:kLocationManagerDidGetFirstLocation object:nil];
    [nc addObserver:self selector:@selector(showLocationDenied:) name:kLocationManagerChangeStatusToDenied object:nil];
    
    if (!self.isFromDetails) {
        [self locationUpdate];
    } else {
        self.isFromDetails = NO;
    }
}

- (void)locationUpdate {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [self showLocationDenied:nil];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [LOCATION_MANAGER startUpdateLocation];
            self.noLocationView.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)showLocationDenied:(NSNotification *)note {
    self.noLocationView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    BOOL locationAllowed = status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways;
    if (locationAllowed && !self.isFromDetails) {
        [LOCATION_MANAGER stopUpdateLocation];
    }
    [self hideHoverView];
    
    self.shouldLoadImages = NO;
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Actions

- (IBAction)activateLocation:(UIButton *)sender {
    LocationUpdateStatus status = [LOCATION_MANAGER getLocationUpdateStatus];
    switch (status) {
        case kCLLocationUpdateStatusDenied: {
            UIResponder *responder = self;
            while ((responder = [responder nextResponder]) != nil) {
                NSLog(@"responder = %@", responder);
                if([responder respondsToSelector:@selector(openURL:)] == YES) {
                    [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
        }   break;
            
        case kCLLocationUpdateStatusAllowed:
            [LOCATION_MANAGER startUpdateLocation];
            self.noLocationView.hidden = NO;
            break;
            
        case kCLLocationUpdateStatusNotRespond:
            [LOCATION_MANAGER startUpdateLocation];
            break;
            
        default:
            break;
    }
}

- (void)performSearch {
    [self loadPlacesBySearchText:self.searchField.text];
}

- (void)performPlacesRequest {
    self.noLocationView.hidden = YES;
    
    if ([REA_MANAGER reachabilityStatus] == 0) {
        [self setupHoverViewByType:HoverViewTypeNoInternet];
    } else {
        [self loadPlacesBySearchText:nil];
    }
}

- (IBAction)actionSearch {
    [self.delegate hideKeyboard];
    
    [self performSearch];
}


#pragma mark - API

- (void)loadPlacesBySearchText:(NSString *)searchText {
    NSString *term = searchText;
    if (!searchText) {
        term = @"dinner";
    }
    
    NSString *defaultLocation = @"San Francisco, CA";
    
    [HProgressHUD showHUDSizeType:HProgressHUDSizeTypeBigWhite addedTo:self.hudContainerView animated:YES];
    
    __weak typeof(self) weakSelf = self;
    if ([LOCATION_MANAGER currentLocation]) {
        [self googleGeocodeRequestByCoord:[LOCATION_MANAGER currentLocation].coordinate withResponceBlock:^(NSArray *resultInfo) {
            if (resultInfo.count > 0) {
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                    NSString *city = resultInfo[0][@"city"];
                    [self.yelp searchWithLocation:city term:term limit:20 offset:self.offset sort:YLPSortTypeBestMatched completionHandler:^
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
                             // [mutablePlacesArray sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 if(self.offset == 0)
                                     [weakSelf.placesArray removeAllObjects];
                                 [weakSelf.placesArray addObjectsFromArray:mutablePlacesArray];
                                 [weakSelf.tableView reloadData];
                                 weakSelf.noLocationView.hidden = YES;
                                 
                               //  if(search.total > (weakSelf.offset + 20)) {
                                     if(self.moreButton == nil) {
                                         UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
                                         weakSelf.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
                                         [weakSelf.moreButton setTitle:@"Load More" forState:UIControlStateNormal];
                                         [weakSelf.moreButton setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
                                         [weakSelf.moreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
                                         [footerView addSubview:weakSelf.moreButton];
                                         weakSelf.tableView.tableFooterView = footerView;
                                     }
                              //   }else {
                                   //  weakSelf.tableView.tableFooterView = nil;
                               //  }
                             //
                                 if (weakSelf.placesArray.count > 0) {
                                     [weakSelf hideNoResultHoverView];
                                 } else {
                                     [weakSelf showNoResultHoverViewAboveSubview:weakSelf.tableView];
                                 }
                                 [HProgressHUD hideHUDForView:weakSelf.hudContainerView animated:YES];
                             });
                         }
                     }];
                    
                    
                    
                    
                });
            }
        }];
    }
}

- (void)loadMore {
    self.offset+=20;
    [self loadPlacesBySearchText:self.searchField.text];
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField.text.length > 0) {
        self.offset = 0;
        [self loadPlacesBySearchText:textField.text];
    }
    return YES;
}


#pragma mark - ImagesLoadingAndSavingManagerDelegate

- (void)image:(UIImage *)image wasLoadedByIndexPath:(NSIndexPath *)indexPath {
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YelpCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YelpCell class]) forIndexPath:indexPath];
    
    NSDictionary *yelpInfo = [self.placesArray objectAtIndex:indexPath.row];
    
    if ([LOCATION_MANAGER currentLocation]) {
        CLLocation *myTestLocation = [LOCATION_MANAGER currentLocation];
        CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:[yelpInfo[@"location"][@"coordinate"][@"latitude"] doubleValue] longitude:[yelpInfo[@"location"][@"coordinate"][@"longitude"] doubleValue]];
        
        CLLocationDistance distance = [myTestLocation distanceFromLocation:placeLocation] / 1000;
        
        cell.miLabel.text = [NSString stringWithFormat:@"%.1fml", distance];
    } else {
        cell.miLabel.text = @"--";
    }
    
    cell.avatarImage.image = nil;
    cell.rateImageView.image = nil;
    
    if (self.shouldLoadImages) {
        UIImage *avaImage = [self.fileManager loadImageIfItNotExistsByPath:yelpInfo[@"image_url"] byServiceType:ServiceTypeYelp andSelectedIndex:indexPath];
        if (avaImage) {
            cell.avatarImage.image = avaImage;
            cell.avatarImage.layer.cornerRadius = 5.0;
            cell.avatarImage.layer.masksToBounds = YES;
        }
        
        if([yelpInfo[@"rating"] doubleValue] < 1) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_0.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 1.5) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_1.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 2) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_1_half.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 2.5) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_2.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 3) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_2_half.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 3.5) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_3.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 4) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_3_half.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 4.5) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_4.png"];
        }
        else if([yelpInfo[@"rating"] doubleValue] < 5) {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_4_half.png"];
        }else {
            cell.rateImageView.image = [UIImage imageNamedPod:@"large_5.png"];
        }
    }
    
    
    cell.nameLabel.text = yelpInfo[@"name"];
    cell.adresLabel.text = (((NSArray*)yelpInfo[@"location"][@"address"]).count > 0) ? yelpInfo[@"location"][@"address"][0] : @"No address";
    
    NSArray *categoryArray = yelpInfo[@"categories"];
    NSString *finalString = @"";
    if (categoryArray.count > 0) {
        NSString *categoryString = finalString.length == 0 ? [NSString stringWithFormat:@"%@", categoryArray[0]] : [NSString stringWithFormat:@",%@", categoryArray[0]];
        finalString = [finalString stringByAppendingString:categoryString];
    }
    
    cell.descriptionLabel.text = finalString.length == 0 ? @"--" : finalString;
    cell.reviewsLabel.text = [NSString stringWithFormat:@"%ld Reviews", [yelpInfo[@"review_count"] longValue]];
    cell.hoverView.alpha = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *placeInfo = [self.placesArray objectAtIndex:indexPath.row];
    NSString *urlString = placeInfo[@"url"];
    
    NSString *address = (((NSArray*)placeInfo[@"location"][@"address"]).count > 0) ? placeInfo[@"location"][@"address"][0] : nil;
    NSString *title = address ? [NSString stringWithFormat:@"%@, %@", placeInfo[@"name"], address] : placeInfo[@"name"];
    
    [self insertLinkWithURLString:urlString title:title featureType:self.featureType completion:nil];
    
    NSArray *paths = [tableView indexPathsForVisibleRows];
    YelpCell *cell = (YelpCell *)[tableView cellForRowAtIndexPath:indexPath];
    for (NSIndexPath *path in paths) {
        YelpCell *visibleCell = (YelpCell *)[tableView cellForRowAtIndexPath:path];
        visibleCell.hoverView.alpha = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [cell.hoverView setAlpha:1.0];
    }];
}


#pragma mark - GoogleGeocode

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


#pragma mark - UITextFieldIndirectDelegate

- (UITextField *)forceFindSearchTextField{
    return self.searchField;
}

@end

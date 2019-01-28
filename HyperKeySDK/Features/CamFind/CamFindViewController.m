//
//  CamFindViewController.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 23.02.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "CamFindViewController.h"
#import "CamFindTableViewCell.h"
#import "ImagesLoadingAndSavingManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CamFindAmazonViewController.h"
#import <AVKit/AVKit.h>

@interface CamFindViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak,nonatomic) IBOutlet UITableView *resultsTable;
@property (strong,nonatomic) NSMutableArray *searchResults;
@property (weak,nonatomic) IBOutlet UIImageView *empty;
@property (weak, nonatomic) IBOutlet UIView *noAcccessView;
@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;
@end

@implementation CamFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    /*    self.fileManager = [[ImagesLoadingAndSavingManager alloc] init];
     [self.fileManager setDelegate:self];
     [self.fileManager showContentsOfDirrectoryForServiceType:ServiceTypeCamFind];*/
    
    self.resultsTable.tableFooterView = [UIView new];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.searchResults = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"camFindSearches"]] mutableCopy];
    self.searchResults  = [[[self.searchResults reverseObjectEnumerator] allObjects] mutableCopy];
    [self.resultsTable reloadData];
}

- (void)checkAccess {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        self.noAcccessView.hidden = YES;
    }else {
        self.noAcccessView.hidden = NO;
    }
}

- (IBAction)grantAccess:(id)sender {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusDenied) {
        [self openURL:UIApplicationOpenSettingsURLString];
    }else {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self checkAccess];
            });
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAccess];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.searchResults = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"camFindSearches"]] mutableCopy];
    self.searchResults  = [[[self.searchResults reverseObjectEnumerator] allObjects] mutableCopy];
    if(self.searchResults.count == 0)
        self.empty.hidden = NO;
    else
        self.empty.hidden = YES;
}

- (IBAction)newCamFind:(id)sender {
    [self openURL:@"hyperkeysdk://camfind"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getProfile {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDictionary *headers = @{ @"Content-Type": @"application/x-www-form-urlencoded", @"Authorization": [NSString stringWithFormat:@"Bearer %@",[userDefaults objectForKey:@"camFindJwt"]] };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.camfindapp.com/v1/users/current"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    if (!error) {
                                                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                             options:NSJSONReadingMutableContainers
                                                                                                               error:nil];
                                                        [self fetchFavs:json[@"profile"][@"id"]];
                                                    }
                                                }];
    [dataTask resume];
}

- (void)fetchFavs:(NSString*)userId {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDictionary *headers = @{ @"Content-Type": @"application/x-www-form-urlencoded", @"Authorization": [NSString stringWithFormat:@"Bearer %@",[userDefaults objectForKey:@"camFindJwt"]] };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.camfindapp.com/v1/users/%@/favorites",userId]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                             options:NSJSONReadingMutableContainers
                                                                                                               error:nil];
                                                        NSMutableArray *jsonArray = [json objectForKey:@"favorites"];
                                                        
                                                        if(jsonArray.count == 0) {
                                                            [self fetchRecents];
                                                        }else {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.searchResults = [NSMutableArray new];
                                                                int limit = 10;
                                                                for(NSDictionary *item in jsonArray) {
                                                                    if(self.searchResults.count < limit) {
                                                                        NSMutableDictionary *newItem = [item mutableCopy];
                                                                        [self.searchResults addObject:newItem];
                                                                        [self searchItem:newItem];
                                                                    }else {
                                                                        break;
                                                                    }
                                                                }
                                                                [self.resultsTable reloadData];
                                                            });
                                                        }
                                                    }
                                                }];
    [dataTask resume];
}

- (void)fetchRecents {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDictionary *headers = @{ @"Content-Type": @"application/x-www-form-urlencoded", @"Authorization": [NSString stringWithFormat:@"Bearer %@",[userDefaults objectForKey:@"camFindJwt"]] };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.camfindapp.com/v1/images/popular"]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                    options:NSJSONReadingMutableContainers
                                                                                                                      error:nil];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            self.searchResults = [NSMutableArray new];
                                                            int limit = 10;
                                                            for(NSDictionary *item in jsonArray) {
                                                                if(self.searchResults.count < limit) {
                                                                    NSMutableDictionary *newItem = [item mutableCopy];
                                                                    [self.searchResults addObject:newItem];
                                                                    [self searchItem:newItem];
                                                                }else {
                                                                    break;
                                                                }
                                                            }
                                                            [self.resultsTable reloadData];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}

- (void)searchItem:(NSMutableDictionary*)item {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDictionary *headers = @{ @"Content-Type": @"application/json", @"Authorization": [NSString stringWithFormat:@"Bearer %@",[userDefaults objectForKey:@"camFindJwt"]] };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.camfindapp.com/v1/buy_similar"]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    NSMutableDictionary *jsonData = [NSMutableDictionary new];
    NSMutableDictionary *buy_similar = [NSMutableDictionary new];
    [buy_similar setObject:item[@"name"] forKey:@"search_string"];
    [buy_similar setObject:@"us" forKey:@"country_code"];
    [jsonData setObject:buy_similar forKey:@"buy_similar"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSMutableArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                    options:NSJSONReadingMutableContainers
                                                                                                                      error:nil];
                                                        NSDictionary *firstLink = [jsonArray objectAtIndex:0];
                                                        item[@"link"] = firstLink[@"url"];
                                                        item[@"desc"] = firstLink[@"title"];
                                                        [self.resultsTable reloadData];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.resultsTable reloadData];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CamFindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CamFindTableViewCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle bundleForClass:NSClassFromString(@"CamFindTableViewCell")] loadNibNamed:@"CamFindTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.itemTitle.text = [self.searchResults objectAtIndex:indexPath.row][@"title"];
    cell.itemDesc.text = [NSString stringWithFormat:@"Found via CamFind at %@", [self.searchResults objectAtIndex:indexPath.row][@"date"]];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSString *previewUrl = [userDefaults objectForKey:[NSString stringWithFormat:@"camfind_%@",cell.itemTitle.text]];
    if(previewUrl.length == 0) {
        [self searchImage:cell.itemTitle.text];
    }else {
        [cell.imageIcon sd_setImageWithURL:[NSURL URLWithString:previewUrl]];
    }
    return cell;
}

- (void)searchImage:(NSString*)query {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDictionary *headers = @{ @"Ocp-Apim-Subscription-Key": @"e0d5f3bfc1814598891169a8bd6aaedd" };
    NSString *encodedQuery = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=%@&count=50",encodedQuery]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:headers];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                 options:NSJSONReadingMutableContainers
                                                                                                                   error:nil];
                                                        NSDictionary *firstLink = [jsonData[@"value"] objectAtIndex:0];
                                                        [userDefaults setObject:firstLink[@"thumbnailUrl"] forKey:[NSString stringWithFormat:@"camfind_%@",query]];
                                                        [userDefaults synchronize];
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self.resultsTable reloadData];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CamFindAmazonViewController *infoVC = [[CamFindAmazonViewController alloc] initWithNibName:NSStringFromClass([CamFindAmazonViewController class]) bundle:[NSBundle bundleForClass:NSClassFromString(@"CamFindAmazonViewController")]];
    infoVC.camFindItem = [self.searchResults objectAtIndex:indexPath.row][@"title"];
    [infoVC setDelegate:self.delegate];
    [self.navigationController pushViewController:infoVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
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

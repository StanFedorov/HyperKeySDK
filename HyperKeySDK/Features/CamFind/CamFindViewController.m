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
#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "KeyboardConfig.h"
#import "HProgressHUD.h"

@interface CamFindViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak,nonatomic) IBOutlet UITableView *resultsTable;
@property (strong,nonatomic) NSMutableArray *searchResults;
@property (strong,nonatomic) NSMutableArray *recentResults;
@property (weak,nonatomic) IBOutlet UIView *empty;
@property (weak,nonatomic) IBOutlet UIButton *search;
@property (weak,nonatomic) IBOutlet UIButton *search2;
@property (weak,nonatomic) IBOutlet UIButton *results;
@property (weak,nonatomic) IBOutlet UIButton *history;
@property (weak,nonatomic) IBOutlet UIView *bgView;
@property (weak,nonatomic) IBOutlet UIView *topbar;
@property (weak,nonatomic) IBOutlet UIView *line1;
@property (weak,nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *searchBar;
@property (weak, nonatomic) IBOutlet UIView *noAcccessView;
@property (strong, nonatomic) ImagesLoadingAndSavingManager *fileManager;
@property (nonatomic) int resultMode;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;
@end

@implementation CamFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([CamFindTableViewCell class]) bundle:[NSBundle bundleForClass:NSClassFromString(@"CamFindTableViewCell")]];
    [self.resultsTable registerNib:cellNib forCellReuseIdentifier:@"CamFindTableViewCell"];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.searchField.delegate = self;
    self.search.layer.cornerRadius = 25;
    self.search2.layer.cornerRadius = 25;
    self.resultsTable.tableFooterView = [UIView new];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.searchResults = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"camFindSearches"]] mutableCopy];
    self.searchResults  = [[[self.searchResults reverseObjectEnumerator] allObjects] mutableCopy];
    self.recentResults = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"camFindSearchesRecent"]] mutableCopy];
    self.recentResults  = [[[self.recentResults reverseObjectEnumerator] allObjects] mutableCopy];
    [self.resultsTable reloadData];
}

- (void)checkAccess {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        self.noAcccessView.hidden = YES;
        self.searchBar.hidden = NO;
    }else {
        self.noAcccessView.hidden = NO;
        self.searchBar.hidden = YES;
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
    [self checkEmpty];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkEmpty {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.searchResults = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"camFindSearches"]] mutableCopy];
    self.searchResults  = [[[self.searchResults reverseObjectEnumerator] allObjects] mutableCopy];
    self.recentResults = [[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"camFindSearchesRecent"]] mutableCopy];
    self.recentResults  = [[[self.recentResults reverseObjectEnumerator] allObjects] mutableCopy];
    if(self.searchResults.count == 0 && self.recentResults.count == 0) {
        self.empty.hidden = NO;
        self.search2.hidden = YES;
        self.topbar.hidden = YES;
        self.resultsTable.hidden = YES;
        self.bgView.hidden = YES;
        self.searchBar.hidden = YES;
    }
    else {
        self.empty.hidden = YES;
        self.search2.hidden = NO;
        self.topbar.hidden = NO;
        self.resultsTable.hidden = NO;
        self.bgView.hidden = NO;
        self.searchBar.hidden = NO;
    }
    [self.resultsTable reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [defaults setBool:NO forKey:@"camFindCompleted"];
        [defaults synchronize];
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.resultsTable) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
            if(self.resultMode == 0) {
                [self.recentResults removeObjectAtIndex:indexPath.row];
                self.recentResults  = [[[self.recentResults reverseObjectEnumerator] allObjects] mutableCopy];
            }else {
                [self.searchResults removeObjectAtIndex:indexPath.row];
                self.searchResults  = [[[self.searchResults reverseObjectEnumerator] allObjects] mutableCopy];
            }
            NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:self.searchResults];
            [defaults setObject:newData forKey:@"camFindSearches"];
            [defaults synchronize];
            [self checkEmpty];
        }
    }
}

- (IBAction)newCamFind:(id)sender {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    [userDefaults setBool:YES forKey:kUserDefaultsCamfindRefresh];
    [userDefaults setBool:NO forKey:kUserDefaultsCamfindClose];
    [userDefaults synchronize];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CamFindTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CamFindTableViewCell"];
    cell.backgroundColor = [UIColor clearColor];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDictionary *item;
    if(self.resultMode == 0)
        item = [self.recentResults objectAtIndex:indexPath.row];
    else
        item = [self.searchResults objectAtIndex:indexPath.row];
    cell.itemTitle.text = item[@"title"];
    cell.itemDesc.text = [NSString stringWithFormat:@"Found via CamFind"];
    NSString *previewUrl = [userDefaults objectForKey:[NSString stringWithFormat:@"camfind_%@",cell.itemTitle.text]];
    if(previewUrl.length == 0) {
        [self searchImage:cell.itemTitle.text andImageView:cell.imageIcon];
    }else {
        [cell.imageIcon sd_setImageWithURL:[NSURL URLWithString:previewUrl]];
    }
    return cell;
}

- (void)searchImage:(NSString*)query andImageView:(UIImageView*)iv{
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
                                                            [iv sd_setImageWithURL:[NSURL URLWithString:firstLink[@"thumbnailUrl"]]];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.resultMode == 1)
        return self.searchResults.count;
    else
        return self.recentResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(self.resultMode == 1) {
        [self insertLinkWithURLString:@"" title:[NSString stringWithFormat:@"%@",[self decodeFromPercentEscapeString:[self.searchResults objectAtIndex:indexPath.row][@"url"]]] featureType:self.featureType completion:nil];
    }else {
        [self insertLinkWithURLString:@"" title:[NSString stringWithFormat:@"%@",[self decodeFromPercentEscapeString:[self.recentResults objectAtIndex:indexPath.row][@"url"]]] featureType:self.featureType completion:nil];

    }
}

- (NSString*) decodeFromPercentEscapeString:(NSString *) string {
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef) string,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (IBAction)previousClicked:(id)sender {
    [self.history setTitleColor:[UIColor colorWithRed:96/255.0f green:81/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.line2.backgroundColor = [UIColor colorWithRed:96/255.0f green:81/255.0f blue:255/255.0f alpha:1.0f];
    self.line1.backgroundColor = [UIColor clearColor];
    [self.results setTitleColor:[UIColor colorWithRed:136/255.0f green:136/255.0f blue:136/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.resultMode = 1;
    [self.resultsTable reloadData];
}

- (IBAction)resultsClicked:(id)sender {
    [self.results setTitleColor:[UIColor colorWithRed:96/255.0f green:81/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.line1.backgroundColor = [UIColor colorWithRed:96/255.0f green:81/255.0f blue:255/255.0f alpha:1.0f];
    self.line2.backgroundColor = [UIColor clearColor];
    [self.history setTitleColor:[UIColor colorWithRed:136/255.0f green:136/255.0f blue:136/255.0f alpha:1.0f] forState:UIControlStateNormal];
    self.resultMode = 0;
    [self.resultsTable reloadData];
}

@end

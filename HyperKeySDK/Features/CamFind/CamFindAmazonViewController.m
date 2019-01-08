//
//  CamFindViewController.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 23.02.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "CamFindAmazonViewController.h"
#import "AmazonTableViewCell.h"
#import "ImagesLoadingAndSavingManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URLEncode.h"
#import "XMLReader.h"
#import "KeyboardConfig.h"
#import "HProgressHUD.h"
#import "AmazonPageViewController.h"
#import "GifCategoryCell.h"

@interface CamFindAmazonViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak,nonatomic) IBOutlet UITableView *resultsTable;
@property (strong,nonatomic) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;
@property (nonatomic) BOOL searchInProgress;
@property (weak, nonatomic) IBOutlet UICollectionView *categoriesCollectionView;
@property (strong, nonatomic) NSArray *categoriesArray;
@property (strong, nonatomic) NSArray *categoriesArrayIds;
@property (strong, nonatomic) UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *upButton;
@property (nonatomic) int itemPage;
@property (nonatomic) NSString *activeCategory;
@property (nonatomic) NSString *activeCategoryName;
@end

@implementation CamFindAmazonViewController
@synthesize camFindItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hoverView.seletedSocialType = HoverViewSocialTypeDropBox;
    self.resultsTable.tableFooterView = [UIView new];
    self.searchResults = [NSMutableArray new];
    [SDWebImageManager sharedManager].delegate = self;
    //  [self searchAmazon:@"Amazon"];
    self.featureType = FeatureTypeCamFind;
    NSString* cellName = NSStringFromClass([GifCategoryCell class]);
    [self.categoriesCollectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];
    
    self.categoriesArray = @[@"All", @"Appliances", @"Arts, Crafts & Sewing", @"Automotive", @"Baby", @"Beauty",@"Books",@"Collectibles & Fine Arts",@"Electronics",@"Clothing, Shoes & Jewelry",@"Gift Cards",@"Grocery & Gourmet Food",@"Handmade",@"Health & Personal Care",@"Home & Kitchen",@"Industrial & Scientific",@"Kindle Store",@"Patio, Lawn & Garden",@"Luggage & Travel Gear",@"Magazine Subscriptions",@"CDs & Vinyl",@"Musical Instruments",@"Office Products",@"Prime Pantry",@"Computers",@"Pet Supplies",@"Software",@"Sports & Outdoors",@"Tools & Home Improvement",@"Toys & Games",@"Vehicles",@"Cell Phones & Accessories"];
    self.categoriesArrayIds = @[@"All", @"Appliances", @"ArtsAndCrafts", @"Automotive", @"Baby", @"Beauty",@"Books",@"Collectibles",@"Electronics",@"Fashion",@"GiftCards",@"Grocery",@"Handmade",@"HealthPersonalCare",@"HomeGarden",@"Industrial",@"KindleStore",@"LawnAndGarden",@"Luggage",@"Magazines",@"Music",@"MusicalInstruments",@"OfficeProducts",@"Pantry",@"PCHardware",@"PetSupplies",@"Software",@"SportingGoods",@"Tools",@"Toys",@"Vehicles",@"Wireless"];
    [self.categoriesCollectionView reloadData];
    self.activeCategory = @"All";
    self.itemPage = 1;
    [self.categoriesCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self searchAmazon:self.camFindItem];
}


- (IBAction)scrollToTop:(id)sender {
    [self.resultsTable  scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)loadMore {
    self.itemPage++;
    [self searchAmazon:self.camFindItem];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.categoriesCollectionView.collectionViewLayout invalidateLayout];
}

- (void)addFakeItemWithTitle:(NSString*)title price:(NSString*)price seller:(NSString*)seller image:(NSString*)image link:(NSString*)link features:(NSArray*)featuresArr{
    NSMutableDictionary *item = [NSMutableDictionary new];
    item[@"title"] = title;
    item[@"price"] = price;
    item[@"seller"] = seller;
    item[@"image"] = image;
    item[@"link"] = link;
    NSString *features = @"";
    for(NSString *feature in featuresArr) {
        if(feature != nil) {
            if([features length] == 0) {
                features = [features stringByAppendingString:[NSString stringWithFormat:@"• %@",feature]];
            }else {
                features = [features stringByAppendingString:[NSString stringWithFormat:@"\n• %@",feature]];
            }
        }
    }
    item[@"features"] = features;
    [self.searchResults addObject:item];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(performSearch) name:kKeyboardNotificationActionSearchButton object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)searchAmazon:(NSString*)keyword {
    if(self.itemPage == 1)
        [self.searchResults removeAllObjects];
    if(!self.searchInProgress)
        [HProgressHUD showHUDSizeType:HProgressHUDSizeTypeBigWhite addedTo:self.hudContainerView animated:YES];
    self.searchInProgress = YES;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"Service"] = @"AWSECommerceService";
    parameters[@"Operation"] = @"ItemSearch";
    parameters[@"ResponseGroup"] = @"Medium";
    parameters[@"SearchIndex"] = self.activeCategory;
    parameters[@"Availability"] = @"Available";
    parameters[@"Keywords"] = [keyword URLEncode];
    parameters[@"AWSAccessKeyId"] = @"AKIAIO4ZFUAJBTZCRGRA";
    parameters[@"AssociateTag"] = @"hyperkey-20";
    parameters[@"ItemPage"] = [NSString stringWithFormat:@"%i",self.itemPage];
    parameters[@"Timestamp"] = [[dateFormatter stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector: @selector(compare:)];
    NSString *strToSign = [NSString stringWithFormat:@"GET\nwebservices.amazon.com\n/onca/xml\n"];
    NSString *query = @"";
    int index = 0;
    for(NSString *keys in sortedKeys) {
        if(index == 0)
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@=%@",keys,parameters[keys]]];
        else
            query = [query stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",keys,parameters[keys]]];
        index++;
    }
    strToSign = [strToSign stringByAppendingString:query];
    NSString *strToHash = strToSign;
    NSString *salt = @"f0tf7mFDKwPEwwUjdwYzpEWLBqI7ZZqWeqdf7Bs0";
    NSData *saltData = [salt dataUsingEncoding:NSUTF8StringEncoding];
    NSData *paramData = [strToHash dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* hash = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA256, saltData.bytes, saltData.length, paramData.bytes, paramData.length, hash.mutableBytes);
    NSString *base64Hash = [hash base64Encoding];
    query = [query stringByAppendingString:[NSString stringWithFormat:@"&Signature=%@",base64Hash]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://webservices.amazon.com/onca/xml?%@",query]]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"GET"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    if (!error) {
                                                        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                        if([newStr containsString:@"SignatureDoesNotMatch"]) {
                                                            newStr = nil;
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self searchAmazon:keyword];
                                                            });
                                                            return;
                                                        }
                                                        NSLog(@"%@",newStr);
                                                        NSData* dataXml = [newStr dataUsingEncoding:NSUTF8StringEncoding];
                                                        NSError *error = nil;
                                                        NSDictionary *dict = [XMLReader dictionaryForXMLData:dataXml
                                                                                                     options:XMLReaderOptionsProcessNamespaces
                                                                                                       error:&error];
                                                        if(dict[@"ItemSearchResponse"][@"Items"][@"Item"] != nil) {
                                                            NSArray *items = dict[@"ItemSearchResponse"][@"Items"][@"Item"];
                                                            for(NSDictionary *dic in items) {
                                                                NSMutableDictionary *item = [NSMutableDictionary new];
                                                                item[@"title"] = dic[@"ItemAttributes"][@"Title"][@"text"];
                                                                item[@"price"] = dic[@"ItemAttributes"][@"ListPrice"][@"FormattedPrice"][@"text"];
                                                                if(dic[@"ItemAttributes"][@"Manufacturer"][@"text"] != nil)
                                                                    item[@"seller"] = [NSString stringWithFormat:@"by %@",dic[@"ItemAttributes"][@"Manufacturer"][@"text"]];
                                                                else
                                                                    item[@"seller"] = @"";
                                                                item[@"image"] = dic[@"MediumImage"][@"URL"][@"text"];
                                                                item[@"link"] = [dic[@"DetailPageURL"][@"text"] stringByReplacingOccurrencesOfString:@"hyperkey-20" withString:@"hyperk-20"];
                                                                NSString *features = @"";
                                                                if(dic[@"ItemAttributes"][@"Feature"] != [NSNull null]) {
                                                                    if([dic[@"ItemAttributes"][@"Feature"] isKindOfClass:[NSArray class]]) {
                                                                        NSArray *featuresArr = dic[@"ItemAttributes"][@"Feature"];
                                                                        for(NSDictionary *feature in featuresArr) {
                                                                            if(feature != nil) {
                                                                                if([features length] == 0) {
                                                                                    features = [features stringByAppendingString:[NSString stringWithFormat:@"• %@",feature[@"text"]]];
                                                                                }else {
                                                                                    features = [features stringByAppendingString:[NSString stringWithFormat:@"\n• %@",feature[@"text"]]];
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                    item[@"features"] = features;
                                                                }
                                                                item[@"features"] = features;
                                                                [self.searchResults addObject:item];
                                                            }
                                                            dataXml = nil;
                                                            newStr = nil;
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                self.searchInProgress = NO;
                                                                if(self.moreButton == nil) {
                                                                    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
                                                                    self.moreButton = [UIButton buttonWithType:UIButtonTypeSystem];
                                                                    [self.moreButton setTitle:@"Load More" forState:UIControlStateNormal];
                                                                    [self.moreButton setFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
                                                                    [self.moreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
                                                                    [footerView addSubview:self.moreButton];
                                                                    self.resultsTable.tableFooterView = footerView;
                                                                }
                                                                [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
                                                                [self.resultsTable reloadData];
                                                                if(self.searchResults.count <= 10){
                                                                    NSIndexPath* ipath = [NSIndexPath indexPathForRow:0 inSection:0];
                                                                    [self.resultsTable scrollToRowAtIndexPath:ipath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                                                }
                                                            });
                                                            
                                                        }else {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self.searchResults removeAllObjects];
                                                                [self.resultsTable reloadData];
                                                                self.searchInProgress = NO;
                                                                [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
                                                            });
                                                        }
                                                    }else {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            self.searchInProgress = NO;
                                                            [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AmazonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AmazonTableViewCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"AmazonTableViewCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.share.tag = (int)indexPath.row;
    [cell.share removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.share addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.itemTitle.text = [self.searchResults objectAtIndex:indexPath.row][@"title"];
    cell.itemDesc.text = [self.searchResults objectAtIndex:indexPath.row][@"seller"];
    cell.itemPrice.text = [self.searchResults objectAtIndex:indexPath.row][@"price"];
    [cell.imageIcon sd_setImageWithURL:[NSURL URLWithString:[self.searchResults objectAtIndex:indexPath.row][@"image"]] placeholderImage:nil options: SDWebImageRetryFailed | SDWebImageContinueInBackground ];
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    AmazonTableViewCell *cellAmazon = (AmazonTableViewCell*)cell;
    cellAmazon.imageIcon.image = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AmazonPageViewController *infoVC = [[AmazonPageViewController alloc] initWithNibName:NSStringFromClass([AmazonPageViewController class]) bundle:nil];
    infoVC.item = [self.searchResults objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (IBAction)handleBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    if(![self isRowZeroVisible] && self.upButton.hidden) {
        self.upButton.hidden = NO;
    }else if([self isRowZeroVisible] && !self.upButton.hidden){
        self.upButton.hidden = YES;
    }
}

-(BOOL)isRowZeroVisible {
    NSArray *indexes = [self.resultsTable indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == 1) {
            return YES;
        }
    }
    return NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL
{
    image = [self imageWithImage:image scaledToSize:CGSizeMake(100, 100)];
    return image;
}

- (IBAction)shareAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    int index = (int)btn.tag;
    NSString *link = [self.searchResults objectAtIndex:index][@"link"];
    if(link != nil) {
        [self insertLinkWithURLString:link title:@"" featureType:self.featureType completion:nil];
    }
}

- (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)targetSize; {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        } else {
            scaleFactor = heightFactor; // scale to fit width
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else {
            if (widthFactor < heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    UIGraphicsBeginImageContextWithOptions(targetSize, YES, 0);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
 {
 CGRect scaledImageRect = CGRectZero;
 
 CGFloat aspectWidth = newSize.width / image.size.width;
 CGFloat aspectHeight = newSize.height / image.size.height;
 CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
 
 scaledImageRect.size.width = image.size.width * aspectRatio;
 scaledImageRect.size.height = image.size.height * aspectRatio;
 scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
 scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
 
 UIGraphicsBeginImageContextWithOptions( newSize, NO, 0 );
 [image drawInRect:scaledImageRect];
 UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 
 return scaledImage;
 }*/

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    
    NSString *string = [self.categoriesArray objectAtIndex:indexPath.item];
    
    CGRect frame = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.categoriesCollectionView.frame.size.height)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}
                                        context:nil];
    size.width = frame.size.width + 29;
    size.height = collectionView.frame.size.height;
    
    return size;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoriesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([GifCategoryCell class]) forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)aCell forItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCategoryCell *cell = (GifCategoryCell *)aCell;
    cell.titleLabel.text = [self.categoriesArray objectAtIndex:indexPath.item];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.activeCategory = [self.categoriesArrayIds objectAtIndex:indexPath.item];
    self.activeCategoryName = [self.categoriesArray objectAtIndex:indexPath.item];
    [self searchAmazon:self.camFindItem];
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

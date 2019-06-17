//
//  ViewController.m
//  DropBox
//
//  Created by Dmitriy Gonchar on 18.10.15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import "DropBoxViewController.h"

#import "DropInfoTableViewCell.h"
#import "DropInfoTableViewHeaderCell.h"
#import "DropBoxImageLoader.h"
#import "HProgressHUD.h"
#import "Config.h"
#import "KeyboardFeaturesAuthenticationManager.h"
#import "KeyboardConfig.h"

#import <Masonry/Masonry.h>


@interface DropBoxViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *hudContainerView;
@property (weak, nonatomic) IBOutlet UIView *authContainerView;
@property (strong, nonatomic) NSMutableArray *arrayOfDropFiles;
@property (strong, nonatomic) NSMutableDictionary *alpabeticOrder;
@property (strong, nonatomic) NSMutableArray *alpabeticOrderArray;
@property (strong, nonatomic) DBUserClient *client;
//@property (strong, nonatomic) DBRestClient *restClient;
@property (strong, nonatomic) NSString *searchString;

@property (assign, nonatomic) BOOL shouldLoadImages;

@end

@implementation DropBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.borderColor = [UIColor colorWithRed:233/255.0f green:234/255.0f blue:238/255.0f alpha:1.0f].CGColor;
    if(self.filePath == nil)
        self.filePath = @"";
    
    self.hoverView.seletedSocialType = HoverViewSocialTypeDropBox;
    
    if (!self.arrayOfDropFiles) {
        self.arrayOfDropFiles = [[NSMutableArray alloc] init];
    }
    
    self.searchField.delegate = self;
    
    NSString *cellName = NSStringFromClass([DropInfoTableViewCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
    
    cellName = NSStringFromClass([DropInfoTableViewHeaderCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellReuseIdentifier:cellName];
    
    // For see through
   // self.tableView.contentInset = UIEdgeInsetsMake(kSeeThroughSearchBarContentTopOffset, 0, 0, 0);
    
    if (self.navigationController.viewControllers.count > 1) {
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeRight];
    }
    NSArray *dropTokenInfo = [[KeyboardFeaturesAuthenticationManager sharedManager] authorizationObjectForFeatureType:FeatureTypeDropbox];
    self.client = [[DBUserClient alloc] initWithAccessToken:dropTokenInfo[0]];
    if(self.searchString.length == 0 || self.searchString == nil)
        [self loadInfoLogic];
    else
        [self performSearch:self.searchString];
}

- (void)setLastSearch:(NSString *)search {
    self.searchString = search;
}

- (IBAction)checkAccess:(id)sender {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        NSLog(@"responder = %@", responder);
        if([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"hyperkeyapp://dropbox"]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSArray *dropTokenInfo = [[KeyboardFeaturesAuthenticationManager sharedManager] authorizationObjectForFeatureType:FeatureTypeDropbox];
    self.client = [[DBUserClient alloc] initWithAccessToken:dropTokenInfo[0]];
    self.shouldLoadImages = YES;
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionSearch) name:kKeyboardNotificationActionSearchButton object:nil];
    
    if([self.client isAuthorized]) {
        if (self.shouldReloadInfo) {
            self.shouldReloadInfo = NO;
            [self loadInfoLogic];
        }
        [self.tableView reloadData];
        self.authContainerView.hidden = YES;
    }else {
        self.authContainerView.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self hideHoverView];
    
    self.shouldLoadImages = NO;
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)reloadAction {
    self.shouldLoadImages = NO;
    [self.tableView reloadData];
}

- (void)loadInfoLogic {
    [HProgressHUD showHUDSizeType:HProgressHUDSizeTypeBigWhite addedTo:self.hudContainerView animated:YES];
    [[self.client.filesRoutes listFolder:self.filePath]
     setResponseBlock:^(DBFILESListFolderResult *result, DBFILESCreateFolderError *routeError, DBRequestError *networkError) {
         if (result) {
             self.arrayOfDropFiles = [result.entries mutableCopy];
             NSMutableArray *folders = [NSMutableArray new];
             NSMutableArray *items = [NSMutableArray new];
             for(id item in self.arrayOfDropFiles) {
                 if([item isKindOfClass:[DBFILESFolderMetadata class]])
                     [folders addObject:item];
                 else
                     [items addObject:item];
             }
             folders = [[folders sortedArrayUsingComparator:^NSComparisonResult(DBFILESFolderMetadata* a, DBFILESFolderMetadata* b) {
                 return [a.name compare:b.name];
             }] mutableCopy];
             items = [[items sortedArrayUsingComparator:^NSComparisonResult(DBFILESFileMetadata* a, DBFILESFileMetadata* b) {
                 return [a.name compare:b.name];
             }] mutableCopy];
             [self.arrayOfDropFiles removeAllObjects];
             [self.arrayOfDropFiles addObjectsFromArray:folders];
             [self.arrayOfDropFiles addObjectsFromArray:items];
             [self.tableView reloadData];
         }
         [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
     }];
}

- (void)performSearch:(NSString*)query {
    [HProgressHUD showHUDSizeType:HProgressHUDSizeTypeBigWhite addedTo:self.hudContainerView animated:YES];
    [[self.client.filesRoutes search:self.filePath query:query]
     setResponseBlock:^(DBFILESSearchResult *searchResult, DBFILESListFolderError *routeError, DBRequestError *networkError) {
         if (searchResult) {
             self.arrayOfDropFiles = [NSMutableArray new];
             NSArray<DBFILESSearchMatch*> *entries = searchResult.matches;
             for (DBFILESSearchMatch *entry in entries) {
                 [self.arrayOfDropFiles addObject:entry.metadata];
             }
             NSMutableArray *folders = [NSMutableArray new];
             NSMutableArray *items = [NSMutableArray new];
             for(id item in self.arrayOfDropFiles) {
                 if([item isKindOfClass:[DBFILESFolderMetadata class]])
                     [folders addObject:item];
                 else
                     [items addObject:item];
             }
             folders = [[folders sortedArrayUsingComparator:^NSComparisonResult(DBFILESFolderMetadata* a, DBFILESFolderMetadata* b) {
                 return [a.name compare:b.name];
             }] mutableCopy];
             items = [[items sortedArrayUsingComparator:^NSComparisonResult(DBFILESFileMetadata* a, DBFILESFileMetadata* b) {
                 return [a.name compare:b.name];
             }] mutableCopy];
             [self.arrayOfDropFiles removeAllObjects];
             [self.arrayOfDropFiles addObjectsFromArray:folders];
             [self.arrayOfDropFiles addObjectsFromArray:items];
             [self.tableView reloadData];
         }
         [HProgressHUD hideHUDForView:self.hudContainerView animated:YES];
     }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfDropFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //  DBMetadata *fileData = ((NSArray *)self.alpabeticOrderArray[indexPath.section])[indexPath.row];
    
    id fileDataId = [self.arrayOfDropFiles objectAtIndex:(int)indexPath.row];
    BOOL isFolder = NO;
    if([fileDataId isKindOfClass:[DBFILESFolderMetadata class]])
        isFolder = YES;
    
    DropInfoTableViewCell *cell = (DropInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DropInfoTableViewCell class])];
    cell.shouldLoadImages = self.shouldLoadImages;
    
    if(isFolder) {
        DBFILESFolderMetadata *folderData = fileDataId;
        cell.folderData = folderData;
        cell.isFolder = YES;
        cell.fileNameLabel.text = folderData.name;
        cell.fileDateLabel.text = @"";
        cell.dropFileImageView.image = nil;
        cell.dropFileImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.hoverView setAlpha:0];
        cell.fileSizeLabelWidthConstarint.constant = 0;
        cell.namePadding.constant = 7;
        [cell loadDropThumbnailByPath:nil andFileName:nil];
    }else {
        DBFILESFileMetadata *fileData = fileDataId;
        cell.fileData = fileData;
        cell.isFolder = NO;
        cell.fileNameLabel.text = fileData.name;
        cell.fileDateLabel.text = [self.dateFormatterWithDate stringFromDate:fileData.clientModified];
        cell.namePadding.constant = -3;
        [cell.hoverView setAlpha:0];
        [cell loadDropThumbnailByPath:fileData.pathLower andFileName:fileData.name];
    }
    
    UIView *lineView  = [cell.contentView viewWithTag:999];
    if(lineView != nil) {
        [lineView removeFromSuperview];
    }
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height - 1.0, self.tableView.frame.size.width, 1)];
    lineView.tag = 999;
    lineView.backgroundColor = [UIColor colorWithRed:233/255.0f green:234/255.0f blue:238/255.0f alpha:1.0f];
    [cell.contentView addSubview:lineView];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DropInfoTableViewCell *cell = (DropInfoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    // DBMetadata *fileData = ((NSArray *)self.alpabeticOrderArray[indexPath.section])[indexPath.row];
    if (!cell.isFolder) {
        NSArray *paths = [tableView indexPathsForVisibleRows];
        for (NSIndexPath *path in paths) {
            DropInfoTableViewCell *cell = (DropInfoTableViewCell *)[tableView cellForRowAtIndexPath:path];
            cell.hoverView.alpha = 0;
        }
        DBFILESFileMetadata *fileData = [self.arrayOfDropFiles objectAtIndex:(int)indexPath.row];
        [[self.client.sharingRoutes createSharedLinkWithSettings:fileData.pathLower]
         setResponseBlock:^(DBSHARINGSharedLinkMetadata *link, DBSHARINGListSharedLinksError *routeError, DBRequestError *networkError) {
             if (link) {
                 [self insertLinkWithURLString:link.url title:link.name featureType:self.featureType];
             }else {
                 [[self.client.sharingRoutes listSharedLinks:fileData.pathLower cursor:nil directOnly:[NSNumber numberWithBool:YES]]
                  setResponseBlock:^(DBSHARINGListSharedLinksResult *linksArr, DBSHARINGListSharedLinksError *routeError, DBRequestError *networkError) {
                      if(linksArr) {
                          NSArray<DBSHARINGSharedLinkMetadata*> *links = linksArr.links;
                          DBSHARINGSharedLinkMetadata *link = [links objectAtIndex:0];
                          [self insertLinkWithURLString:link.url title:link.name featureType:self.featureType];
                      }
                  }];
             }
         }];
        [UIView animateWithDuration:0.5 animations:^{
            [cell.hoverView setAlpha:1.0];
        }];
    } else {
        DBFILESFolderMetadata *folderData = [self.arrayOfDropFiles objectAtIndex:(int)indexPath.row];
      //  self.filePath = folderData.pathLower;
        //[self loadInfoLogic];
         DropBoxViewController *dropVC = [[DropBoxViewController alloc] initWithNibName:NSStringFromClass([DropBoxViewController class]) bundle:nil];
         dropVC.filePath = folderData.pathLower;
         dropVC.delegate = self.delegate;
         [self.navigationController pushViewController:dropVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (IBAction)actionSearch {
    [self.delegate hideKeyboard];
    if (self.searchTextField.text.length > 0) {
        [self performSearch:self.searchTextField.text];
        //    [self.restClient searchPath:self.filePath ? self.filePath : @"/" forKeyword:self.searchTextField.text];
    } else {
        [self hideNoResultHoverView];
        [self loadInfoLogic];
    }
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)functionButton:(id)sender {
    [self.delegate functionButton:sender];
}


#pragma mark - UITextFieldIndirectDelegate

- (UITextField *)forceFindSearchTextField {
    return self.searchField;
}
@end

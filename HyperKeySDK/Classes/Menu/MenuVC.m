//
//  MenuVC.m
//  
//
//  Created by Oleg Mytsouda on 05.10.15.
//
//

#import "MenuVC.h"
#import "Config.h"
#import "KeyboardConfig.h"
#import "KeyboardThemesHelper.h"
#import "Macroses.h"
#import "MenuItemCollectionViewCell.h"
#import "LXReorderableCollectionViewFlowLayout.h"
#import "UIImage+Pod.h"

#import "ImagesLoadingAndSavingManager.h"

NSString *const kNotificationMenuGetAnyAction = @"kNotificationMenuGetAnyAction";
NSString *const kNotificationKeyboardBlock = @"kNotificationKeyboardBlock";

NSString *const kUserDefaultKludgeAppUrlIndex = @"KludgeAppUrlIndex";
NSString *const kUserDefaultKludgeFirstTimeShow = @"KludgeFirstTimeShow";

NSString *const kMenuVCCellReuseIdentifier = @"MenuItemCell";

@interface MenuVC ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LXReorderableCollectionViewDelegateFlowLayout, ImagesLoadingAndSavingManagerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *gifEmojiSelector;
@property (weak, nonatomic) IBOutlet UIButton *backSpaceButton;
@property (weak, nonatomic) IBOutlet UIView *hover;

@property (strong, nonatomic) ImagesLoadingAndSavingManager *featuresImagesLoadingManager;
@property (assign, nonatomic) BOOL requireMainKeyboard;
@property (assign, nonatomic) BOOL fakeSelectionIsDone;
@property (strong, nonatomic) NSIndexPath *selectedIndexPathBeforeDragging;

@end

@implementation MenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[KeyboardFeaturesManager sharedManager] reloadEnabledAndAllDynamicItemsList];
    
    self.featuresImagesLoadingManager = [[ImagesLoadingAndSavingManager alloc] init];
    self.featuresImagesLoadingManager.delegate = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([MenuItemCollectionViewCell class])bundle:[NSBundle bundleForClass:MenuItemCollectionViewCell.class]] forCellWithReuseIdentifier:kMenuVCCellReuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardBlockHandler) name:kNotificationKeyboardBlock object:nil];
    
    if (self.backSpaceButton) {
        [self.backSpaceButton setImage:[UIImage imageNamedPod:@"backspace_transparent_active"] forState:UIControlStateHighlighted];
        [self addGRToDeleteButton];
    }
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    KBTheme theme = ((NSNumber *)[userDefaults objectForKey:kUserDefaultsKeyboardTheme]).integerValue;
    [self setTheme:theme];
    
    self.requireMainKeyboard = [userDefaults boolForKey:kUserDefaultsSettingMainKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[KeyboardFeaturesManager sharedManager] reloadEnabledAndAllDynamicItemsList];
}

- (NSArray *)actualArray {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[KeyboardFeaturesManager sharedManager].enabledItemsList];
    
    
    /* NSMutableArray *array = [NSMutableArray new];
   
    KeyboardFeature *item1 = [KeyboardFeature featureWithType:FeatureTypeCamFind];
    [array addObject:item1];
    KeyboardFeature *item2 = [KeyboardFeature featureWithType:FeatureTypeEmojiKeypad];
    [array addObject:item2];
    KeyboardFeature *item3 = [KeyboardFeature featureWithType:FeatureTypeGif];
    [array addObject:item3];
    KeyboardFeature *item5 = [KeyboardFeature featureWithType:FeatureTypeYelp];
    [array addObject:item5];
    KeyboardFeature *item6 = [KeyboardFeature featureWithType:FeatureTypeShareLocation];
    [array addObject:item6];
    KeyboardFeature *item7 = [KeyboardFeature featureWithType:FeatureTypeYoutube];
    [array addObject:item7];
    KeyboardFeature *item8 = [KeyboardFeature featureWithType:FeatureTypePhotoLibrary];
    [array addObject:item8];
    KeyboardFeature *item9 = [KeyboardFeature featureWithType:FeatureTypeGoogleTranslate];
    [array addObject:item9];*/
    
    NSUInteger index = array.count;
    
  /*  if (!self.requireMainKeyboard) {
        KeyboardFeature *item = [KeyboardFeature featureWithType:FeatureTypeNone];
        item.imageNameOrUrl = @"feature_menu_plus_icon";
        [array addObject:item];
    }*/

     NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    id firstTimeObject = [userDefaults objectForKey:kUserDefaultKludgeFirstTimeShow];
    
    if (firstTimeObject == nil) {
        [userDefaults setBool:YES forKey:kUserDefaultKludgeFirstTimeShow];
        [userDefaults setInteger:index forKey:kUserDefaultKludgeAppUrlIndex];
        [userDefaults synchronize];
    } else if (array.count <= 1 ) { // Fail-safe
        [userDefaults removeObjectForKey:kUserDefaultKludgeFirstTimeShow];
        [userDefaults synchronize];
    }
    
    return array;
}


#pragma mark - Public

- (void)setCoveredByHover:(BOOL)needToBeCovered {
    if (needToBeCovered) {
        self.hover.hidden = NO;
    }
    [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
        self.hover.alpha = needToBeCovered ? 1 : 0;
    } completion:^(BOOL finished) {
        if (!needToBeCovered) {
            self.hover.hidden = YES;
        }
    }];
}

                            
#pragma mark - Actions

- (IBAction)tapRecent:(id)sender {
    [self.delegate showRecentAction];
}

- (IBAction)tapFeed:(id)sender {
    [self.delegate showFeedAction];
}

- (IBAction)tapGlobe:(id)sender {
    [self.delegate nextKeyboardAction];
}

- (IBAction)tapABC:(id)sender {    
    if ([self.delegate respondsToSelector:@selector(showKeyboard)]) {
        [self.delegate showKeyboard];
    }
}

- (IBAction)tapPlus:(id)sender {
    [self.delegate switchToFeature:[KeyboardFeature featureWithType:FeatureTypeNone]];
}

- (IBAction)tapGifOrEmoji:(id)sender {
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    
    BOOL gifFeature = self.gifEmojiSelector.highlighted;
    self.gifEmojiSelector.highlighted = !gifFeature;
    [self.delegate switchToFeature:[KeyboardFeature featureWithType:(gifFeature ? FeatureTypeEmojiKeypad : FeatureTypeGif)]];
}

                            
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isKeyboardBlockedByTutorial) {
        [self postNotificationForAnyAction];
    }
}
                            

#pragma mark - LXReorderableCollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPathBeforeDragging = [[collectionView indexPathsForSelectedItems] firstObject];
    
    [self postNotificationForAnyAction];
    
    for (MenuItemCollectionViewCell *cell in collectionView.visibleCells) {
        [cell startQuivering];
    }
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath{
    for (MenuItemCollectionViewCell *cell in collectionView.visibleCells) {
        [cell stopQuivering];
    }
    
    [collectionView selectItemAtIndexPath:self.selectedIndexPathBeforeDragging animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didTapDraggingItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isKeyboardBlockedByTutorial || !indexPath) {
        return;
    }
    
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    KeyboardFeature *feature = [[self actualArray] objectAtIndex:indexPath.row];
    [self.delegate switchToFeature:feature];
}

- (void)collectionView:(UICollectionView *)collectionView willScrollOverLimitWithDirection:(LXScrollingDirection)direction {
    //NSLog(@"start scroll %@",(self.direction == LXScrollingDirectionLeft?@"⬅️":@"➡️"));
}

                            
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self actualArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MenuItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMenuVCCellReuseIdentifier forIndexPath:indexPath];

    KeyboardFeature *feature = [[self actualArray] objectAtIndex:indexPath.item];
    
    cell.isNoneFeature = (feature.type == FeatureTypeNone);
    
    // iPhone image should be 31x31
    // iPad image should be 41x41
    
    if (feature.isImageFromResources) {
        cell.imageView.image = [UIImage imageNamedPod:feature.imageNameOrUrl];
    } else {
        // FIXME: Remove ServiceType from project
        ServiceType serviceType = ServiceTypeInstagram;
        if (feature.type == FeatureTypeInstagram) {
            serviceType = ServiceTypeInstagram;
        } else if (feature.type == FeatureTypeGifCamera) {
            serviceType = ServiceTypeGifCamera;
        }
        
        UIImage *image = [self.featuresImagesLoadingManager loadImageIfItNotExistsByPath:feature.imageNameOrUrl byServiceType:serviceType andSelectedIndex:indexPath];
        cell.imageView.image = image ? image : [UIImage imageNamedPod:@"menu_gifCameraPlaceholder"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    cell.imageView.backgroundColor = cell.imageView.image ? [UIColor clearColor] : [UIColor whiteColor];
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = feature.isImageFromResources ? 0.0f : cell.imageView.bounds.size.height/2.0;
    
    if (!self.fakeSelectionIsDone && indexPath.item == 0 && !cell.isNoneFeature) {
        self.fakeSelectionIsDone = YES;
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }

    return cell;
}

- (void)image:(UIImage *)image wasLoadedByIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath) && ([self.collectionView.indexPathsForVisibleItems containsObject:indexPath])) {
        MenuItemCollectionViewCell *cell = (MenuItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];

        cell.imageView.image = image ? image : [UIImage imageNamedPod:@"menu_gifCameraPlaceholder"];
        cell.imageView.backgroundColor = cell.imageView.image ? [UIColor clearColor] : [UIColor whiteColor];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return (!self.requireMainKeyboard)?(indexPath.row < ([[self actualArray] count] - 1)) : YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return (!self.requireMainKeyboard)?(toIndexPath.row < ([[self actualArray] count] - 1)) : YES;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // We set it in IB
    CGFloat horizontalSpacing = (IS_IPAD) ? 10 : 8;
    
    return UIEdgeInsetsMake(0.5, horizontalSpacing, -0.5, horizontalSpacing);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {
    
    if (fromIndexPath.item == self.selectedIndexPathBeforeDragging.item) {
        self.selectedIndexPathBeforeDragging = toIndexPath;
    } else if (toIndexPath.item == self.selectedIndexPathBeforeDragging.item) {
        self.selectedIndexPathBeforeDragging = fromIndexPath;
    }
    
    [[KeyboardFeaturesManager sharedManager] moveEnabledItemFromIndex:fromIndexPath.item toIndex:toIndexPath.item];
}


#pragma mark - ThemeChangesResponderProtocol

- (void)setTheme:(KBTheme)theme {
    self.view.backgroundColor = [UIColor whiteColor];
    //Feed UI design + Hide themes lock KBThemeClassic
    //colorMenuForTheme(theme);
    [self.collectionView reloadData];
}


#pragma mark - Notifications

- (void)postNotificationForAnyAction {
    self.isKeyboardBlockedByTutorial = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMenuGetAnyAction object:nil userInfo:nil];
}

- (void)keyboardBlockHandler {
    self.isKeyboardBlockedByTutorial = YES;
}


#pragma mark - Delete button gesture recognizers

- (void)deleteButtonTap:(UITapGestureRecognizer *)gestureRecognizer {
    [self.delegate deleteTap];
}

- (void)deleteButtonLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self.delegate deleteLongTapBegin];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self.delegate deleteLongTapEnd];
            break;
            
        default:
            break;
    }
}

- (void)addGRToDeleteButton {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonTap:)];
    [self.backSpaceButton addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *lpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonLongPress:)];
    lpGestureRecognizer.minimumPressDuration = kKeyboardDeleteOneCharacterTimerInterval;
    lpGestureRecognizer.numberOfTouchesRequired = 1;
    lpGestureRecognizer.delegate = self;
    [self.backSpaceButton addGestureRecognizer:lpGestureRecognizer];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.backSpaceButton.gestureRecognizers containsObject:gestureRecognizer] &&
        [self.backSpaceButton.gestureRecognizers containsObject:otherGestureRecognizer]) {
        return YES;
    } else {
        return NO;
    }
}

@end

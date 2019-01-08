    //
//  EmojiKeypadViewController.m
//  Better Word
//
//  Created by Sergey Vinogradov on 29.03.16.
//
//

#import "EmojiKeypadViewController.h"
#import "EmojiKeypadCollectionViewCell.h"
#import "Config.h"
#import "Macroses.h"
#import "KeyboardConfig.h"
#import "KeyboardLayoutManager.h"
#import "EmojiPageSelectorViewController.h"
#import "EmojiCategoryCollectionReusableView.h"
#import "GifStripeViewController.h"
#import "UIImage+Pod.h"

NSString *const kEmojiKeypadRecentUsedEmojiCharactersKey = @"RecentUsedEmojiCharactersKey";
NSUInteger const kEmojiKeypadDefaultRecentEmojisMaintainedCount = 20;

@interface EmojiKeypadViewController () <EmojiPageSelectorDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backSpaceButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIView *searchView;

@property (strong, nonatomic) IBOutlet GifStripeViewController *gifStripe;
@property (strong, nonatomic) IBOutlet EmojiPageSelectorViewController *pageSelector;
@property (strong, nonatomic) IBOutlet UIView *pop;
@property (strong, nonatomic) IBOutlet UIImageView *popImage;
@property (strong, nonatomic) IBOutlet UILabel *popLabel;
@property (strong, nonatomic) IBOutlet UIView *bottomBar;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *bottomBarItemsTopAlignConstraintsList;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;

@property (strong, nonatomic) NSArray *emojis;
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSMutableArray *recentEmojis;
@property (strong, nonatomic) NSTimer *popHideTimer;
@property (assign, nonatomic) EmojiSkinTone skinTone;

@property (strong, nonatomic) NSIndexPath *hightlightedIndexPath;
@property (strong, nonatomic) NSTimer *freezeTimer;

@property (assign, nonatomic) BOOL lastEnterIsEmoji;

@end

@implementation EmojiKeypadViewController

@synthesize delegate;

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.categoryList = @[@"RECENT", @"SMILES & PEOPLE", @"ANIMALS & NATURE", @"FOOD & DRINK", @"ACTIVITY", @"TRAVEL & PLACES", @"OBJECTS", @"SYMBOLS", @"FLAGS"];
    
    NSString *cellName = NSStringFromClass([EmojiKeypadCollectionViewCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:[NSBundle bundleForClass:EmojiKeypadCollectionViewCell.class]] forCellWithReuseIdentifier:cellName];
    
    // TODO: Do right headers
    /*
    cellName = NSStringFromClass([EmojiCategoryCollectionReusableView class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellName];
    */
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSArray *emojis = [userDefaults arrayForKey:kEmojiKeypadRecentUsedEmojiCharactersKey];
    self.recentEmojis = [NSMutableArray arrayWithArray:emojis];
    if (!self.recentEmojis) {
        self.recentEmojis = [NSMutableArray new];
    }
    
    self.skinTone = ((NSNumber*)[userDefaults objectForKey:kUserDefaultsSettingEmojiSkinTone]).integerValue;
    self.sectionTitleLabel.text = [self categoryNameAtIndex:0];
    
    [self addGRToDeleteButton];
    
    // Device depending layout
    CGFloat offset = 0;
    
    if (IS_IPHONE) {
        if (IS_IPHONE_6_PLUS) {
            offset = 5;
        } else if (IS_IPHONE_6) {
            offset = 6;
        } else if (IS_IPHONE_5) {
            offset = 8;
        }
    }
    if (offset != 0) {
        for (NSLayoutConstraint *constraint in self.bottomBarItemsTopAlignConstraintsList) {
            constraint.constant -= offset;
        }
    }
    
    KBTheme theme = ((NSNumber *)[userDefaults objectForKey:kUserDefaultsKeyboardTheme]).integerValue;
    [self setTheme:theme];
    
    self.bottomBar.backgroundColor = [UIColor clearColor];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search GIFs" attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performSearchFieldSearch) name:kKeyboardNotificationActionSearchButton object:nil];
    
    self.searchView.hidden = ![self gifStripeAllowed];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kKeyboardNotificationActionSearchButton object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.contentViewTopConstraint.constant = ([LayoutManager isGifStripeShow] ? kGifStripeGeight : 0);
    
    if ([LayoutManager isGifStripeShow]) {
        [self.gifStripe viewWillLayoutSubviews];
    }
}


#pragma mark - Private

- (NSArray *)emojis {
    if (!_emojis) {
        
        NSString *suffix = @"_8";
        if (IS_IOS9) {//9 or 10
            suffix = @"_9";
        }
        
        if (IS_IOS10) {
            suffix = @"_10";
        }
        
        NSString *plistPath = [[NSBundle bundleForClass:NSClassFromString(@"HKKeyboardViewController")] pathForResource:[@"EmojisList" stringByAppendingString:suffix] ofType:@"plist"];
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
        NSUInteger skinTone = [userDefaults integerForKey:kUserDefaultsSettingEmojiSkinTone];
        NSArray *rawList = [NSArray arrayWithContentsOfFile:plistPath];
        
        if (skinTone != EmojiSkinToneYellow) {
            NSMutableArray *originList = [[NSMutableArray alloc] init];
            for (NSArray *array in rawList) {
                [originList addObject:[NSMutableArray arrayWithArray:array]];
            }
            
            plistPath = [[NSBundle bundleForClass:NSClassFromString(@"HKKeyboardViewController")] pathForResource:@"skinTonedList" ofType:@"plist"];
            NSArray *skinToned = [[NSArray arrayWithContentsOfFile:plistPath] copy];
            NSArray *origin = [skinToned objectAtIndex:EmojiSkinToneYellow];
            NSArray *tanned = [skinToned objectAtIndex:skinTone];
            
            NSUInteger index = 0;
            for (NSMutableArray *categoryList in originList) {
                for (int i = 0; i < [origin count]; i ++) {
                    index = [categoryList indexOfObject:[origin objectAtIndex:i]];
                    if (index != NSNotFound) {
                        [categoryList replaceObjectAtIndex:index withObject:[tanned objectAtIndex:i]];
                    }
                }
            }
            
            _emojis = [NSArray arrayWithArray:originList];
        } else {
            _emojis = [NSArray arrayWithArray:rawList];
        }
        
    }
    
    return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
    if (index == 0 && self.recentEmojis.count == 0) {
        return [self.categoryList objectAtIndex:1];
    }
    
    return [self.categoryList objectAtIndex:index];
}

- (void)tryToInsertTextString:(NSString *)textString {
    [self unFreezeScroll];
    self.textField.text = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertTextStringToCurrentPosition:)]) {
        [self.delegate insertTextStringToCurrentPosition:textString];
        
    }
    
    if (![textString isEqualToString:@" "]) {
        [self addToRecentEmojiString:textString];
    }
}

- (void)addToRecentEmojiString:(NSString *)emoji {
    // Avoid double
    if ([self.recentEmojis containsObject:emoji]) {
        return;
    }
    
    [self.recentEmojis insertObject:emoji atIndex:0];
    
    // Remove emojis if they cross the cache maintained limit
    if ([self.recentEmojis count] > kEmojiKeypadDefaultRecentEmojisMaintainedCount) {
        NSRange indexRange = NSMakeRange(kEmojiKeypadDefaultRecentEmojisMaintainedCount, [self.recentEmojis count] - kEmojiKeypadDefaultRecentEmojisMaintainedCount);
        NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:indexRange];
        if (indexesToBeRemoved.count) {
            [self.recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
        }
    }
    
    if (self.recentEmojis.count == 1) {
        [self startHideTimer];
        [self.collectionView reloadData];
    } else {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    [defaults setObject:self.recentEmojis forKey:kEmojiKeypadRecentUsedEmojiCharactersKey];
    [defaults synchronize];
}

- (NSString *)emojiStringAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *category = (indexPath.section) ? [self.emojis objectAtIndex:(indexPath.section - 1)] : self.recentEmojis;
    if ([category count] == 0) {
        category = [self.emojis objectAtIndex:0];
    }
    return [category objectAtIndex:indexPath.row];
}

- (void)hidePop {
    [self.pop removeFromSuperview];
}

- (void)showPopForIndexPath:(NSIndexPath *)indexPath andCenter:(CGPoint)center {
    if (IS_IPAD) {
        return;
    }
    
    [self hidePop];
    
    CGRect frame = self.pop.frame;
    frame.origin = CGPointMake(center.x - frame.size.width / 2, center.y - 89.5);
    self.pop.frame = frame;
    
    self.popLabel.text = [self emojiStringAtIndexPath:indexPath];
    
    [self.collectionView addSubview:self.pop];
}

- (void)stopHideTimer {
    [self.popHideTimer invalidate];
    self.popHideTimer = nil;
}

- (void)startHideTimer {
    self.popHideTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(hidePop) userInfo:nil repeats:NO];
}

- (void)performSearchFieldSearch {
    if (![self gifStripeAllowed]) {
        return;
    }
    
    NSString *string = [self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self.gifStripe updateContentForString:string];
}

- (BOOL)gifStripeAllowed {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    return [userDefaults boolForKey:kUserDefaultsSettingAllowGifStripe];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger result = 0;
    
    if (section == 0) {
        result = self.recentEmojis.count;
    } else {
        result = [[self.emojis objectAtIndex:(section - 1)] count];
    }
    
    return result;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmojiKeypadCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([EmojiKeypadCollectionViewCell class]) forIndexPath:indexPath];
    
    [cell setString:[self emojiStringAtIndexPath:indexPath]];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.categoryList.count;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    [self startFreezeTimer];
    [self setHightlightedIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView.scrollEnabled) {
        [self tryToInsertTextString:[self emojiStringAtIndexPath:indexPath]];
        [self setUnHightlightedIndexPath:indexPath];
    }
}


#pragma mark - Moved popup

/**
 1.Tap down -> show popup
 2.Tap Up (cancel tap) -> hide popup + insert text
 
 1.Tap down + hold -> show popup
 2.->hold -> freeze scroll
 3.move -> change highlighted -> hide old + show new popup
 ...
 4.Tap Up (cancel tap) -> hide popup + insert text + unfreeze scroll
 */

- (void)setHightlightedIndexPath:(NSIndexPath *)hightlightedIndexPath {
    if (!hightlightedIndexPath || [self.hightlightedIndexPath isEqual:hightlightedIndexPath]) {
        _hightlightedIndexPath = hightlightedIndexPath;
        return;
    }
    _hightlightedIndexPath = hightlightedIndexPath;
    
    
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.hightlightedIndexPath];
    [self showPopForIndexPath:self.hightlightedIndexPath andCenter:attributes.center];
}

- (void)setUnHightlightedIndexPath:(NSIndexPath *)indexPath {
    self.lastEnterIsEmoji = YES;
    
    [self stopFreezeTimer];
    [self startHideTimer];
}

- (IBAction)collectionViewPanGestireRecognizer:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    switch (sender.state) {
        case UIGestureRecognizerStateChanged:
            if (!self.collectionView.scrollEnabled) {
                if (indexPath) {
                    [self setHightlightedIndexPath:indexPath];
                } else {
                    [self setUnHightlightedIndexPath:nil];
                    [self unFreezeScroll];
                }
            }
            break;
            
        case UIGestureRecognizerStateEnded:
            if (self.pop.superview) {
                [self unFreezeScroll];
                [self tryToInsertTextString:[self emojiStringAtIndexPath:indexPath]];
                [self setUnHightlightedIndexPath:indexPath];
            }
            break;
            
        default:
            break;
    }
}

- (IBAction)collectionViewLongPressGestireRecognizer:(UIPanGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    if (sender.state == UIGestureRecognizerStateEnded && [self.pop superview]) {
        [self setUnHightlightedIndexPath:indexPath];
    }
}

- (void)freezeScroll {
    [self stopFreezeTimer];
    self.collectionView.scrollEnabled = NO;
}

- (void)unFreezeScroll {
    self.collectionView.scrollEnabled = YES;
}

- (void)stopFreezeTimer {
    [self.freezeTimer invalidate];
    self.freezeTimer = nil;
}

- (void)startFreezeTimer {
    self.freezeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(freezeScroll) userInfo:nil repeats:NO];
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize result = CGSizeMake(38.0, 38.0);
    
    if (IS_IPHONE) {
        if (IS_IPHONE_6) {
            result = CGSizeMake(35.0, 35.0);
        } else if (IS_IPHONE_5) {
            result = CGSizeMake(36.0, 36.0);
        }
    } else {
        result = CGSizeMake(58.0, 65.0);
    }
    
    return result;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    BOOL areWeHaveRecent = (self.recentEmojis.count > 0);

    UIEdgeInsets result = UIEdgeInsetsMake(4, areWeHaveRecent ? 8 : 0, 0, 8);
    
    if (IS_IPHONE) {
        if (IS_IPHONE_6) {
            result = UIEdgeInsetsMake(6, areWeHaveRecent ? 10 : -2, 0, 10);
        } else if (IS_IPHONE_6_PLUS) {
            result = UIEdgeInsetsMake(5, areWeHaveRecent ? 7 : 0, 0, 10);
        }
    }
    
    return result;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    CGFloat result = 0.0;
    if (IS_IPHONE) {
        if (IS_IPHONE_6) {
            result = 6;
        } else if (IS_IPHONE_6_PLUS) {
            result = 2;
        }
    }
    return result;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray *visibleIndexes = [self.collectionView indexPathsForVisibleItems];
    NSInteger index1 = ((NSIndexPath *)visibleIndexes.firstObject).section;
    NSInteger index2 = ((NSIndexPath *)visibleIndexes.lastObject).section;

    if (index1 == index2) {
        [self.pageSelector setActiveSectionNumber:index1];
        self.sectionTitleLabel.text = [self categoryNameAtIndex:index1];
        return;
    }

    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ((NSIndexPath *)evaluatedObject).section == index1;
    }];
    NSArray *array = [visibleIndexes filteredArrayUsingPredicate:predicate];
    
    NSInteger resultSection = (array.count > (int)(visibleIndexes.count / 2)) ? index1 : index2;

    if (!self.bottomBar.hidden) {
        [self.pageSelector setActiveSectionNumber:resultSection];
    }
    
    self.sectionTitleLabel.text = [self categoryNameAtIndex:resultSection];
}


#pragma mark - Delete button gesture recognizers

- (void)deleteButtonTap:(UITapGestureRecognizer *)gestureRecognizer{
    [self.delegate deleteTap];
}

- (void)deleteButtonLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
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
    
    if ([self.backSpaceButton.gestureRecognizers containsObject:gestureRecognizer] && [self.backSpaceButton.gestureRecognizers containsObject:otherGestureRecognizer]) {
        return YES;
    } else if ([self.collectionView.gestureRecognizers containsObject:gestureRecognizer] && [self.collectionView.gestureRecognizers containsObject:otherGestureRecognizer]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - Actions

- (IBAction)functionButton:(id)sender {
    [self.delegate functionButton:sender];
}

- (IBAction)actionABCButton:(id)sender {
    [self functionButton:nil];
}

- (IBAction)actionSpaceButton:(id)sender {
    [self tryToInsertTextString:@" "];
}

- (IBAction)tapSearchButton:(id)sender {
    [self.delegate hideKeyboard];

    [self performSearchFieldSearch];
}


#pragma mark - EmojiPageSelectorDelegate

- (void)setActiveSection:(NSUInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    
    while ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section + 1];
        if (indexPath.section >= self.collectionView.numberOfSections) {
            return;
        }
    }
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    self.sectionTitleLabel.text = [self categoryNameAtIndex:section];
}

- (void)setTheme:(KBTheme)theme {
    BOOL needDark = NO;//(theme != KBThemeClassic);
    
    //self.view.backgroundColor = (needDark) ? RGB(37, 37, 37) : RGB(226, 229, 233);
    
    [self.popImage setImage:[UIImage imageNamedPod:(needDark) ? @"popBlack" : @"pop"]];
    [self.pageSelector setTheme:theme];
}


#pragma mark - GifStripeSelectionResponder

- (void)gifImageDidSelected {
    self.textField.text = nil;
    
    if (self.lastEnterIsEmoji) {
        [self.delegate deleteTap];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self performSearchFieldSearch];
    
    [textField resignFirstResponder];
    [self.delegate hideKeyboard];

    return YES;
}


#pragma mark - UITextFieldIndirectDelegate

- (void)textDidChangedForTextField:(UITextField *)textField {
    self.lastEnterIsEmoji = NO;
    
    [self performSearchFieldSearch];
}

- (UITextField *)forceFindSearchTextField {
    return self.textField;
}

@end

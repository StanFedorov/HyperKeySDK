//
//  ACKeyboardViewController.m
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/16/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#define AF_APP_EXTENSIONS

#import "HKKeyboardViewController.h"
#import "KeyboardViewControllerProtocolList.h"
#import "KeyboardLayoutManager.h"
#import "UIImage+Resize.h"
#import "AFNetworkReachabilityManager.h"
#import "GTViewController.h"
#import "MenuVC.h"
#import "MenuItemCollectionViewCell.h"
#import "AutoCorrectionView.h"
#import "AppsLineView.h"
#import "GifVC.h"
#import "DropBoxViewController.h"
#import "YelpVC.h"
#import "PhotoAlbumsVC.h"
#import "BaseVC.h"
#import "CustomCursorView.h"
#import "OverlayButtonTutorialView.h"
#import "Config.h"
#import "Macroses.h"
#import "KeyboardConfig.h"
#import "YoutubeVC.h"
#import "EmojiKeypadViewController.h"
#import "LocationVC.h"
#import "ReachabilityManager.h"
#import "KeyboardViewControllerProtocolList.h"
#import "KeyboardView.h"
#import "SwitchToEmoji.h"
#import "EmojiAPI.h"
#import "EmojiPanel.h"
#import <Masonry/Masonry.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "AuthView.h"
#import "SearchViewController.h"
#import <mach/mach.h>
#import "UIImage+Pod.h"

#import "ThemeChangesResponderProtocol.h"
#import "KeyboardThemesHelper.h"

#import "NSUserDefaults+Hyperkey.h"

@import AudioToolbox;

NSTimeInterval const kDeleteLongPressWaitInterval = 2.0; // Time for wait delete by words
NSTimeInterval const kDeletePreviousWordDelay = 0.3;

@interface HKKeyboardViewController () <UIGestureRecognizerDelegate, KeyboardContainerDelegate, OverlayButtonTutorialViewDelegate, GTTranslatorDelegate, AutoCorrectionViewDelegate, MenuItemPushDelegate, SwitchToEmojiDelegate, DirectInsertAndDeleteDelegate, KeyboardViewDelegate, KeyboardAppearingDelegate, HoverViewShowHideDelegate>

@property (assign, nonatomic) BOOL orientation;
@property (strong, nonatomic) NSString *undoBuffer;
@property (strong, nonatomic) NSString *redoBuffer;
@property (strong, nonatomic) NSArray *wordDeleteRoutine;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (assign, nonatomic) BOOL switchOffAutolayout;

@property (strong, nonatomic) KeyboardView *keyboardView;

@property (strong, nonatomic) NSRegularExpression *endOfSentenceRegularExpression;
@property (strong, nonatomic) NSRegularExpression *beginningOfSentenceRegularExpression;
@property (strong, nonatomic) NSRegularExpression *beginningOfWordRegularExpression;

@property (strong, nonatomic) MenuVC *menu;
@property (strong, nonatomic) AutoCorrectionView *autoCorrectionView;
@property (strong, nonatomic) AppsLineView *appsLineView;
@property (strong, nonatomic) SwitchToEmoji *switchToEmojiView;
@property (strong, nonatomic) EmojiPanel *emojiPanel;

@property (strong, nonatomic) UIViewController *selectedVC;
@property (strong, nonatomic) UINavigationController *selectedNavigationController;
@property (strong, nonatomic) KeyboardFeature *selectedFeature;

@property (strong, nonatomic) UISwipeGestureRecognizer *swipeUp;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipeDown;

@property (assign, nonatomic) BOOL isKeyboardTextFieldSelected;
@property (assign, nonatomic) BOOL isFullAccessGranted;
@property (assign, nonatomic) BOOL isFirxtTextDidChanged;

@property (strong, nonatomic) CustomCursorView *cursor;

@property (weak, nonatomic) OverlayButtonTutorialView *overlayButtonTutorialView;

@property (assign, nonatomic) BOOL eraserShouldDeleteWords;
@property (strong, nonatomic) NSTimer *eraserDeleteTimer;
@property (strong, nonatomic) NSTimer *eraserChangeSymbolToWordTimer;
@property (strong, nonatomic) NSTimer *eraserWordDeletionTickerTimer;

@property (assign, nonatomic) NSUInteger wordDeleteRoutineAmount;
@property (assign, nonatomic) NSUInteger wordDeleteRoutineStep;

@property (assign, nonatomic) BOOL requireWordSuggestions;
@property (assign, nonatomic) BOOL requireWordAutocorrections;
@property (assign, nonatomic) BOOL requireQuickPeriod;
@property (assign, nonatomic) BOOL requireAutoCapitalize;
@property (assign, nonatomic) BOOL requireKeyClickSounds;
@property (assign, nonatomic) BOOL requireQuickEmojiKey;
@property (assign, nonatomic) BOOL requireMainKeyboard;
@property (assign, nonatomic) BOOL requireEnglishExtensions;

@property (strong, nonatomic) NSTimer *checkKBThemeChangesTimer;
@property (assign, nonatomic) KBTheme currentKBTheme;

@property (strong, nonatomic) UIView *guideView;

@end

@implementation HKKeyboardViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self) {
        // Execute self.view.bounds.size here is failure for keyboard custom height
        [LayoutManager resetFrameWithSize:UIScreen.mainScreen.bounds.size];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        NSString *originalString = pasteboard.string;
        pasteboard.string = [[NSProcessInfo processInfo] globallyUniqueString];
        if (pasteboard.hasStrings) {
            if (originalString.length > 0) {
                pasteboard.string = originalString;
            }
            self.isFullAccessGranted = YES;
        } else{
            self.isFullAccessGranted = NO;
        }
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *cp = [fileManager containerURLForSecurityApplicationGroupIdentifier:kUserDefaultsSuiteName];
        NSError *error = nil;
        [fileManager contentsOfDirectoryAtPath:cp.path error:&error];
        
        self.isFullAccessGranted = (pasteboard != nil && [pasteboard isKindOfClass:[UIPasteboard class]] && !error);
    }
    
    self.keyboardView = [[KeyboardView alloc] init];
    self.keyboardView.delegate = self;
    self.keyboardView.isFullAccess = self.isFullAccessGranted;
    self.keyboardView.userInteractionEnabled = YES;
    [self.view addSubview:self.keyboardView];
    
    [LayoutManager setDelegate:self];
    
    self.selectedFeature = nil;
    LayoutManager.selectedFeature = self.selectedFeature;
    self.selectedVC = nil;
    self.selectedNavigationController = nil;
    
    [NSUserDefaults setupDefaultValues];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    // Load settings
    NSNumber *value = [userDefaults objectForKey:kUserDefaultsSettingWordSuggestions];
    self.requireWordSuggestions = (value && value.boolValue) ? YES : NO;
    
    value = [userDefaults objectForKey:kUserDefaultsSettingWordAutocorrections];
    self.requireWordAutocorrections = (value && value.boolValue) ? YES : NO;
    
    // TODO: Uncomment after bring localization
    /*self.requireEnglishExtensions = [userDefaults boolForKey:kUserDefaultsMainLangIsEnglish];
     if (!self.requireEnglishExtensions) {
     //autocorrection work only for english
     self.requireWordSuggestions = NO;
     self.requireWordAutocorrections = NO;
     }*/
    
    value = [userDefaults objectForKey:kUserDefaultsSettingQuickPeriod];
    self.requireQuickPeriod = (value && value.boolValue) ? YES : NO;
    
    value = [userDefaults objectForKey:kUserDefaultsSettingAutoCapitalize];
    self.requireAutoCapitalize = (value && value.boolValue) ? YES : NO;
    
    value = [userDefaults objectForKey:kUserDefaultsSettingKeyClickSounds];
    self.requireKeyClickSounds = (value && value.boolValue) ? YES : NO;
    
    value = [userDefaults objectForKey:kUserDefaultsSettingQuickEmojiKey];
    self.requireQuickEmojiKey = (value && value.boolValue) ? YES : NO;
    
    self.requireMainKeyboard = YES;
    
    //NSString *nibName = [NSString stringWithFormat:(self.requireMainKeyboard) ? @"bottomWide_%@" : @"bottom_%@", NSStringFromClass([MenuVC class])];
    
    //self.menu = [[MenuVC alloc] initWithNibName:nibName bundle:nil];
    //self.menu.delegate = self;
    //[self.view addSubview:self.menu.view];
    
    //  [self.menu.view mas_makeConstraints:^(MASConstraintMaker *make) {
    //  make.left.right.bottom.mas_equalTo(0);
    // make.height.mas_equalTo([LayoutManager menuHeight]);
    //}];
    
    if (self.requireWordSuggestions) {
        self.autoCorrectionView = [[[NSBundle bundleForClass:AutoCorrectionView.class] loadNibNamed:NSStringFromClass([AutoCorrectionView class]) owner:self options:nil] firstObject];
        self.autoCorrectionView.delegate = self;
        self.autoCorrectionView.isAutoCorrect = self.requireWordAutocorrections;
        self.autoCorrectionView.isAutoCapitalize = self.requireAutoCapitalize;
        self.autoCorrectionView.isFullAccess = self.isFullAccessGranted;
        
        self.autoCorrectionView.alpha = 0;
        
        [self.view addSubview:self.autoCorrectionView];
        [self.autoCorrectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(0);
            make.height.mas_equalTo([LayoutManager menuHeight]);
        }];
    } else {
        // Empty view for requireMainKeyboard without AutoCorrectionView
        self.autoCorrectionView = [[AutoCorrectionView alloc] init];
        
        if (self.requireQuickEmojiKey) {
            [self makeEmojiPanel];
            self.emojiPanel.view.alpha = 1;
            [self.emojiPanel loadEmoji];
        }
    }
    
    
    [self.view bringSubviewToFront:self.autoCorrectionView];
    
    self.appsLineView = [[[NSBundle bundleForClass:AppsLineView.class] loadNibNamed:NSStringFromClass([AppsLineView class]) owner:self options:nil] firstObject];
    [self.view addSubview:self.appsLineView];
    [self.appsLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo([LayoutManager menuHeight]);
    }];
    self.appsLineView.keyboardViewController = self;
    
    
    
    /*   if(![userDefaults objectForKey:@"firstLaunchCompleted"]) {
     self.introView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([IntroView class]) owner:self options:nil] objectAtIndex:0];
     self.introView.tag = 5544;
     self.introView.frame = self.view.bounds;
     [self.view addSubview:self.introView];
     [self.introView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.edges.mas_equalTo(0);
     }];
     [userDefaults setBool:YES forKey:@"firstLaunchCompleted"];
     [userDefaults synchronize];
     }*/
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(userDidSelectTextField) name:kSearchFieldDidTaped object:nil];
    [nc addObserver:self selector:@selector(userDidEndEditingTextField) name:kSearchFieldDidEndEditing object:nil];
    
    self.swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboardAsOverlay)];
    self.swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    self.swipeUp.delegate = self;
    [self.view addGestureRecognizer:self.swipeUp];
    
    self.swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHideKeyboard)];
    self.swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    self.swipeDown.delegate = self;
    [self.view addGestureRecognizer:self.swipeDown];
    
    NSNumber *objectValue = [userDefaults valueForKey:kUserDefaultsFullAccessGranted];
    BOOL storedAccessGranted = (!objectValue || !objectValue.boolValue) ? NO : YES;
    if (!objectValue || storedAccessGranted != self.isFullAccessGranted) {
        [userDefaults setBool:self.isFullAccessGranted forKey:kUserDefaultsFullAccessGranted];
        [userDefaults synchronize];
    }
    
    [self updateOverlayButtonImage];
    
    self.currentKBTheme = KBThemeClassic;
    //!!!: Hide themes lock KBThemeClassic
    //[userDefaults integerForKey:kUserDefaultsKeyboardTheme];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Here we'll know if we need to check KB theme changes
    if ([self.textDocumentProxy keyboardType] == UIKeyboardTypeWebSearch && [[self.textDocumentProxy documentContextBeforeInput] isEqualToString:kThemeSelectorText]) {
        [self startThemeTimer];
    }
    
    [self createHeightConstraint];
    
    if (self.isFullAccessGranted) {
        [EmojiAPI sharedAPI];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.isKeyboardTextFieldSelected = NO;
    
    //   HoverView *hoverView = [self.view viewWithTag:5531];
    //  if (hoverView) {
    //    [hoverView stopAnimation];
    //   [hoverView removeFromSuperview];
    //  }
    
    [self stopThemeTimer];
    
    [self removeAllControllersWichWeDontNeed];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    NSString *fullText = [[NSString alloc] init];
    NSString *strBeforeCursor = [self.textDocumentProxy documentContextBeforeInput];
    NSString *strAfterCursor = [self.textDocumentProxy documentContextAfterInput];
    if (strBeforeCursor == nil && strAfterCursor == nil) {
        fullText = @"";
    }
    if (strBeforeCursor != nil && strAfterCursor != nil) {
        fullText = [strBeforeCursor stringByAppendingString:strAfterCursor];
    }
    if (strBeforeCursor == nil) {
        fullText = strAfterCursor;
    }
    if (strAfterCursor == nil) {
        fullText = strBeforeCursor;
    }
    self.undoBuffer = fullText;
    
    if (self.isFullAccessGranted) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
            
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [self updateOverlayButtonImage];
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable:
                default:
                    self.keyboardView.overlayButton.image = [UIImage imageNamedPod:@"icon_kb_overlay_error"];
                    break;
            }
        }];
    } else {
        self.keyboardView.overlayButton.image = [UIImage imageNamedPod:@"icon_kb_overlay_error"];
    }
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    NSDate *blockDate = [defaults objectForKey:kUserDefaultsKeyboardShowedBeforeBlockDate];
    if (self.isFullAccessGranted && (!blockDate || [[NSDate date] timeIntervalSinceDate:blockDate] > 5)) {
        if (![defaults boolForKey:kUserDefaultsKeyboardTutorialShowedBefore]) {
            [defaults setBool:YES forKey:kUserDefaultsKeyboardTutorialShowedBefore];
            [defaults synchronize];
        }
    }

    if (self.requireMainKeyboard || [self isShowKeyboardForTextFieldType]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.autoCorrectionView setHidden:NO animation:YES];
        });
    }
    
    if(self.appsLineView.alpha != 0)
        [self.appsLineView initApps];
    
    if([defaults boolForKey:@"camFindCompleted"]) {
        [defaults setBool:YES forKey:kUserDefaultsCamfindClose];
        [defaults setBool:YES forKey:kUserDefaultsCamfindNewRecent];
        [defaults synchronize];
        KeyboardFeature *defaultFeature = [KeyboardFeature featureWithType:FeatureTypeCamFind];
        [self switchToFeature:defaultFeature];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Call first on rotation
- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (self.view.frame.size.width == 0 || self.view.frame.size.height == 0) {
        return;
    }
    
    if (!self.switchOffAutolayout) {
        [LayoutManager resetFrameWithSize:self.view.bounds.size];
        
        if (self.heightConstraint) {
            [self updateMainViewHeight];
        }
    }
}

// Call first after viewDidLoad
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [LayoutManager resetFrameWithSize:self.view.bounds.size];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Fix call-bar issue
    CGRect frame = self.view.superview.frame;
    CGFloat dy = CGRectGetMinY(frame);
    if (dy > 0.f) {
        frame.origin.y = 0.f;
        frame.size.height += dy;
        [self.view.superview setFrame:frame];
    }
    
    //If we add animation to next row - than we get creepy effect like moving buttons on recalculation
    [self calculateFramesForSize:self.view.frame.size];
    
    NSInteger appExtensionWidth = (NSInteger)round(self.view.frame.size.width);
    NSInteger possibleScreenWidthValue1 = (NSInteger)round(SCREEN_WIDTH);
    NSInteger possibleScreenWidthValue2 = (NSInteger)round(SCREEN_HEIGHT);
    
    NSInteger screenWidthValue;
    if (possibleScreenWidthValue1 < possibleScreenWidthValue2) {
        screenWidthValue = possibleScreenWidthValue1;
    } else {
        screenWidthValue = possibleScreenWidthValue2;
    }
    
    BOOL orientation = NO;
    if (appExtensionWidth == screenWidthValue) {
        orientation = YES;
    } else {
        orientation = NO;
    }
    
    if (IS_IPHONE && orientation != self.orientation) {
        switch (self.keyboardView.currentPad) {
            case KeyboardViewPadTypeLetter:
                [self.keyboardView createLetterPadPhone];
                break;
                
            case KeyboardViewPadTypeSymbol:
                [self.keyboardView changeNumberToSymbolPad];
                break;
                
            case KeyboardViewPadTypeNumber:
                [self.keyboardView changeSymbolToNumberPad];
                break;
                
            default:
                break;
        }
    }
    
    self.orientation = orientation;
    self.keyboardView.isPortraitOrientation = !self.orientation;
    
    [self.keyboardView.overlayButton setUserInteractionEnabled:YES];
    if (self.isFullAccessGranted) {
        if ([self.view viewWithTag:5531]) {
            [[self.view viewWithTag:5531] removeFromSuperview];
        }
    } else {
        if (![self.view viewWithTag:5531]) {
            [self addHoverView];
        }
        
        [self.view bringSubviewToFront:[self.view viewWithTag:5531]];
        [self.view bringSubviewToFront:self.keyboardView];
    }
}


#pragma mark - Keyboard Height

- (void)updateMainViewHeight {
    CGFloat height = [LayoutManager mainViewHeight];
    if (self.heightConstraint.constant != height) {
        for (NSLayoutConstraint *constraint in self.view.constraints) {
            if (constraint.firstItem == self.view && constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = height;
            }
        }
    }
}

- (void)updateMainViewHeightAmazon {
    CGFloat amazonHeight = [[UIScreen mainScreen] bounds].size.height * 0.6f;
    if (self.heightConstraint.constant != amazonHeight) {
        for (NSLayoutConstraint *constraint in self.view.constraints) {
            if (constraint.firstItem == self.view && constraint.firstAttribute == NSLayoutAttributeHeight) {
                constraint.constant = amazonHeight;
            }
        }
    }
}
- (void)createHeightConstraint {
    if (!self.heightConstraint) {
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:[LayoutManager mainViewHeight]];
        self.heightConstraint.priority = (UILayoutPriorityRequired - 1);
        [self.view addConstraint:self.heightConstraint];
        self.heightConstraint.constant = [LayoutManager mainViewHeight];
    } else {
        [self updateMainViewHeight];
    }
}


#pragma mark - Memory

- (void)reportMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kerr == KERN_SUCCESS) {
        NSLog(@"Memory in use (in bytes): %u", (unsigned int)(info.resident_size / 1000000));
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    [self performSelector:@selector(reportMemory) withObject:nil afterDelay:0.2];
}


#pragma mark - Property

- (NSArray *)wordDeleteRoutine {
    if (!_wordDeleteRoutine) {
        _wordDeleteRoutine = @[@{@"step": @(0), @"wordAmount": @(1), @"waitNextStep": @(1.5)},
                               @{@"step": @(1), @"wordAmount": @(2), @"waitNextStep": @(3.0)},
                               @{@"step": @(2), @"wordAmount": @(5), @"waitNextStep": @(3.0)},
                               @{@"step": @(2), @"wordAmount": @(10), @"waitNextStep": @(0)}];
    }
    return _wordDeleteRoutine;
}


#pragma mark - KeyboardAppearingDelegate

- (void)keyboardWasHidden:(BOOL)wasHidden {
    if (self.selectedVC) {
        if ([self.selectedVC isKindOfClass:[GTViewController class]]) {
            UIImage *bgImage = [UIImage imageNamedPod:wasHidden ? @"arrow_up" : @"arrow_down"];
            [((BaseVC *)self.selectedVC).iconButton setBackgroundImage:bgImage forState:UIControlStateNormal];
        }
        if (wasHidden){
            if ([self.selectedVC respondsToSelector:@selector(keyboardDidDisappear)]) {
                [self.selectedVC performSelector:@selector(keyboardDidDisappear)]; // Because notification kSearchFieldDidEndEditing does not work
            }
        }
    }
}


#pragma mark - Keyboard Appearing

// Only one method to show keyboard
- (void)showKeyboardAsOverlay {
    //if ([LayoutManager isKeyboardHidden]) {
    [LayoutManager setKeyboardHide:NO];
    
    
    BOOL needToshowFullHeight = self.isKeyboardTextFieldSelected || self.selectedFeature.type == FeatureTypeMinions || self.selectedFeature.type == FeatureTypeGoogleTranslate || self.requireWordSuggestions || self.requireQuickEmojiKey;
    
    BOOL canShowAutocorrections = self.requireWordSuggestions && !self.isKeyboardTextFieldSelected && self.selectedFeature.type != FeatureTypeMinions && self.selectedFeature.type != FeatureTypeGoogleTranslate;
    
    BOOL canShowEmojiPanel = self.requireQuickEmojiKey && !self.isKeyboardTextFieldSelected && self.selectedFeature.type != FeatureTypeMinions && self.selectedFeature.type != FeatureTypeGoogleTranslate;
    
    BOOL needTruncateMainView = !needToshowFullHeight;
    
    BOOL needToUpdateMainViewHeight = NO;
    if (needTruncateMainView != [LayoutManager isMainViewTruncate]) {
        [LayoutManager setMainViewTruncate:needTruncateMainView];
        needToUpdateMainViewHeight = YES;
    }
    
    if (!self.requireWordSuggestions && canShowEmojiPanel) {
        if (!self.emojiPanel) {
            [self makeEmojiPanel];
            [self.emojiPanel loadEmoji];
        }
        [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
            self.emojiPanel.view.alpha = 1;
        }];
    }
    
    void (^animateKeyboardBlock)(void) = ^{
        [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
            self.keyboardView.frame = [LayoutManager keyboardFrame];
        } completion:^(BOOL finished) {
            self.switchOffAutolayout = NO;
        }];
    };
    
    if (needToUpdateMainViewHeight) {
        self.switchOffAutolayout = YES;
        // TODO: Prevent flash-style animation on height change
        [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
            [self updateMainViewHeight];
        } completion:^(BOOL finished) {
            animateKeyboardBlock();
        }];
    } else {
        animateKeyboardBlock();
    }
    
    //  [self.menu setCoveredByHover:YES];
    
    if (self.requireWordSuggestions && canShowAutocorrections) {
        [self.autoCorrectionView setHidden:NO animation:YES];
        //      [self.view bringSubviewToFront:self.keyboardView];
        //        [self.view bringSubviewToFront:self.appsLineView];
        [self updateAutoCorrectionViewText];
        [self.view bringSubviewToFront:self.autoCorrectionView];
        [self.view bringSubviewToFront:self.keyboardView];
    }
    //  }
    
    [self updateSwipeEnable];
    [self updateControllers];
}

// TODO:delete it
- (void)swipeHideKeyboard {
    [self dictionaryPressed:nil];
}

- (void)showDefaultFeature {
    if (self.isFullAccessGranted) {
        KeyboardFeature *defaultFeature = [KeyboardFeature featureWithType:FeatureTypeEmojiKeypad];
        [self switchToFeature:defaultFeature];
    } else {
        [LayoutManager setKeyboardHide:YES];
        [self showKeyboardAsOverlay];
    }
}

- (void)addHoverView {
    AuthView *hover = [[[NSBundle bundleForClass:AuthView.class] loadNibNamed:NSStringFromClass([AuthView class]) owner:self options:nil] objectAtIndex:0];
    hover.tag = 5531;
    hover.frame = self.view.bounds;
    //   hover.delegate = self;
    [self.view addSubview:hover];
    
    [hover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    //    [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1];
    // [hover setupViewByType:HoverViewTypeNoAccess];
}

- (BOOL)isShowKeyboardForTextFieldType {
    switch (self.textDocumentProxy.returnKeyType) {
        case UIReturnKeySearch:
        case UIReturnKeyYahoo:
        case UIReturnKeyGoogle:
            return YES;
            
        default:
            return NO;
    }
}

- (void)updateOverlayButtonImage {
    NSString *imageName = nil;
    if (self.isFullAccessGranted) {
        imageName = @"kb_main_icon.png";
    } else {
        imageName = @"icon_kb_overlay_error.png";
    }
    
    if (imageName) {
        self.keyboardView.overlayButton.image = [UIImage imageNamedPod:imageName];
    }
}

// Tapping on Hyperkey-logo button on KB and swipe down
- (void)dictionaryPressed:(id)sender {
    if (self.requireQuickEmojiKey) {
        [self closeEmojiPanel];
    }
    
    if (!self.selectedVC && self.requireMainKeyboard) {
        [self showDefaultFeature];
        return;
    }
    
    //    [self.view bringSubviewToFront:self.menu.view];
    [self.view bringSubviewToFront:self.keyboardView];
    [self refreshAutocorrectionDataWithCleaning:YES];
    
    BOOL needToUpdateMainViewHeight = NO;
    if ([LayoutManager isMainViewTruncate]) {
        [LayoutManager setMainViewTruncate:NO];
        needToUpdateMainViewHeight = YES;
    }
    
    if(self.selectedFeature != nil && (self.selectedFeature.type == FeatureTypeAmazon || self.selectedFeature.type == FeatureTypeCamFind)) {
        needToUpdateMainViewHeight = YES;
        self.keyboardView.hidden = YES;
    }
    
    [LayoutManager setKeyboardHide:YES];
    
    [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
        self.keyboardView.frame = [LayoutManager keyboardFrame];
    } completion:^(BOOL finished) {
        self.switchOffAutolayout = NO;
        // TODO: Prevent flash-style animation on height change
        if (needToUpdateMainViewHeight) {
            self.switchOffAutolayout = YES;
            
            [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
                if(self.selectedFeature != nil && (self.selectedFeature.type == FeatureTypeAmazon || self.selectedFeature.type == FeatureTypeCamFind)) {
                    [self updateMainViewHeightAmazon];
                }else {
                    [self updateMainViewHeight];
                }
            } completion:^(BOOL finished) {
                self.switchOffAutolayout = NO;
            }];
        }
    }];
    
    if (self.autoCorrectionView) {
        [self.autoCorrectionView setHidden:YES animation:YES];
    }
    
    //    [self.menu setCoveredByHover:NO];
    
    [self userDidEndEditingTextField];
    
    [self updateSwipeEnable];
    [self updateControllers];
}

- (void)fixKb {
    
}

#pragma mark - HoverViewShowHideDelegate

- (void)userTapEmptySpace {
    if ([LayoutManager isKeyboardHidden]) {
        [self showKeyboard];
    } else {
        [self hideKeyboard];
    }
}

#pragma mark - OverlayButtonTutorialViewDelegate

- (void)overlayButtonTutorialViewDidActionOverlay {
    [self performSelector:@selector(overlayButtonTapped:) withObject:nil afterDelay:0.1];
}

- (void)overlayButtonTutorialViewDidActionSwipe {
    [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1];
}


#pragma mark - AutoCorrectionViewDelegate

- (void)autoCorrectionView:(AutoCorrectionView *)autoCorrectionView didSelectString:(NSString *)selectedString {
    NSString *curentText = self.textDocumentProxy.documentContextBeforeInput;
    NSUInteger length = curentText.length;
    if (length > 0 && [[NSCharacterSet characterSetWithCharactersInString:@".!?"] characterIsMember:[curentText characterAtIndex:length - 1]]) {
        [self.textDocumentProxy insertText:[NSString stringWithFormat:@" %@ ", selectedString]];
    } else {
        [self removeLastWordFromTextDocumentProxy];
        [self.textDocumentProxy insertText:[selectedString stringByAppendingString:@" "]];
    }
    
    [self updateAutoCorrectionViewText];
}

- (void)autoCorrectionView:(AutoCorrectionView *)autoCorrectionView didReplaceString:(NSString *)replaceString toString:(NSString *)toString {
    if (replaceString.length > 0 && toString.length > 0) {
        NSString *curentText = self.textDocumentProxy.documentContextBeforeInput;
        
        NSRange range = [curentText rangeOfString:replaceString options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString *afterText = nil;
            if ((range.location + range.length) < curentText.length) {
                afterText = [curentText substringFromIndex:range.location + range.length];
            }
            [self removeCharactersCountFromTextDocumentProxy:range.length + afterText.length];
            [self.textDocumentProxy insertText:toString];
            if (afterText.length > 0) {
                [self.textDocumentProxy insertText:afterText];
            }
            
            // Translate after replace
            [self tryToTranslateOnTheWay];
        }
    }
}

- (void)autoCorrectionView:(AutoCorrectionView *)autoCorrectionView didUpdateCorrectionString:(NSString *)correctionString {
    if (correctionString.length != 0) {
        [self.view bringSubviewToFront:self.autoCorrectionView];
        [self.view bringSubviewToFront:self.keyboardView];
        //  self.appsLineView.alpha = 0.0f;
    }
}


#pragma mark - KeyboardContainerDelegate

- (void)functionButton:(UIButton *)sender{
    // Unused. menu is always show
}

- (void)openMainAppFromFeatureType:(NSUInteger)featureType; {
    // by default we'll open app like tap on (+) menu item
    NSString *urlString = @"hyperkeyapp://addmenu";
    
    if (featureType == FeatureTypeGifCamera) {
        urlString = @"hyperkeyapp://gifCamera";
    } else if (featureType == FeatureTypeFeedFriends) {
        urlString = @"hyperkeyapp://facebookInvite";
    }
    
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:urlString]];
        }
    }
}

- (void)showKeyboard {
    // gif stripe on Emoji
    LayoutManager.selectedFeature = nil;
    self.keyboardView.hidden = NO;
    [LayoutManager setGifStripeShow:NO];
    [self updateMainViewHeight];
    [self showKeyboardAsOverlay];
}

- (void)clearTextFocus {
    if([self searchTextField] != nil) {
        [[self searchTextField] endEditing:YES];
        [[self searchTextField] resignFirstResponder];
    }
    self.isKeyboardTextFieldSelected = NO;
}

- (void)hideKeyboard {
    if (![LayoutManager isKeyboardHidden]) {
        
        [LayoutManager setKeyboardHide:YES];
        
        [self clearTextFocus];
        
        BOOL needToshowFullHeight = self.isKeyboardTextFieldSelected || self.selectedFeature.type == FeatureTypeMinions || self.selectedFeature.type == FeatureTypeGoogleTranslate || self.requireWordSuggestions || self.requireQuickEmojiKey;
        BOOL needToUpdateMainViewHeight = NO;
        if ((!needToshowFullHeight) != [LayoutManager isMainViewTruncate]) {
            [LayoutManager setMainViewTruncate:(!needToshowFullHeight)];
            needToUpdateMainViewHeight = YES;
        }
        
        AuthView *authView = [self.view viewWithTag:5531];
        if (authView) {
            [authView hideLine];
        }
        
        
        // self.appsLineView.alpha = 0.0f;
        // [self.menu setCoveredByHover:NO];
        [self.autoCorrectionView setHidden:YES animation:YES];
        
        [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
            self.keyboardView.frame = [LayoutManager keyboardFrame];
        } completion:^(BOOL finished) {
            self.switchOffAutolayout =  NO;
            
            // TODO: Prevent flash-style animation on height change
            if (needToUpdateMainViewHeight) {
                self.switchOffAutolayout = YES;
                [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
                    if(self.selectedFeature != nil && (self.selectedFeature.type == FeatureTypeAmazon || self.selectedFeature.type == FeatureTypeCamFind)) {
                        [self updateMainViewHeightAmazon];
                    }else {
                        [self updateMainViewHeight];
                    }
                } completion:^(BOOL finished) {
                    self.switchOffAutolayout = NO;
                }];
            }
        }];
        
        if((self.selectedFeature.type == FeatureTypeEmojiKeypad) && [self searchTextField] && self.cursor.superview ) {
            [self removeCursorFromView];
        }
        
        [self updateSwipeEnable];
        [self updateControllers];
    }
}

- (void)nextKeyboardAction {
    [self advanceToNextInputMode];
}

- (void)showRecentAction {
    static KeyboardFeature *recentShare;
    if (!recentShare) {
        recentShare = [KeyboardFeature featureWithType:FeatureTypeRecentShared];
    }
    
    [self switchToFeature:recentShare];
}

- (void)showFeedAction {
    static KeyboardFeature *feedAction;
    if (!feedAction) {
        feedAction = [KeyboardFeature featureWithType:FeatureTypeFeedFriends];
    }
    
    [self switchToFeature:feedAction];
}

- (void)keyboardContainerDidPrepareForInsertText {
    if (self.isKeyboardTextFieldSelected) {
        self.isKeyboardTextFieldSelected = NO;
        [self updateReturnButton];
        
        if (self.cursor) {
            [self removeCursorFromView];
        }
        [[self searchTextField] layer].borderWidth = 0.0;
    }
}

- (void)keyboardContainerDidInsertText:(NSString *)text {
    [self insertText:text];
}

- (void)keyboardContainerDidInsertKeyboardText:(NSString *)text {
    [self insertKeyboardText:text];
}

// TODO: Rename it
- (void)globeButtonAction:(id)sender {
    [self functionButton:sender];
}

- (void)refreshAutocorrectionDataWithCleaning:(BOOL)shouldClean {
    if (self.requireWordSuggestions && self.autoCorrectionView) {
        if ((self.selectedFeature.type != FeatureTypeGoogleTranslate) && (self.selectedFeature.type != FeatureTypeMinions)) {
            if (shouldClean) {
                [self.autoCorrectionView clearCorrectionData];
            } else {
                [self.autoCorrectionView createCorrectionData];
            }
        }
    }
}

- (void)removeAllControllersWichWeDontNeed {
    if ((self.selectedNavigationController) && (self.selectedNavigationController.view.superview)) {
        [self.selectedNavigationController.view removeFromSuperview];
    } else if ((self.selectedVC) && (self.selectedVC.view.superview)) {
        [self.selectedVC.view removeFromSuperview];
    }
    
    self.selectedVC = nil;
    self.selectedNavigationController = nil;
    self.selectedFeature = nil;
    LayoutManager.selectedFeature = self.selectedFeature;
}

- (void)userDidChangeController {
    self.isKeyboardTextFieldSelected = NO;
    if (self.cursor) {
        [self removeCursorFromView];
    }
    [[self searchTextField] layer].borderWidth = 0.0;
    [self updateReturnButton];
}


#pragma mark - Cursor view

- (void)addCursorToView {
    [self removeCursorFromView];
    
    if (!self.cursor) {
        //   CustomCursorView *cursorView = [[CustomCursorView alloc] initWithFrame:CGRectMake(4, 4, 2, [self searchTextField].frame.size.height - 8)];
        CustomCursorView *cursorView = [[CustomCursorView alloc] initWithFrame:CGRectMake(28, 4, 2, [self searchTextField].frame.size.height - 8)];
        self.cursor = cursorView;
    }
    
    [[self searchTextField] addSubview:self.cursor];
    [self setupCursorByText:[self searchTextField].text];
    [self.cursor startAnimation];
}

- (void)removeCursorFromView {
    [self.cursor stopAnimation];
    [self.cursor removeFromSuperview];
}

- (void)userDidSelectTextField {
    self.keyboardView.hidden = NO;
    self.isKeyboardTextFieldSelected = YES;
    [self addCursorToView];
    [self showKeyboardAsOverlay];
    [self updateReturnButton];
}

- (void)userDidEndEditingTextField {
    [[self searchTextField] endEditing:YES];
    [[self searchTextField] resignFirstResponder];
    [self removeCursorFromView];
    if (self.isKeyboardTextFieldSelected) {
        [self userDidChangeController];
    }
}

- (void)setupCursorByText:(NSString *)text {
    if ([self searchTextField]) {
        NSString *futureString = text;
        CGRect textRect = [self countFrameForTextInTextField:[self searchTextField] withFutureText:futureString];
        
        CGRect cursorFrame = self.cursor.frame;
        BOOL hasOffset = NO;
        CGFloat constantForTF = hasOffset ? 6 : 0;
        CGFloat constantForTF2 = hasOffset ? 12 : 6;
        cursorFrame.origin.x = 28 + textRect.size.width + constantForTF;
        if (textRect.size.width > [self searchTextField].frame.size.width - constantForTF2) {
            cursorFrame.origin.x = 28+ [self searchTextField].frame.size.width - constantForTF2;
        }
        self.cursor.frame = cursorFrame;
    }
}

- (CGRect)countFrameForTextInTextField:(UITextField *) textField withFutureText:(NSString *)futureText {
    return [futureText boundingRectWithSize:CGSizeMake(0, textField.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textField.font} context:nil];
}


#pragma mark - Controller Update

- (void)updateControllers {
    if (![LayoutManager isKeyboardHidden]) {
        if ([self.selectedVC isKindOfClass:[BaseVC class]]) {
            [(BaseVC *)self.selectedVC hideOverlayView];
        } else if ([self.selectedVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController *)self.selectedVC;
            if ([navigationController.visibleViewController isKindOfClass:[BaseVC class]]) {
                [(BaseVC *)navigationController.visibleViewController hideOverlayView];
            }
        }
    }
}

- (void)updateSwipeEnable {
    if (self.selectedVC && self.selectedFeature != nil && ((self.selectedFeature.type == FeatureTypeDrawImage) || (self.selectedFeature.type == FeatureTypeFacebook) || (self.selectedFeature.type == FeatureTypeInstagram)  || (self.selectedFeature.type == FeatureTypeCamFind)  || (self.selectedFeature.type == FeatureTypeAmazon) || (self.selectedFeature.type == FeatureTypePhotoLibrary))) {
        self.swipeUp.enabled = ![LayoutManager isKeyboardHidden];
        self.swipeDown.enabled = ![LayoutManager isKeyboardHidden];
    } else {
        self.swipeUp.enabled = YES;
        self.swipeDown.enabled = YES;
    }
}

- (void)calculateFramesForSize:(CGSize)size {
    CGRect frame = [LayoutManager keyboardFrame];
    self.keyboardView.frame = frame;
    [self.keyboardView recalculateFramesForSize:frame.size];
    
    if (self.overlayButtonTutorialView) {
        self.overlayButtonTutorialView.overlayButton.frame = [self.keyboardView convertRect:((IS_IPAD) ? self.keyboardView.padKeyboardMetrics.overlayButtonFrame : self.keyboardView.phoneKeyboardMetrics.overlayButtonFrame) toView:self.view];
        self.overlayButtonTutorialView.overlayButton.cornerRadius = self.keyboardView.cornerRadius;
    }
    
    [self layoutSwitchToEmoji];
}


#pragma mark - Regular Expressions

- (NSRegularExpression *)endOfSentenceRegularExpression {
    if (!_endOfSentenceRegularExpression) {
        NSError *error = nil;
        _endOfSentenceRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[a-z0-9] \\z" options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (!_endOfSentenceRegularExpression) {
            NSLog(@"Cannot create regular expression: %@", [error description]);
        }
    }
    return _endOfSentenceRegularExpression;
}

- (NSRegularExpression *)beginningOfSentenceRegularExpression {
    if (!_beginningOfSentenceRegularExpression) {
        NSError *error = nil;
        _beginningOfSentenceRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[.?!] \\s*$" options:0 error:&error];
        
        if (!_beginningOfSentenceRegularExpression) {
            NSLog(@"Cannot create regular expression: %@", [error description]);
        }
    }
    return _beginningOfSentenceRegularExpression;
}

- (NSRegularExpression *)beginningOfWordRegularExpression {
    if (!_beginningOfWordRegularExpression) {
        NSError* error = nil;
        _beginningOfWordRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"\\s+\\z" options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (!_beginningOfWordRegularExpression) {
            NSLog(@"Cannot create regular expression: %@", [error description]);
        }
    }
    return _beginningOfWordRegularExpression;
}


#pragma mark - UITextInputDelegate

- (void)textWillChange:(id<UITextInput>)textInput {
    self.isKeyboardTextFieldSelected = NO;
    if (self.cursor) {
        [self removeCursorFromView];
    }
    [[self searchTextField] layer].borderWidth = 0.0;
    
    [self updateReturnButton];
}

- (void)textDidChange:(id<UITextInput>)textInput {
    if (!self.isFirxtTextDidChanged) {
        self.isFirxtTextDidChanged = YES;
        
        if (self.requireMainKeyboard || [self isShowKeyboardForTextFieldType]) {
            [self.view bringSubviewToFront:self.keyboardView];
            [LayoutManager setKeyboardHide:NO];
        } else {
            [LayoutManager setKeyboardHide:YES];
            
            [self showDefaultFeature];
        }
    }
    
    [self updateReturnButton];
    [self updateShiftButtonState];
    [self updateAutoCorrectionViewText];
    [self updateAutoCorrectionViewTypes];
    [self.keyboardView updateFont];
    [self.keyboardView updateAppearance];
    
}


#pragma mark - Keys state

- (void)updateReturnButton {
    NSString *newTitle = nil;
    
    if (self.isKeyboardTextFieldSelected) {
        if ((self.selectedFeature.type == FeatureTypeMemeGenerator) || (self.selectedFeature.type == FeatureTypeDrawImage)) {
            newTitle = @"Ok";
        } else {
            newTitle = @"Search";
        }
    } else {
        switch (self.textDocumentProxy.returnKeyType) {
            case UIReturnKeyDefault:
            case UIReturnKeyDone:
                newTitle = @"return";
                break;
            case UIReturnKeyEmergencyCall:
                newTitle = @"Emergency Call";
                break;
            case UIReturnKeyGo:
                newTitle = @"Go";
                break;
            case UIReturnKeySearch:
            case UIReturnKeyGoogle:
            case UIReturnKeyYahoo:
                newTitle = @"Search";
                break;
            case UIReturnKeyJoin:
                newTitle = @"Join";
                break;
            case UIReturnKeyNext:
                newTitle = @"Next";
                break;
            case UIReturnKeyRoute:
                newTitle = @"Route";
                break;
            case UIReturnKeySend:
                newTitle = @"Send";
                break;
            default:
                break;
        }
    }
    
    [self.keyboardView updateReturnButtonTitle:newTitle];
}

- (void)updateShiftButtonState {
    if (self.keyboardView.leftShiftButton.isLocked) {
        return;
    }
    
    BOOL selected = NO;
    
    if (self.isKeyboardTextFieldSelected) {
        UITextField * searchField = [self searchTextField];
        
        if (searchField.text.length == 0) {
            selected = YES;
        }
    } else {
        NSString *beforeInput = self.textDocumentProxy.documentContextBeforeInput;
        
        switch (self.textDocumentProxy.autocapitalizationType) {
            case UITextAutocapitalizationTypeAllCharacters:
                selected = YES;
                break;
                
            case UITextAutocapitalizationTypeSentences:
                if (beforeInput.length == 0 || [[self.beginningOfSentenceRegularExpression matchesInString:beforeInput options:0 range:NSMakeRange(0, beforeInput.length)] count]) {
                    selected = YES;
                }
                break;
                
            case UITextAutocapitalizationTypeWords: {
                if (beforeInput.length == 0 || [[self.beginningOfWordRegularExpression matchesInString:beforeInput options:0 range:NSMakeRange(0, beforeInput.length)] count]) {
                    selected = YES;
                }
                break;
            }
                
            case UITextAutocapitalizationTypeNone:
            default:
                break;
        }
    }
    
    if (!self.requireAutoCapitalize) {
        selected = NO;
    }
    
    self.keyboardView.leftShiftButton.selected = selected;
    if (IS_IPAD) {
        self.keyboardView.rightShiftButton.selected = selected;
    }
    [self.keyboardView updateCapitalizationOfKeys];
}

- (void)updateAutoCorrectionViewText {
    if (!self.requireWordSuggestions) {
        return;
    }
    
    if (self.autoCorrectionView.alpha > 0) {
        self.autoCorrectionView.text = self.textDocumentProxy.documentContextBeforeInput;
    } else {
        self.autoCorrectionView.text = nil;
    }
}

- (void)updateAutoCorrectionViewTypes {
    if (!self.requireWordSuggestions) {
        return;
    }
    
    self.autoCorrectionView.isAutoCorrect = self.requireWordAutocorrections && self.textDocumentProxy.autocorrectionType != UITextAutocorrectionTypeNo;
}


#pragma mark - Text Actions

// Insert text without understanding to where
- (void)insertText:(NSString *)text {
    if (self.isKeyboardTextFieldSelected) {
        UITextField *searchField = [self searchTextField];
        
        if (searchField) {
            NSString *oldText = [searchField.text stringByAppendingString:text];
            [searchField setText:oldText];
            
            if (searchField.delegate && [searchField.delegate respondsToSelector:@selector(textDidChangedForTextField:)]) {
                // Here we notify view controller and delegate of searchField that text is changed
                [((BaseVC *)searchField.delegate) textDidChangedForTextField:searchField];
            }
            
            [self setupCursorByText:oldText];
            
            if(self.selectedFeature.type == FeatureTypeEmojiKeypad && ![LayoutManager isGifStripeShow]) {
                //    [LayoutManager setGifStripeShow:YES];
                //   [self updateMainViewHeight];
            }
        }
    } else {
        [self insertKeyboardText:text];
        
        // Here we check do we need translate or not
        [self checkForTranslation:text];
    }
    [self updateShiftButtonState];
    [self closeEmojiPanel];
}

// Insert text not in searchField
- (void)insertKeyboardText:(NSString *)text {
    NSString *before = self.textDocumentProxy.documentContextBeforeInput;
    
    if (self.requireQuickPeriod && before.length && [text isEqualToString:@" "] && ([[self.endOfSentenceRegularExpression matchesInString:before options:0 range:NSMakeRange(0, before.length)] count] > 0)) {
        [self.textDocumentProxy deleteBackward];
        [self.textDocumentProxy insertText:@"."];
    }
    
    if (self.requireWordSuggestions) {
        if ([self.autoCorrectionView checkNeedSeparateText:before withIsertedText:text]) {
            [self.autoCorrectionView addSeparate];
        }
        
        // NO REFACTOR! sequence is necessary
        [self.textDocumentProxy insertText:text];
        if (text.length == 1) {
            [self updateAutoCorrectionViewText];
        }
    } else {
        // NO REFACTOR!
        [self.textDocumentProxy insertText:text];
    }
}

- (void)removeLastWordFromTextDocumentProxy {
    NSString *text = [self.textDocumentProxy.documentContextBeforeInput copy];
    NSUInteger length = MAX(text.length - 1, 0);
    for (long i = length; i >= 0; i --) {
        unichar character = [text characterAtIndex:i];
        if (self.requireWordSuggestions && [self.autoCorrectionView.separatorCharacterSet characterIsMember:character]) {
            return;
        }
        
        [self.textDocumentProxy deleteBackward];
    }
}

- (void)removeCharactersCountFromTextDocumentProxy:(NSInteger)count {
    for (NSInteger i = 0; i < count; i++) {
        [self.textDocumentProxy deleteBackward];
    }
}

- (UITextField *)searchTextField {
    /*BaseVC *localSelectedVC;
     
     if (self.selectedVC) {
     if ([self.selectedVC isKindOfClass:[UINavigationController class]]) {
     NSArray *navStack = [(UINavigationController *)self.selectedVC viewControllers];
     localSelectedVC = [navStack lastObject];
     } else {
     localSelectedVC = (BaseVC *)self.selectedVC;
     }
     }
     
     if (localSelectedVC) {
     UITextField *searchField = localSelectedVC.searchTextField;
     searchField.layer.borderColor = [UIColor blueColor].CGColor;
     return searchField;
     }
     
     if (self.isKeyboardTextFieldSelected) {
     self.isKeyboardTextFieldSelected = NO;
     if (self.cursor) {
     [self removeCursorFromView];
     }
     [self updateReturnButton];
     }*/
    return self.appsLineView.search;
    //return nil;
}


#pragma mark - KeyboardViewDelegate

- (void)hidePressedPad {
    [self dismissKeyboard];
}

- (void)overlayButtonTapped:(id)sender {
    if (!self.isFullAccessGranted) {
        [self hideKeyboard];
        return;
    }
    [self userDidEndEditingTextField];
    if (self.requireWordSuggestions) {
        if (self.autoCorrectionView.alpha > 0 || self.emojiPanel) {
            [self closeEmojiPanel];
        } else {
            if (self.selectedVC) {
                [self dictionaryPressed:sender];
                return;
            } else {
                [self updateAutoCorrectionViewText];
            }
        }
        
        if (self.selectedVC) {
            [self dictionaryPressed:sender];
        } else {
            [self showDefaultFeature];
        }
    } else {
        [self dictionaryPressed:sender];
    }
}

- (void)letterButtonTappedWithText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertText:text];
    });
}

- (void)returnButtonTapped {
    if (self.isKeyboardTextFieldSelected) {
        if (([self.keyboardView.returnButton.title isEqualToString:@"Search"]) || (self.selectedFeature.type == FeatureTypeMemeGenerator) || (self.selectedFeature.type == FeatureTypeDrawImage) || (self.selectedFeature.type == FeatureTypeFrequentlyUsedPhrases)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kKeyboardNotificationActionSearchButton object:nil];
            if([self searchTextField] == self.appsLineView.search) {
                [self showSearch:[self searchTextField].text];
            }
            [self hideKeyboard];
        } else if ([self.keyboardView.returnButton.title isEqualToString:@"Save"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kKeyboardNotificationActionReturnButton object:nil];
        } else {
            self.isKeyboardTextFieldSelected = NO;
            if (self.cursor) {
                [self removeCursorFromView];
            }
            [[self searchTextField] layer].borderWidth = 0.0;
            [self updateReturnButton];
        }
    } else {
        [self insertText:@"\n"];
        [self textDidChange:nil];
    }
}

- (void)undoButtonTapped {
    [self playClick];
    
    NSString *fullText = [[NSString alloc] init];
    NSString *strBeforeCursor=[self.textDocumentProxy documentContextBeforeInput];
    NSString *strAfterCursor=[self.textDocumentProxy documentContextAfterInput];
    if (strBeforeCursor == nil && strAfterCursor == nil) {
        fullText = @"";
    }
    if (strBeforeCursor != nil && strAfterCursor != nil) {
        fullText = [strBeforeCursor stringByAppendingString:strAfterCursor];
    }
    if (strBeforeCursor == nil) {
        fullText = strAfterCursor;
    }
    if (strAfterCursor == nil) {
        fullText = strBeforeCursor;
    }
    self.redoBuffer = fullText;
    
    [self.textDocumentProxy insertText:self.undoBuffer];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // We can't know when text position adjustment is finished
        // Hack: Call this code after delay. In other case these changes won't be applied
        while (self.textDocumentProxy.documentContextBeforeInput.length > 0) {
            [self.textDocumentProxy deleteBackward];
        }
    });
    
    [self tryToTranslateOnTheWay];
}

- (void)redoButtonTapped {
    [self playClick];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // We can't know when text position adjustment is finished
        // Hack: Call this code after delay. In other case these changes won't be applied
        while (self.textDocumentProxy.documentContextBeforeInput.length > 0) {
            [self.textDocumentProxy deleteBackward];
        }
    });
    
    [self tryToTranslateOnTheWay];
}

- (void)playClick {
    if (self.requireKeyClickSounds) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            AudioServicesPlaySystemSound(1104);
        });
    }
}

- (void)setupNewNextKeyboardButton:(ACKey *)button {
    if (self.requireWordSuggestions && self.requireQuickEmojiKey) {
        button.imageView.image = [UIImage imageNamedPod:@"emoji"];
        [button addTarget:self action:@selector(tapEmojiButton) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapGlobeButton)];
        longPress.minimumPressDuration = 0.5;
        [button addGestureRecognizer:longPress];
    } else {
        [button addTarget:self action:@selector(nextKeyboardAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setupNewDeleteButton:(ACKey *)button {
    [self addGRToDeleteButton];
}


#pragma mark - GTTranslatorDelegate

- (void)changeOriginText:(NSString *)origin forTranslatedText:(NSString *)translated {
    if (((self.selectedFeature.type == FeatureTypeGoogleTranslate) && (((GTViewController *)self.selectedVC).isItTranslatedPasteboard))) {
        
        if (translated) {
            [self.textDocumentProxy insertText:translated];
        }
        return;
    }
    
    if (origin && translated && translated.length > 0) {
        NSString *beforeString = [self.textDocumentProxy documentContextBeforeInput];
        if (beforeString == nil) {
            beforeString = @"";
        }
        NSString *afterString = [self.textDocumentProxy documentContextAfterInput];
        if (afterString == nil) {
            afterString = @"";
        }
        NSMutableString *fullText = [NSMutableString stringWithString:beforeString];
        [fullText appendString:afterString];
        
        if (fullText.length) {
            NSString *result = [fullText stringByReplacingOccurrencesOfString:origin withString:translated];
            
            NSString *newOrigin;
            // Sometimes it happen when origin text not equal to full text
            // Try to clean origin from '\n' etc
            if ([fullText isEqualToString:result] || ![fullText containsString: origin]) {
                newOrigin = [origin stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                result = [fullText stringByReplacingOccurrencesOfString:newOrigin withString:translated];
            } else {
                newOrigin = origin;
            }
            
            if ([fullText containsString:newOrigin]) {
                // Need to change position
                if (![beforeString containsString:newOrigin]) {
                    if ([newOrigin containsString:afterString]) {
                        [self.textDocumentProxy adjustTextPositionByCharacterOffset:afterString.length];
                    } else {
                        [self.textDocumentProxy insertText:result];
                        return;
                    }
                }
                
                while (self.textDocumentProxy.documentContextBeforeInput.length > 0) {
                    [self.textDocumentProxy deleteBackward];
                }
                
                [self.textDocumentProxy insertText:result];
            }
        }
    }
}

- (void)checkForTranslation:(NSString *)text {
    if (self.selectedVC) {
        if ([self.selectedVC isKindOfClass:[GTViewController class]] && text && text.length) {
            [self tryToTranslateOnTheWay];
        }
    }
}

- (void)checkLanguageSelector {
    if (self.selectedFeature.type == FeatureTypeGoogleTranslate) {
        [(GTViewController *)self.selectedVC checkLanguageSelector];
    }
}

- (void)tryToTranslateOnTheWay {
    if (self.selectedFeature.type == FeatureTypeGoogleTranslate || self.selectedFeature.type == FeatureTypeMinions || [LayoutManager isGifStripeShow]) {
        NSString *fullText = [[NSString alloc] init];
        NSString *strBeforeCursor = [self.textDocumentProxy documentContextBeforeInput];
        NSString *strAfterCursor = [self.textDocumentProxy documentContextAfterInput];
        
        if (strBeforeCursor == nil && strAfterCursor == nil) {
            return;
        }
        if (strBeforeCursor != nil && strAfterCursor != nil) {
            fullText = [strBeforeCursor stringByAppendingString:strAfterCursor];
        }
        if (strBeforeCursor == nil) {
            fullText = strAfterCursor;
        }
        if (strAfterCursor == nil) {
            fullText = strBeforeCursor;
        }
        
        if ([self.selectedVC respondsToSelector:@selector(setOriginText:)]) {
            [(GTViewController *)self.selectedVC setOriginText:fullText];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kKeyboardNotificationActionUpdateText object:nil userInfo:@{@"text":fullText}];
    }
}


#pragma mark - Switch to emoji actions

- (void)layoutSwitchToEmoji {
    if (!self.switchToEmojiView) {
        return;
    }
    
    [self.switchToEmojiView layoutSwitchWithEmojiButtonFrame:self.keyboardView.nextKeyboardButton.frame animated:YES];
}

- (void)openSwitchToEmojiView {
    if (self.switchToEmojiView) {
        return;
    }
    
    self.switchToEmojiView = [[SwitchToEmoji alloc] initWithSuperViewFrame:self.keyboardView.bounds emojiButtonFrame:self.keyboardView.nextKeyboardButton.frame];
    self.switchToEmojiView.delegate = self;
    self.switchToEmojiView.alpha = 0;
    [self.keyboardView addSubview:self.switchToEmojiView];
    [self.keyboardView bringSubviewToFront:self.switchToEmojiView];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.switchToEmojiView.alpha = 1;
    }];
}


#pragma mark - SwitchToEmojiDelegate

- (void)tapGlobeButton {
    [self nextKeyboardAction];
}

- (void)tapEmojiButton {
    [self closeSwitchToEmojiView];
    
    if (self.emojiPanel) {
        [self closeEmojiPanel];
    } else {
        [self makeEmojiPanel];
        
        [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
            self.emojiPanel.view.alpha = 1;
        }];
        
        [self.emojiPanel loadEmoji];
    }
}

- (void)closeSwitchToEmojiView {
    if (self.switchToEmojiView) {
        [UIView transitionWithView:self.keyboardView duration:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.switchToEmojiView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.switchToEmojiView removeFromSuperview];
            self.switchToEmojiView = nil;
        }];
    }
}


#pragma mark - DirectInsertAndDeleteDelegate

- (void)insertTextStringToCurrentPosition:(NSString *)textString {
    // assume the GifStripe have to appear only after input something
    [LayoutManager setGifStripeShow:(self.selectedFeature.type == FeatureTypeEmojiKeypad)];
    [self updateMainViewHeight];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kKeyboardNotificationActionUpdateText object:nil userInfo:@{@"text":textString}];
    
    [self.textDocumentProxy insertText:textString];
}

- (void)deleteTap {
    [self backSpaceTap];
}

- (void)deleteLongTapBegin {
    [self backSpaceLongTapBegin];
}

- (void) deleteLongTapEnd {
    [self backSpaceLongTapEnd];
}


#pragma mark - Close from menu

- (void)needCloseEmojiView {
    [self closeSwitchToEmojiView];
}


#pragma mark - Add and remove

- (void)makeEmojiPanel {
    self.emojiPanel = [[EmojiPanel alloc] initWithNibName:NSStringFromClass([EmojiPanel class]) bundle:[NSBundle bundleForClass:EmojiPanel.class]];
    self.emojiPanel.delegate = self;
    [self.emojiPanel setTheme:self.currentKBTheme];
    self.emojiPanel.view.alpha = 0;
    
    [self.view addSubview:self.emojiPanel.view];
    [self.view bringSubviewToFront:self.emojiPanel.view];
    
    [self.emojiPanel.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo([LayoutManager menuHeight]);
    }];
    
    [self.autoCorrectionView setHidden:YES animation:YES];
}

- (void)closeEmojiPanel {
    if (self.emojiPanel) {
        [UIView animateWithDuration:kKeyboardMenuAnimationDuration animations:^{
            self.emojiPanel.view.alpha = 0;
            for (UIView *view in self.menu.view.subviews) {
                if ([view isKindOfClass:[UICollectionView class]]) {
                    view.alpha = 1;
                    break;
                }
            }
        } completion:^(BOOL finished) {
            [self.emojiPanel.view removeFromSuperview];
            self.emojiPanel = nil;
        }];
    }
    
    if (!self.isKeyboardTextFieldSelected) {
        [self.autoCorrectionView setHidden:NO animation:YES];
    }
}


#pragma mark - MenuItemPushDelegate

- (void)switchToFeatureFromApps:(KeyboardFeature*)item {
    if (!self.isFullAccessGranted) {
        [self hideKeyboard];
        return;
    }
    if (self.requireWordSuggestions) {
        if (self.autoCorrectionView.alpha > 0 || self.emojiPanel) {
            [self closeEmojiPanel];
        }
    }
    if(self.selectedFeature.type == item.type) {
        self.selectedFeature = nil;
        [self.autoCorrectionView setHidden:NO animation:YES];
        [self.view bringSubviewToFront:self.autoCorrectionView];
        [self showKeyboard];
        return;
    }
    [self switchToFeature:item];
}

- (void)switchToFeature:(KeyboardFeature *)item {
    if (item.type == FeatureTypeNone) {
        UIResponder *responder = self;
        while ((responder = [responder nextResponder]) != nil) {
            NSLog(@"Responder = %@", responder);
            if ([responder respondsToSelector:@selector(openURL:)] == YES) {
                [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"hyperkeyapp://addmenu"]];
            }
        }
    } else if (item.type == FeatureTypeAppURL) {
        [self.textDocumentProxy insertText:kAppShareText];
    } else {
        if ((self.selectedFeature) && ([self.selectedFeature isSameTo:item])) {
            NSLog(@"SelectedFeature: THE SAME");
        } else {
            [self userDidChangeController];
            [self removeAllControllersWichWeDontNeed];
            
            NSDictionary *classNamesForTypes = @{
                                                 @(FeatureTypeEmojiKeypad):           @"EmojiKeypadViewController",
                                                 @(FeatureTypeGif):                   @"GifVC",
                                                 @(FeatureTypeMojiSMPepsi):           @"MojiSMVC",
                                                 @(FeatureTypeMojiSMBurgerKing):      @"MojiSMVC",
                                                 @(FeatureTypeMojiSMDelish):          @"MojiSMVC",
                                                 @(FeatureTypeMojiSMHarpers):         @"MojiSMVC",
                                                 @(FeatureTypeMojiSMVodafone):        @"MojiSMVC",
                                                 @(FeatureTypeMojiSMCosmopolitan):    @"MojiSMVC",
                                                 @(FeatureTypeYelp):                  @"YelpVC",
                                                 @(FeatureTypeDropbox):               @"DropBoxViewController",
                                                 @(FeatureTypeGoogleDrive):           @"GoogleDriveViewController",
                                                 @(FeatureTypeInstagram):             @"InstagramViewController",
                                                 @(FeatureTypeFacebook):              @"FacebookVC",
                                                 @(FeatureTypeDrawImage):             @"DrawImageViewController",
                                                 @(FeatureTypeSpotify):               @"SpotifyViewController",
                                                 @(FeatureTypeGoogleTranslate):       @"GTViewController",
                                                 @(FeatureTypeShareLocation):         @"LocationVC",
                                                 @(FeatureTypePhotoLibrary):          @"PhotoAlbumsVC",
                                                 @(FeatureTypeYoutube):               @"YoutubeVC",
                                                 @(FeatureTypeEbay):                  @"EbayVC",
                                                 @(FeatureTypeMeme):                  @"MemePickerVC",
                                                 @(FeatureTypeMemeGenerator):         @"MemeGeneratorVC",
                                                 @(FeatureTypeMinions):               @"MinionsTranslateViewController",
                                                 @(FeatureTypeFrequentlyUsedPhrases): @"FrequentlyUsedPhrasesVC",
                                                 @(FeatureTypeSoundsCatalog):         @"SoundsCatalogViewController",
                                                 @(FeatureTypeRecentShared):          @"RecentSharedVC",
                                                 @(FeatureTypeFeedFriends):             @"FeedFriendsViewController",
                                                 @(FeatureTypeTwitch):                @"TwitchViewController",
                                                 @(FeatureTypeCamFind):                @"CamFindViewController",
                                                 @(FeatureTypeAmazon):                @"AmazonViewController",
                                                 @(FeatureTypeGifCamera):             @"GifCameraVC"
                                                 };
            
            NSString *className = [classNamesForTypes objectForKey:@(item.type)] ? [classNamesForTypes objectForKey:@(item.type)] : @"";
            
            //NSLog(@"itemType %lu, className : %@", (unsigned long)item.type, className);
            
            self.selectedFeature = item;
            LayoutManager.selectedFeature = self.selectedFeature;
            
            [LayoutManager setGifStripeShow:NO];
            if(self.selectedFeature != nil && (self.selectedFeature.type == FeatureTypeAmazon || self.selectedFeature.type == FeatureTypeCamFind)) {
                [self updateMainViewHeightAmazon];
            }else {
                [self updateMainViewHeight];
            }
            
            Class class = NSClassFromString(className);
            self.selectedVC = [[class alloc] initWithNibName:NSStringFromClass(class) bundle:[NSBundle bundleForClass:class]];
            
            if ([self.selectedVC isKindOfClass:[BaseVC class]]) {
                [(id)self.selectedVC setFeatureType:item.type];
                
                if ([self.selectedVC respondsToSelector:@selector(setFeatureTitle:dataSource:)]) {
                    [(id)self.selectedVC setFeatureTitle:item.title dataSource:item.dataSource];
                }
            }
            
            if ([self.selectedVC respondsToSelector:@selector(setDelegate:)]) {
                [self.selectedVC performSelector:@selector(setDelegate:) withObject:self];
            }
            
            if (self.selectedFeature.type == FeatureTypeSpotify || self.selectedFeature.type == FeatureTypeGoogleTranslate || self.selectedFeature.type == FeatureTypeMinions) {
                ((BaseVC *)self.selectedVC).iconButton.hidden = NO;
                
            } else if ((self.selectedFeature.type == FeatureTypeYelp) || (self.selectedFeature.type == FeatureTypeDropbox) || (self.selectedFeature.type == FeatureTypeGoogleDrive) || (self.selectedFeature.type == FeatureTypeAmazon) || (self.selectedFeature.type == FeatureTypeCamFind)) {
                self.selectedNavigationController = [[UINavigationController alloc] initWithRootViewController:self.selectedVC];
                [self.selectedNavigationController setNavigationBarHidden:YES];
                self.swipeUp.enabled = NO;
                self.swipeDown.enabled = NO;
            }
            
            if (self.selectedFeature.type == FeatureTypeYoutube) {
                [(YoutubeVC *)self.selectedVC setLastSearch:[self searchTextField].text];
            }
            if (self.selectedFeature.type == FeatureTypeYelp) {
                [(YelpVC *)self.selectedVC setLastSearch:[self searchTextField].text];
            }
            if (self.selectedFeature.type == FeatureTypeGif) {
                [(GifVC *)self.selectedVC setLastSearch:[self searchTextField].text];
            }
            if (self.selectedFeature.type == FeatureTypeDropbox) {
                [(DropBoxViewController *)self.selectedVC setLastSearch:[self searchTextField].text];
            }
            if (self.selectedFeature.type == FeatureTypeGoogleTranslate) {
                [(GTViewController *)self.selectedVC setLastSearch:[self searchTextField].text];
            }
            
            [self contentadViewAddSubview:(self.selectedNavigationController ? self.selectedNavigationController.view : self.selectedVC.view)];
            
            ((BaseVC *)self.selectedVC).iconButton.hidden = YES;
            
            if (self.selectedFeature.type == FeatureTypeGoogleTranslate || self.selectedFeature.type == FeatureTypeMinions) {
                /* NSString *fullText = [[NSString alloc] init];
                 NSString *strBeforeCursor = [self.textDocumentProxy documentContextBeforeInput];
                 NSString *strAfterCursor = [self.textDocumentProxy documentContextAfterInput];
                 if (strBeforeCursor == nil && strAfterCursor == nil) {
                 fullText = @"";
                 }
                 if (strBeforeCursor != nil && strAfterCursor != nil) {
                 fullText = [strBeforeCursor stringByAppendingString:strAfterCursor];
                 }
                 if (strBeforeCursor == nil) {
                 fullText = strAfterCursor;
                 }
                 if (strAfterCursor == nil) {
                 fullText = strBeforeCursor;
                 }*/
                
                //     if ([self.selectedVC respondsToSelector:@selector(setOriginText:)]) {
                //  [(GTViewController *)self.selectedVC setOriginText:fullText];
                // }
                
                //  [LayoutManager setKeyboardHide:YES];
                //[self showKeyboardAsOverlay];
                [self updateSwipeEnable];
                [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1];
            } else {
                [self updateSwipeEnable];
                [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1];
            }
        }
    }
    
    if(item.type == FeatureTypeAmazon || item.type == FeatureTypeCamFind) {
        self.keyboardView.hidden = YES;
        [self updateMainViewHeightAmazon];
    }else {
        self.keyboardView.hidden = NO;
        [self updateMainViewHeight];
    }
}

- (void)showSearch:(NSString*)searchQuery {
    if(self.selectedFeature.type == FeatureTypeGif) {
        GifVC *vc = (GifVC*)self.selectedVC;
        [vc loadItemsWithSearch:searchQuery];
    } else if(self.selectedFeature.type == FeatureTypeYelp) {
        YelpVC *vc = (YelpVC*)self.selectedVC;
        [vc performSearch:searchQuery];
    }else if(self.selectedFeature.type == FeatureTypeYoutube) {
        YoutubeVC *vc = (YoutubeVC*)self.selectedVC;
        [vc loadDataFromSearch:searchQuery];
    }else if(self.selectedFeature.type == FeatureTypeDropbox) {
        DropBoxViewController *vc = (DropBoxViewController*)self.selectedVC;
        [vc performSearch:searchQuery];
    }else if(self.selectedFeature.type == FeatureTypeGoogleTranslate) {
        GTViewController *vc = (GTViewController*)self.selectedVC;
        [vc performSearch:searchQuery];
    }else {
        [self userDidChangeController];
        [self removeAllControllersWichWeDontNeed];
        [self updateMainViewHeight];
        SearchViewController *svc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:[NSBundle bundleForClass:SearchViewController.class]];
        svc.keyboardViewController = self;
        svc.delegate = self;
        svc.searchQuery = searchQuery;
        self.selectedVC = svc;
        [self contentadViewAddSubview:(self.selectedNavigationController ? self.selectedNavigationController.view : self.selectedVC.view)];
        self.swipeUp.enabled = NO;
        self.swipeDown.enabled = NO;
    }
}

- (void)contentadViewAddSubview:(UIView *)subview {
    CGFloat menuHeight = [LayoutManager menuHeight];
    subview.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
    subview.clipsToBounds = YES;
    
    [self.view bringSubviewToFront:self.menu.view];
    [self.view addSubview:subview];
    [self.view bringSubviewToFront:self.keyboardView];
    
    [subview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.top.mas_equalTo(menuHeight);
    }];
}


#pragma mark - KB Themes

- (void)stopThemeTimer {
    [self.checkKBThemeChangesTimer invalidate];
    self.checkKBThemeChangesTimer = nil;
}

- (void)startThemeTimer {
    [self stopThemeTimer];
    
    self.checkKBThemeChangesTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkKBThemeChange) userInfo:nil repeats:YES];
}

- (void)checkKBThemeChange {
    KBTheme theme = KBThemeClassic;
    //!!!: Hide themes lock KBThemeClassic
    //NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    //KBTheme theme = ((NSNumber *)[userDefaults objectForKey:kUserDefaultsKeyboardTheme]).integerValue;
    
    if (theme != self.currentKBTheme) {
        self.currentKBTheme = theme;
    }
}

- (void)setCurrentKBTheme:(KBTheme)newKBTheme {
    _currentKBTheme = newKBTheme;
    
    [((id<ThemeChangesResponderProtocol>)self.keyboardView) setTheme:_currentKBTheme];
    
    [self updateReturnButton];
    
    [((id<ThemeChangesResponderProtocol>)self.menu) setTheme:_currentKBTheme];
    [((id<ThemeChangesResponderProtocol>)self.autoCorrectionView) setTheme:_currentKBTheme];
    [((id<ThemeChangesResponderProtocol>)self.emojiPanel) setTheme:_currentKBTheme];
    
    // Emoji - avoid to update appearance after update image
    
    NSString *emojiImageName;
    switch (self.currentKBTheme) {
        case KBThemeClassic:
        case KBThemeTransparent:
            emojiImageName = @"emoji_light";
            break;
            
        case KBThemeOriginal:
            emojiImageName = @"emoji";
            break;
            
        default:
            break;
    }
    
    self.keyboardView.nextKeyboardButton.image = [UIImage imageNamedPod:(self.requireWordSuggestions && self.requireQuickEmojiKey) ? emojiImageName : @"global_portrait"];
    self.view.backgroundColor = colorBackgroundForTheme(self.currentKBTheme);
    
    if (self.selectedFeature.type == FeatureTypeEmojiKeypad) {
        [((id<ThemeChangesResponderProtocol>)(self.selectedVC)) setTheme:_currentKBTheme];
    }
}

- (void)showGuide {
    // No need to show guides when we change theme
    if (self.checkKBThemeChangesTimer) {
        return;
    }
}

- (void)hideGuide {
    self.menu.isKeyboardBlockedByTutorial = NO;
}

#pragma mark - Eraser section

- (void)backSpaceTap {
    [self playClick];
    [self deleteBackward];
}

- (void)backSpaceLongTapBegin {
    [self deleteByASymbolTimerStart];
    [self changeSymbolToWordTimerStart];
}

- (void)backSpaceLongTapEnd {
    [self deleteByASymbolTimerStop];
    [self changeSymbolToWordTimerStop];
    [self deleteByWordTimerStop];
}

- (void)addGRToDeleteButton {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backSpaceTap)];
    [self.keyboardView.deleteButton addGestureRecognizer:tapGestureRecognizer];
    
    UILongPressGestureRecognizer *touchUpGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteButtonLongTap:)];
    touchUpGestureRecognizer.minimumPressDuration = kKeyboardDeleteOneCharacterTimerInterval;
    touchUpGestureRecognizer.numberOfTouchesRequired = 1;
    touchUpGestureRecognizer.delegate = self;
    [self.keyboardView.deleteButton addGestureRecognizer:touchUpGestureRecognizer];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([self.keyboardView.deleteButton.gestureRecognizers containsObject:gestureRecognizer] && [self.keyboardView.deleteButton.gestureRecognizers containsObject:otherGestureRecognizer]) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - BackSpace gesture recognizers

- (void)deleteButtonLongTap:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self backSpaceLongTapBegin];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self backSpaceLongTapEnd];
    }
}


#pragma mark - Timers section

- (void)changeDeleteProcessFromSymbolToWord {
    [self deleteByASymbolTimerStop];
    [self deleteByWordTimerStart];
}

- (void)deleteByASymbolTimerStart {
    self.eraserDeleteTimer = [NSTimer scheduledTimerWithTimeInterval:kKeyboardDeleteOneCharacterTimerInterval target:self selector:@selector(backSpaceTap) userInfo:nil repeats:YES];
}

- (void)deleteByASymbolTimerStop {
    [self.eraserDeleteTimer invalidate];
    self.eraserDeleteTimer = nil;
    
    [self tryToTranslateOnTheWay];
}

- (void)changeSymbolToWordTimerStart {
    self.eraserChangeSymbolToWordTimer = [NSTimer scheduledTimerWithTimeInterval:kDeleteLongPressWaitInterval target:self selector:@selector(changeDeleteProcessFromSymbolToWord) userInfo:nil repeats:NO];
}

- (void)changeSymbolToWordTimerStop {
    self.eraserShouldDeleteWords = NO;
    [self.eraserChangeSymbolToWordTimer invalidate];
    self.eraserChangeSymbolToWordTimer = nil;
}

- (void)deleteByWordTimerStart {
    self.eraserShouldDeleteWords = YES;
    
    self.wordDeleteRoutineStep = 0;
    [self checkWordDeleteRoutine];
    
    self.eraserWordDeletionTickerTimer = [NSTimer scheduledTimerWithTimeInterval:kDeletePreviousWordDelay target:self selector:@selector(deletePreviousWord) userInfo:nil repeats:YES];
}

- (void)deleteByWordTimerStop {
    self.eraserShouldDeleteWords = NO;
    [self.eraserWordDeletionTickerTimer invalidate];
    self.eraserWordDeletionTickerTimer = nil;
    
    [self tryToTranslateOnTheWay];
}


#pragma mark - Private with text

- (void)deleteBackward {
    if (!self.eraserShouldDeleteWords) {
        if (self.isKeyboardTextFieldSelected) {
            UITextField *searchField = [self searchTextField];
            
            if (searchField) {
                NSString *oldText = searchField.text;
                if (oldText.length > 0) {
                    oldText = [oldText substringToIndex:[oldText length] - 1];
                }
                [searchField setText:oldText];
                
                if (searchField.delegate && [searchField.delegate respondsToSelector:@selector(textDidChangedForTextField:)]) {
                    // Here we notify view controller and delegate of searchField that text is changed
                    [((BaseVC *)searchField.delegate) textDidChangedForTextField:searchField];
                }
                
                [self setupCursorByText:oldText];
            }
        } else {
            [self.textDocumentProxy deleteBackward];
            [self updateAutoCorrectionViewText];
            [self checkAreWeHaveMoreTextInInput];
        }
    }
    [self updateShiftButtonState];
}

- (void)checkWordDeleteRoutine {
    if (self.eraserShouldDeleteWords) {
        if (self.wordDeleteRoutineStep >= [self.wordDeleteRoutine count]) {
            return;
        }
        
        NSDictionary *dict = [self.wordDeleteRoutine objectAtIndex:self.wordDeleteRoutineStep];
        
        self.wordDeleteRoutineAmount = ((NSNumber *)[dict objectForKey:@"wordAmount"]).integerValue;
        self.wordDeleteRoutineStep += 1;
        
        if (self.wordDeleteRoutineStep <= (self.wordDeleteRoutine.count - 1)) {
            NSUInteger waitInterval = ((NSNumber *)[dict objectForKey:@"waitNextStep"]).integerValue;
            
            [self performSelector:@selector(checkWordDeleteRoutine) withObject:nil afterDelay:waitInterval];
        }
    } else {
        self.wordDeleteRoutineStep = 0;
        self.wordDeleteRoutineAmount = 1;
    }
}

- (void)deletePreviousWord {
    [self playClick];
    
    NSString *before;
    if (self.isKeyboardTextFieldSelected) {
        before = [self searchTextField].text;
    } else {
        before = [self.textDocumentProxy documentContextBeforeInput];
    }
    
    if (before && before.length) {
        NSArray *array = [before componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",.;- "]];
        
        NSUInteger amountOfSymbolsToDelete = 0;
        if (array.count <= self.wordDeleteRoutineAmount) {
            amountOfSymbolsToDelete = before.length;
        } else {
            if (((NSInteger)(self.wordDeleteRoutineAmount) - 1) >= 0) {
                amountOfSymbolsToDelete = self.wordDeleteRoutineAmount - 1;
            }
            
            for (int i = 0; i < self.wordDeleteRoutineAmount; i ++) {
                before = [array objectAtIndex:i];
                amountOfSymbolsToDelete += before.length;
            }
        }
        
        if (self.isKeyboardTextFieldSelected) {
            before = [self searchTextField].text;
            before = [before substringToIndex:(before.length - amountOfSymbolsToDelete)];
            [self searchTextField].text = before;
            [self setupCursorByText:before];
        } else {
            for (int i = 0; i <= amountOfSymbolsToDelete; i++) {
                [self.textDocumentProxy deleteBackward];
            }
        }
    } else {
        if (self.isKeyboardTextFieldSelected) {
            [self searchTextField].text = @"";
        } else {
            [self.textDocumentProxy deleteBackward];
        }
    }
    [self updateShiftButtonState];
    [self checkAreWeHaveMoreTextInInput];
}

- (void)checkAreWeHaveMoreTextInInput {
    BOOL textDidEnd = NO;
    if (self.isKeyboardTextFieldSelected) {
        textDidEnd = ([self searchTextField].text.length == 0) ? YES : NO;
    } else {
        textDidEnd = ![self.textDocumentProxy hasText];
    }
    
    if (textDidEnd && [self.selectedVC respondsToSelector:@selector(textInInputDidEnd)]) {
        [self.selectedVC performSelector:@selector(textInInputDidEnd)];
    }
    
    [self tryToTranslateOnTheWay];
}

@end

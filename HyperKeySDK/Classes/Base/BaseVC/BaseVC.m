//
//  testVC.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 06.10.15.
//
//

#import "BaseVC.h"

#import "DropBoxViewController.h"
#import "FourthTutorialView.h"
#import "Config.h"
#import "Masonry.h"
#import "Macroses.h"
#import "NetworkManager.h"
#import "KeyboardFeature.h"

NSString *const kSearchFieldDidTaped = @"kSearchFieldDidTaped";
NSString *const kSearchFieldDidEndEditing = @"kSearchDidEndEditing";

CGFloat const kSeeThroughSearchBarContentTopOffset = 40;

NSString *const kSearchFieldEnabledKeyPath = @"enabled";

NSTimeInterval kBaseVCActionShowDuration = 0.9;
NSTimeInterval kBaseVCActionHideDuration = 0.5;

@interface BaseVC ()

@property (weak, nonatomic) HoverView *noResultHoverView;
@property (weak, nonatomic) ActionView *actionView;

@end

@implementation BaseVC

- (void)dealloc {
    [self removeTextFieldObsever];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self lookForSearchField];
    [self addHoverView];
}


#pragma mark - Property

- (void)setSearchTextField:(UITextField *)searchTextField {
    if (_searchTextField != searchTextField) {
        if (_searchTextField) {
            [self removeTextFieldObsever];
        }
        _searchTextField = searchTextField;
        
        [self addTextFieldObserver];
    }
}

- (BOOL)actionAnimated {
    return (self.actionView && self.actionView.isAnimating);
}


#pragma mark - Public

- (void)lookForSearchField {
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            self.searchTextField = (UITextField *)subView;
            self.searchTextField.delegate = self;
        }
    }
    
    // TODO: Clean it please, I have no idea why everything you see on top is require
    // Below is work if your UITextField stay on non-first intendation level
    if (!self.searchTextField && [self respondsToSelector:@selector(forceFindSearchTextField)]) {
        self.searchTextField = [self forceFindSearchTextField];
        self.searchTextField.delegate = self;
    }
}

- (void)setFeatureTitle:(NSString *)title dataSource:(NSString *)dataSource {
    // Owerride
}

- (void)insertBranchLinkFromMInsertData:(MInsertData *)insertData completion:(void (^)(NSString *link))completion {
    if ([self.delegate respondsToSelector:@selector(keyboardContainerDidPrepareForInsertText)]) {
        [self.delegate keyboardContainerDidPrepareForInsertText];
    }
    
   /* [BranchLinksAPI createBranchDeepLinkWithParametrs:insertData andCompletion:^(NSString * _Nullable deepLink) {
#if DEBUG == 1 || BETA == 1
        NSLog(@"deep link = %@\n\n", deepLink);
#endif
        
        if (!deepLink || deepLink.length <= 0) {
            return ;
        }
        
        NSString *title = insertData.useDescription ? insertData.title : nil;
        
        [self insertLinkWithURLString:deepLink title:title featureType:insertData.featureType completion:^(NSString *link) {
            if (completion) {
                completion(link);
            }
        }];
    }];*/
}

- (void)insertLinkWithURLString:(NSString *)urlString title:(NSString *)title featureType:(FeatureType)featureType{
    if ([self.delegate respondsToSelector:@selector(keyboardContainerDidPrepareForInsertText)]) {
        [self.delegate keyboardContainerDidPrepareForInsertText];
    }
    
    NSString *text = @"";
    KeyboardFeature *feature = [KeyboardFeature featureWithType:self.featureType];
    if (feature.title && feature.title > 0) {
        text = [text stringByAppendingFormat:@"%@ ", feature.title];
    }
    if (title && title.length > 0) {
        text = [text stringByAppendingFormat:@"%@ ", title];
    }
    text = [text stringByAppendingString:urlString];
    
    if ([self.delegate respondsToSelector:@selector(keyboardContainerDidInsertText:)]) {
        [self.delegate keyboardContainerDidInsertText:text];
    }
}


- (void)insertLinkWithURLString:(NSString *)urlString title:(NSString *)title featureType:(FeatureType)featureType completion:(void (^)(NSString *link))completion {
    if ([self.delegate respondsToSelector:@selector(keyboardContainerDidPrepareForInsertText)]) {
        [self.delegate keyboardContainerDidPrepareForInsertText];
    }
    
    NetworkManager *shortUrlsManager = [[NetworkManager alloc] init];
    [shortUrlsManager getShortURLByLongURLString:urlString withCompletion:^(id object, NSError *error) {
        if (object) {
            NSString *text = @"";
            KeyboardFeature *feature = [KeyboardFeature featureWithType:self.featureType];
            
            if (feature.title && feature.title > 0 && feature.type != FeatureTypeAmazon && feature.type != FeatureTypeCamFind) {
                text = [text stringByAppendingFormat:@"%@ ", feature.title];
            }
            if (title && title.length > 0) {
                text = [text stringByAppendingFormat:@"%@ ", title];
            }
            text = [text stringByAppendingString:object];
            
            if ([self.delegate respondsToSelector:@selector(keyboardContainerDidInsertText:)]) {
                [self.delegate keyboardContainerDidInsertText:text];
            }
            
        }
        
        if (completion) {
            completion(object);
        }
    }];
}

- (void)addHoverView {
    HoverView *hover = [[[NSBundle bundleForClass:HoverView.class] loadNibNamed:NSStringFromClass([HoverView class]) owner:self options:nil] objectAtIndex:0];
    hover.delegate = self;
    hover.frame = self.view.bounds;
    [self.view addSubview:hover];
    
    [hover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.hoverView = hover;
    self.hoverView.hidden = YES;
}


- (void)showNoResultHoverViewAboveSubview:(UIView *)subview {
    if (self.noResultHoverView || !subview) {
        return;
    }
    
    HoverView *hoverView = [[[NSBundle bundleForClass:HoverView.class] loadNibNamed:NSStringFromClass([HoverView class]) owner:self options:nil] objectAtIndex:0];
    hoverView.frame = subview.bounds;
    [self.view insertSubview:hoverView aboveSubview:subview];
    [hoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [hoverView setupViewByType:HoverViewTypeNoResults];
    
    self.noResultHoverView = hoverView;
}

- (void)hideNoResultHoverView {
    if (self.noResultHoverView) {
        [self.noResultHoverView removeFromSuperview];
    }
}

- (void)setupHoverViewByType:(HoverViewType)hoverType {
    [self.hoverView setupViewByType:hoverType];
    
    self.hoverView.hidden = NO;
    [self.view bringSubviewToFront:self.hoverView];
    
    if (self.iconButton) {
        [self.view bringSubviewToFront:self.iconButton];
    }
}

- (void)hideHoverView {
    self.hoverView.iconImageView.image = nil;
    self.hoverView.hidden = YES;
}

- (void)hideOverlayView {
    if (self.fourthTutorialView) {
        [self.fourthTutorialView removeFromSuperview];
    }
}

- (void)showFourthTutorialWithObjectName:(NSString *)objectName {
    NSString *showedKey = [kUserDefaultsKeyboardFourthTutorialShowedBefore stringByAppendingString:NSStringFromClass([self class])];
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    if ([userDefaults boolForKey:kUserDefaultsKeyboardTutorialShowedBefore] && ![userDefaults boolForKey:showedKey]) {
        FourthTutorialView *tutorialView = [[[NSBundle bundleForClass:FourthTutorialView.class] loadNibNamed:NSStringFromClass([FourthTutorialView class]) owner:self options:nil] firstObject];
        tutorialView.objectName = objectName;
        tutorialView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
        [self.view addSubview:tutorialView];
        
        self.fourthTutorialView = tutorialView;
        
        [userDefaults setBool:YES forKey:showedKey];
        [userDefaults synchronize];
    }
}


#pragma mark - Observer

- (void)addTextFieldObserver {
    [self.searchTextField addObserver:self forKeyPath:kSearchFieldEnabledKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeTextFieldObsever {
    [self.searchTextField removeObserver:self forKeyPath:kSearchFieldEnabledKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kSearchFieldEnabledKeyPath] && object == self.searchTextField) {
        if (!self.searchTextField.enabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSearchFieldDidEndEditing object:nil userInfo:nil];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchFieldDidTaped object:nil userInfo:nil];
    return NO;
}


#pragma mark - Action Animation

- (void)addActionAnimationToView:(UIView *)view type:(ActionViewType)type {
    [self addActionAnimationToView:view contentView:view type:type options:0];
}

- (void)addActionAnimationToView:(UIView *)view type:(ActionViewType)type options:(ActionViewOptions)options {
    [self addActionAnimationToView:view contentView:view type:type options:options];
}

- (void)addActionAnimationToView:(UIView *)view contentView:(UIView *)contentView type:(ActionViewType)type options:(ActionViewOptions)options {
    [self removeActionAnimation];
    
    view.layer.masksToBounds = YES;
    
    NSTimeInterval showDuration = kBaseVCActionShowDuration;
    NSTimeInterval hideDuration = kBaseVCActionHideDuration;
    
    ActionView *actionView = [[[NSBundle bundleForClass:ActionView.class] loadNibNamed:NSStringFromClass([ActionView class]) owner:self options:nil] firstObject];
    actionView.type = type;
    actionView.options = options;
    [view addSubview:actionView];
    [actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [view layoutIfNeeded];
    
    self.actionView = actionView;
    
    [UIView animateKeyframesWithDuration:showDuration * 0.5 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            contentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            contentView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    } completion:nil];
    
    if (actionView.options & ActionViewOptionsProgress) {
        [actionView prepareShowAnimation];
    } else {
        __weak __typeof(self)weakSelf = self;
        [actionView startShowAnimationWithDuration:showDuration * 0.7 delay:showDuration * 0.2 completion:^(BOOL finished) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                if (!(actionView.options & ActionViewOptionsWithoutRemoving)) {
                    if (finished) {
                        [actionView startHideAnimationsWithDuration:hideDuration * 0.4 delay:hideDuration * 0.6 completion:nil];
                    } else {
                        [strongSelf removeActionAnimation];
                    }
                }
            }
        }];
    }
}

- (void)updateActionAnimationProgress:(CGFloat)progress {
    if (self.actionView && self.actionView.options & ActionViewOptionsProgress && self.actionView.isAnimating) {
        [self.actionView updateShowAnimationProgress:progress];
        
        if (progress >= 1) {
            if (!(self.actionView.options & ActionViewOptionsWithoutRemoving)) {
                NSTimeInterval hideDuration = kBaseVCActionHideDuration;
                
                [self.actionView startHideAnimationsWithDuration:hideDuration * 0.4 delay:hideDuration * 0.6 completion:nil];
            }
        }
    }
}

- (void)removeActionAnimation {
    if (self.actionView) {
        [self.actionView removeFromSuperview];
    }
}

@end

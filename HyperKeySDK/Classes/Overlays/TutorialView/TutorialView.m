//
//  TutorialView.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "TutorialView.h"

#import "MenuVC.h"
#import "Macroses.h"
#import "Masonry.h"
#import "UIFont+Hyperkey.h"

CGFloat const kTutorialViewArrowAnimationOffset = 5;
CGFloat const kTutorialViewArrowAnimationDuration = 0.3;
CGFloat const kTutorialViewButtonsAnimationDuration = 0.5;

@interface TutorialView () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *tutorialScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIView *thirdView;
@property (weak, nonatomic) IBOutlet UILabel *secondViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdViewLabel;

@property (weak, nonatomic) IBOutlet UIView *rightArrowView;
@property (weak, nonatomic) IBOutlet UIView *upArrowView;
@property (weak, nonatomic) IBOutlet UIView *upArrowContentView;

@property (strong, nonatomic) MenuVC *secondMenu;
@property (strong, nonatomic) MenuVC *thirdMenu;

@end

@implementation TutorialView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.secondViewLabel.font = [UIFont helveticaNeueFontOfSize:IS_IPHONE_5 ? 18 : 20];
    self.thirdViewLabel.font = [UIFont helveticaNeueFontOfSize:IS_IPHONE_5 ? 18 : 20];
    
    NSString *text = @"Many apps let you search and share. Tap Giphy for animated images.";
    NSRange range = [text rangeOfString:@"Giphy"];
    [self setupText:text forLabel:self.thirdViewLabel range:range];
    
    self.secondMenu = [self addMenuToView:self.secondView];
    self.secondMenu.view.alpha = 0;
    self.secondMenu.view.userInteractionEnabled = NO;
    
    self.thirdMenu = [self addMenuToView:self.thirdView];
    
    [self startRightArrowAnimation];
    [self startUpArrowAnimation];
}

- (void)removeFromSuperview {
    [self.layer removeAllAnimations];
    
    [super removeFromSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.tutorialScrollView.contentOffset = CGPointMake(self.pageControl.currentPage * self.tutorialScrollView.bounds.size.width, 0);
}


#pragma mark - Actions

- (void)actionGoGifs {
    if ([self.delegate respondsToSelector:@selector(showDefaultFeature)]) {
        [self.delegate showDefaultFeature];
    }
    [self removeFromSuperview];
}

- (IBAction)actionSkip {
    [self removeFromSuperview];
}


#pragma mark - Private

- (MenuVC *)addMenuToView:(UIView *)view {
    MenuVC *menu = [[MenuVC alloc] initWithNibName:NSStringFromClass([MenuVC class]) bundle:nil];
    [view addSubview:menu.view];
    [menu.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(IS_IPAD ? 54: 44);
    }];
    return menu;
}

- (void)setupText:(NSString *)text forLabel:(UILabel *)label range:(NSRange)range {
    UIFont *font = [UIFont helveticaNeueBoldFontOfSize:IS_IPHONE_5 ? 18 : 20];
    UIColor *color = RGB(0, 174, 239);
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color};
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text];
    [attrString addAttributes:attributes range:range];
    label.attributedText = attrString;
}


#pragma mark - Private Animations

- (void)startRightArrowAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    animation.fromValue = @(self.rightArrowView.center.x);
    animation.toValue = @(self.rightArrowView.center.x - kTutorialViewArrowAnimationOffset);
    animation.duration = kTutorialViewArrowAnimationDuration;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.repeatCount = CGFLOAT_MAX;
    
    [self.rightArrowView.layer addAnimation:animation forKey:nil];
}

- (void)startUpArrowAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = @(self.upArrowView.center.y);
    animation.toValue = @(self.upArrowView.center.y + kTutorialViewArrowAnimationOffset);
    animation.duration = kTutorialViewArrowAnimationDuration;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.repeatCount = CGFLOAT_MAX;
    
    [self.upArrowView.layer addAnimation:animation forKey:nil];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [UIView animateWithDuration:kTutorialViewButtonsAnimationDuration animations:^{
        self.secondMenu.view.alpha = 0;
    }];
}

@end

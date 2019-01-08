//
//  LogoButtonTutorialView.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 12.01.16.
//
//

#import "OverlayButtonTutorialView.h"

#import "Macroses.h"
#import "UIFont+Hyperkey.h"

@interface OverlayButtonTutorialView ()

@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@end

@implementation OverlayButtonTutorialView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.subtitleLabel.font = [UIFont helveticaNeueFontOfSize:IS_IPHONE_5 ? 18 : 20];
    
    UIImage *image = [UIImage imageNamed:@"kb_main_icon"];
    self.overlayButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:ACKeyAppearanceLight image:image];
    [self.overlayButton addTarget:self action:@selector(actionOverlay) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.overlayButton];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(actionSwipe)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeGesture];
}


#pragma mark - Property

- (void)setOverlayButtonFrame:(CGRect)overlayButtonFrame {
    self.overlayButton.frame = overlayButtonFrame;
}

- (CGRect)overlayButtonFrame {
    return self.overlayButton.frame;
}


#pragma mark - Actions

- (void)actionSwipe {
    if ([self.delegate respondsToSelector:@selector(overlayButtonTutorialViewDidActionSwipe)]) {
        [self.delegate overlayButtonTutorialViewDidActionSwipe];
    }
    
    [self removeFromSuperview];
}

- (void)actionOverlay {
    if ([self.delegate respondsToSelector:@selector(overlayButtonTutorialViewDidActionOverlay)]) {
        [self.delegate overlayButtonTutorialViewDidActionOverlay];
    }
    
    [self removeFromSuperview];
}

@end

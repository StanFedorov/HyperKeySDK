//
//  FourthTutorialView.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 23.12.15.
//
//

#import "FourthTutorialView.h"

#import "UIFont+Hyperkey.h"
#import "Macroses.h"

@interface FourthTutorialView ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fourthViewArrowConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fourthViewPasteConstraint;

@property (assign, nonatomic) BOOL stopAllAnimations;

@end

@implementation FourthTutorialView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self startFirstAnimation];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAction)];
    tapGesture.numberOfTapsRequired = 1.0;
    [self addGestureRecognizer:tapGesture];
    
    self.objectName = @"Object";
    self.stopAllAnimations = NO;
}

- (void)removeFromSuperview {
    self.stopAllAnimations = YES;
    [self.layer removeAllAnimations];
    
    [super removeFromSuperview];
}


#pragma mark - Property

- (void)setObjectName:(NSString *)objectName {
    _objectName = objectName;
    
    NSString *string = [NSString stringWithFormat:@"Great! The %@ was copied. Now paste it in the text field.", objectName];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    [attrString addAttribute:NSFontAttributeName value:[UIFont helveticaNeueBoldFontOfSize:20] range:NSMakeRange(0, 6)];
    [attrString addAttribute:NSForegroundColorAttributeName value:RGB(0, 174, 239) range:NSMakeRange(0, 6)];
    
    self.titleLabel.attributedText = attrString;
}


#pragma mark - Private

- (void)removeAction {
    [self removeFromSuperview];
}


#pragma mark - Add Animations

- (void)startFirstAnimation {
    if (self.stopAllAnimations) {
        return;
    }
    
    self.fourthViewArrowConstraint.constant += 5.0;
    self.fourthViewPasteConstraint.constant += 5.0;
    [self.containerView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.fourthViewArrowConstraint.constant -= 5.0;
        self.fourthViewPasteConstraint.constant -= 5.0;
        [self.containerView setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.containerView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self startFirstAnimation];
        }];
    }];
}

@end

//
//  MenuItemCollectionViewCell.m
//  Better Word
//
//  Created by Sergey Vinogradov on 19.02.16.
//
//

#import "MenuItemCollectionViewCell.h"

CGFloat const kRegularAlpha = 0.7;

@interface MenuItemCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *selectedView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *selectRelatedSizeConstraintList;

@end

@implementation MenuItemCollectionViewCell

#pragma mark - Animations

- (void)startQuivering {
    if (self.isNoneFeature) {
        return;
    }
    
    self.selectedView.hidden = YES;
    
    CABasicAnimation *quiverAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    float startAngle = (-2) * M_PI / 180.0;
    float stopAngle = -startAngle;
    quiverAnim.fromValue = [NSNumber numberWithFloat:startAngle];
    quiverAnim.toValue = [NSNumber numberWithFloat:3 * stopAngle];
    quiverAnim.autoreverses = YES;
    quiverAnim.duration = 0.15;
    quiverAnim.repeatCount = HUGE_VALF;
    quiverAnim.timeOffset = (CFTimeInterval)(arc4random() % 100) / 100 - 0.50;
    [self.layer addAnimation:quiverAnim forKey:@"quivering"];
}

- (void)stopQuivering {
    if (self.isNoneFeature) {
        return;
    }
    
    CALayer *layer = self.layer;
    [layer removeAnimationForKey:@"quivering"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.imageView.alpha = selected ? 1.0 : kRegularAlpha;
    for (NSLayoutConstraint *constraint in self.selectRelatedSizeConstraintList) {
        constraint.constant = selected ? 0 : -2;
    }
}

@end

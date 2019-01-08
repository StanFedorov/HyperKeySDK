//
//  ActionView.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 21.06.16.
//
//

#import "ActionView.h"

NSTimeInterval const kActionViewDefaultShowAnimationDuration = 0.6;
NSTimeInterval const kActionViewDefaultHideAnimationDuration = 0.3;

@interface ActionView ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic, readwrite) BOOL isAnimating;

@end

@implementation ActionView

#pragma mark - Property

- (void)setType:(ActionViewType)type {
    _type = type;
        
    [self updateTitle];
    [self updateIcon];
}

- (void)setCustomTitle:(NSString *)customTitle {
    _customTitle = customTitle;
    
    [self updateTitle];
}


#pragma mark - Public

- (void)prepareShowAnimation {
    self.isAnimating = YES;
    
    self.backgroundView.layer.cornerRadius = self.backgroundView.frame.size.width / 2;
    self.contentView.transform = CGAffineTransformMakeScale(0, 0);
    self.contentView.alpha = 1;
}

- (void)startShowAnimationWithCompletion:(void (^)(BOOL finished))completion {
    [self startShowAnimationWithDuration:kActionViewDefaultShowAnimationDuration delay:0 completion:completion];
}

- (void)startShowAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion {
    [self prepareShowAnimation];
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:1 animations:^{
            self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        }];
    } completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.isAnimating = NO;
        }
        
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)updateShowAnimationProgress:(CGFloat)progress {
    CGFloat scale = MIN(1, progress);
    
    self.contentView.transform = CGAffineTransformMakeScale(scale, scale);
    
    if (progress >= 1) {
        self.isAnimating = NO;
    }
}

- (void)startHideAnimationsCompletion:(void (^)(BOOL finished))completion {
    [self startHideAnimationsWithDuration:kActionViewDefaultHideAnimationDuration delay:0 completion:completion];
}

- (void)startHideAnimationsWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion {
    self.isAnimating = YES;
        
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:duration delay:delay options:0 animations:^{
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.isAnimating = NO;
            [strongSelf removeFromSuperview];
        }
        
        if (completion) {
            completion(finished);
        }
    }];
}


#pragma mark - Private

- (void)updateTitle {
    if (self.customTitle) {
        self.titleLabel.text = self.customTitle;
    } else {
        NSString *title = nil;
        switch (self.type) {
            case ActionViewTypeCopy:
                title = @"Copied";
                break;
                
            case ActionViewTypePaste:
                title = @"Pasted";
                break;
        }
        self.titleLabel.text = title;
    }
}

- (void)updateIcon {
    NSString *imageName = nil;
    switch (self.type) {
        case ActionViewTypeCopy:
            imageName = @"icon_action_copy";
            break;
            
        case ActionViewTypePaste:
            imageName = @"icon_action_paste";
            break;
    }
    self.iconImageView.image = [UIImage imageNamed:imageName];
}

@end

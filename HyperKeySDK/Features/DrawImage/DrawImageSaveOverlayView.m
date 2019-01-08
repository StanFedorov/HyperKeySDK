//
//  DrawImageSaveOverlayView.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 30.06.16.
//
//

#import "DrawImageSaveOverlayView.h"

#import "DrawImageConfig.h"

@implementation DrawImageSaveOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    [self addGestureRecognizer:tapGesture];
}


#pragma mark - Public

- (void)startAnimatingWithCompetion:(void (^)(void))competion {
    if (self.alpha < 1) {        
        [UIView animateWithDuration:kDrawImageShowOverlayAnimationDuration animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            if (competion) {
                competion();
            }
        }];
    } else {
        if (competion) {
            competion();
        }
    }
}

- (void)stopAnimatingWithCompetion:(void (^)(void))competion {
    if (self.alpha > 0) {
        [UIView animateWithDuration:kDrawImageShowOverlayAnimationDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if (competion) {
                competion();
            }
        }];
    } else {
        if (competion) {
            competion();
        }
    }
}


#pragma mark - Actions

- (void)actionTap {
    if ([self.delegate respondsToSelector:@selector(drawImageSaveOverlayViewDidTap)]) {
        [self.delegate drawImageSaveOverlayViewDidTap];
    }
}

@end

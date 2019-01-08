//
//  DrawImageNotificationView.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 26.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageShareOverlayView.h"

#import "DrawImageConfig.h"

@interface DrawImageShareOverlayView ()

@property (weak, nonatomic) IBOutlet UIView *pasteView;

@end

@implementation DrawImageShareOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    [self addGestureRecognizer:tapGesture];
}


#pragma mark - Public

- (void)startAnimatingWithCompetion:(void (^)(void))competion {
    if (self.alpha < 1) {
        [self startPasteAnimation];
        
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
            [self stopPasteAnimation];
            
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

- (IBAction)actionLink {
    if ([self.delegate respondsToSelector:@selector(drawImageShareOverlayViewDidLinkAction)]) {
        [self.delegate drawImageShareOverlayViewDidLinkAction];
    }
}

- (IBAction)actionWhatsApp {
    if ([self.delegate respondsToSelector:@selector(drawImageShareOverlayViewDidWhatsAppAction)]) {
        [self.delegate drawImageShareOverlayViewDidWhatsAppAction];
    }
}

- (IBAction)actionSaveImage {
    if ([self.delegate respondsToSelector:@selector(drawImageShareOverlayViewDidImageAction)]) {
        [self.delegate drawImageShareOverlayViewDidImageAction];
    }
}

- (void)actionTap {
    if ([self.delegate respondsToSelector:@selector(drawImageShareOverlayViewDidTap)]) {
        [self.delegate drawImageShareOverlayViewDidTap];
    }
}


#pragma mark - Private

- (void)startPasteAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = @(self.pasteView.center.y);
    animation.toValue = @(self.pasteView.center.y - kDrawImagePasteOverlayOffsetY);
    animation.duration = kDrawImageShowOverlayAnimationDuration;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.autoreverses = YES;
    animation.removedOnCompletion = NO;
    animation.repeatCount = CGFLOAT_MAX;
    
    [self.pasteView.layer addAnimation:animation forKey:nil];
}

- (void)stopPasteAnimation {
    [self.pasteView.layer removeAllAnimations];
}

@end

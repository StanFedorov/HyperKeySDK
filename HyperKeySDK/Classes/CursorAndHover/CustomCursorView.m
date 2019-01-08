//
//  CustomCursorView.m
//  TestCursor
//
//  Created by Dmitriy gonchar on 11/10/15.
//  Copyright (c) 2015 Dmitriy gonchar. All rights reserved.
//

#import "CustomCursorView.h"

#import "Macroses.h"

NSTimeInterval const kCustomCursorTimeInterval = 0.5;

@interface CustomCursorView ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation CustomCursorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGB(0, 173, 238);
    }
    return self;
}

- (void)startAnimation {
    [self stopAnimation];
    
    self.alpha = 1.0;
    [self performSelector:@selector(startTimer) withObject:nil afterDelay:kCustomCursorTimeInterval];
}

- (void)stopAnimation {
    [self stopTimer];
}


#pragma mark - Private

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)startTimer {
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kCustomCursorTimeInterval target:self selector:@selector(startViewAnimation) userInfo:nil repeats:YES];
}

- (void)startViewAnimation {
    BOOL itVisible = (self.alpha == 1);
    [UIView animateWithDuration:(kCustomCursorTimeInterval - 0.1) animations:^{
        self.alpha = itVisible? 0.0 : 1.0;
    }];
}

@end

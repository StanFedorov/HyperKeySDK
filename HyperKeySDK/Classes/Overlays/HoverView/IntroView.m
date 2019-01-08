//
//  HoverView.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 03.11.15.
//
//

#import "IntroView.h"

@interface IntroView ()


@end

@implementation IntroView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

@end

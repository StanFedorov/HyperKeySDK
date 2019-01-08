//
//  SwitchToEmoji.m
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import "SwitchToEmoji.h"
#import "UIImage+Pod.h"

CGFloat const kSwitchToEmojiShadowSize = 3;

@interface SwitchToEmoji()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *backgroundView;

@property (strong, nonatomic) UIButton *globeButton;
@property (strong, nonatomic) UIButton *emojiButton;

@end

@implementation SwitchToEmoji

- (instancetype)initWithSuperViewFrame:(CGRect)superFrame emojiButtonFrame:(CGRect)frame {
    if (self = [self initWithFrame:superFrame]) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        
        [self makeSubviews];
        [self layoutSwitchWithEmojiButtonFrame:frame animated:NO];
        [self addGestures];
    }
    
    return self;
}

- (void)makeSubviews {
    UIFont *buttonFont = [UIFont systemFontOfSize:12];
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 186, 131)];
    self.containerView.userInteractionEnabled = YES;
    self.containerView.backgroundColor = [UIColor clearColor];
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.containerView.bounds];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView setImage:[UIImage imageNamedPod:@"open_globe_backgr"]];
    
    self.globeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.globeButton setTitle:@"SWITCH KEYBOARD" forState:UIControlStateNormal];
    [self.globeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.globeButton.titleLabel setFont:buttonFont];
    [self.globeButton setImage:[UIImage imageNamedPod:@"globe_open"] forState:UIControlStateNormal];
    [self.globeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.globeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.globeButton setFrame:CGRectMake(30, 15, 150, 19)];
    
    self.emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emojiButton setTitle:@"EMOJI" forState:UIControlStateNormal];
    [self.emojiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.emojiButton.titleLabel setFont:buttonFont];
    [self.emojiButton setImage:[UIImage imageNamedPod:@"emoji_open"] forState:UIControlStateNormal];
    [self.emojiButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.emojiButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.emojiButton setFrame:CGRectMake(30, 42, 150, 19)];
    
    [self.globeButton addTarget:self action:@selector(tapGlobe:) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiButton addTarget:self action:@selector(tapEmoji:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerView addSubview:self.backgroundView];
    [self.containerView addSubview:self.globeButton];
    [self.containerView addSubview:self.emojiButton];
    
    [self addSubview:self.containerView];
}

- (void)layoutSwitchWithEmojiButtonFrame:(CGRect)buttonFrame animated:(BOOL)animated {
    CGRect frame = self.containerView.frame;
    frame.origin.x = buttonFrame.origin.x - 25;
    frame.origin.y = buttonFrame.origin.y + buttonFrame.size.height - frame.size.height + kSwitchToEmojiShadowSize;
    
    [UIView animateWithDuration:(int)animated / 10.0 animations:^{
        self.containerView.frame = frame;
    }];
}

- (void)tapGlobe:(id)sender {
    [self.delegate tapGlobeButton];
}

- (void)tapEmoji:(id)sender {
    [self.delegate tapEmojiButton];
}


#pragma mark - Gestures

- (void)addGestures {
    UITapGestureRecognizer *tapBackgr = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(closeSwitchToEmojiView)];
    [self addGestureRecognizer:tapBackgr];
    
    UITapGestureRecognizer *tapPanel = [[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(closeSwitchToEmojiView)];
    [self.containerView addGestureRecognizer:tapPanel];
}

@end

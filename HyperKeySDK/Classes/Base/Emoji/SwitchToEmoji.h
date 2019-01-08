//
//  SwitchToEmoji.h
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import <UIKit/UIKit.h>

@protocol SwitchToEmojiDelegate <NSObject>

- (void)tapGlobeButton;
- (void)tapEmojiButton;
- (void)closeSwitchToEmojiView;

@end

@interface SwitchToEmoji : UIView

@property (weak, nonatomic) id<SwitchToEmojiDelegate> delegate;

- (instancetype)initWithSuperViewFrame:(CGRect)superFrame emojiButtonFrame:(CGRect)frame;
- (void)layoutSwitchWithEmojiButtonFrame:(CGRect)frame animated:(BOOL)animated;

@end

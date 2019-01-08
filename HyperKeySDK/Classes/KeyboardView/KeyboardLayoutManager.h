//
//  KeyboardLayoutManager.h
//  Better Word
//
//  Created by Sergey Vinogradov on 13.08.16.
//
//

#import "UIKit/UIKit.h"
#import "KeyboardFeature.h"

#define LayoutManager [KeyboardLayoutManager sharedManager]
#define kGifStripeGeight 100

@protocol KeyboardAppearingDelegate;

@interface KeyboardLayoutManager : NSObject

@property (assign, nonatomic, getter = isKeyboardHidden) BOOL keyboardHide;
@property (assign, nonatomic, getter = isMainViewTruncate) BOOL mainViewTruncate;
@property (assign, nonatomic, getter = isPortraitOrientation) BOOL portraitOrientation;
@property (assign, nonatomic, getter = isGifStripeShow) BOOL gifStripeShow;

@property (assign, nonatomic, readonly) CGRect keyboardFrame;

@property (weak, nonatomic) id<KeyboardAppearingDelegate> delegate;
@property (strong, nonatomic) KeyboardFeature *selectedFeature;

+ (instancetype)sharedManager;

- (CGFloat)mainViewHeight;
- (CGFloat)menuHeight;
- (CGRect)amazonKeyboardFrame;
- (void)resetFrame;

@end

//
//  KeyboardView.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/17/14.
//
//

#import <UIKit/UIKit.h>
#import "ReachabilityManager.h"
#import "ACKey.h"
#import "ACLockKey.h"
#import "KeyboardThemesHelper.h"
#import "Config.h"
#import "PhoneKeyboardMetrics.h"
#import "PadKeyboardMetrics.h"
#import "ThemeChangesResponderProtocol.h"

typedef NS_ENUM(NSInteger, KeyboardViewPadType) {
    KeyboardViewPadTypeLetter,
    KeyboardViewPadTypeNumber,
    KeyboardViewPadTypeSymbol,
};

@protocol KeyboardViewDelegate <NSObject>

- (void)hidePressedPad;
- (void)overlayButtonTapped:(id)sender;

- (void)textDidChange:(id)someObject;

- (void)letterButtonTappedWithText:(NSString *)text;
- (void)returnButtonTapped;

- (void)undoButtonTapped;
- (void)redoButtonTapped;

- (void)playClick;

- (void)setupNewNextKeyboardButton:(ACKey *)button;
- (void)setupNewDeleteButton:(ACKey *)button;

@end

@interface KeyboardView : UIView <ThemeChangesResponderProtocol>

@property (weak, nonatomic) id<KeyboardViewDelegate> delegate;
@property (assign, nonatomic) BOOL isFullAccess;

- (void)createLetterPadPhone;
- (void)showLetterPad;
- (void)hideLetterPad;
- (void)showSymbolPad;
- (void)hideSymbolPad;
- (void)changeSymbolToNumberPad;
- (void)changeNumberToSymbolPad;

- (ACKeyAppearance)keyAppearance;

- (void)updateAppearance;

- (void)updateFont;
- (void)updateCapitalizationOfKeys;

- (CGFloat)cornerRadius;

- (PhoneKeyboardMetrics)phoneKeyboardMetrics;
- (PadKeyboardMetrics)padKeyboardMetrics;

- (void)recalculateFramesForSize:(CGSize)newSize;
- (void)updateReturnButtonTitle:(NSString *)title;

@property (strong, nonatomic) ACKey *overlayButton;
@property (assign, nonatomic, readonly) KeyboardViewPadType currentPad;

@property (strong, nonatomic) ACKey *nextKeyboardButton;
@property (strong, nonatomic) ACKey *deleteButton;
@property (strong, nonatomic) ACKey *returnButton;

@property (strong, nonatomic) ACLockKey *leftShiftButton;
@property (strong, nonatomic) ACLockKey *rightShiftButton;

@property (assign, nonatomic) BOOL isPortraitOrientation;

@end

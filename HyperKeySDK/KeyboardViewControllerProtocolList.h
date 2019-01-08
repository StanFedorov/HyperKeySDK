//
//  KeyboardViewControllerProtocolList.h
//  Better Word
//
//  Created by Sergey Vinogradov on 11.08.16.
//
//
// Here you can find all protocols for container KeyboardViewController

@protocol DirectInsertAndDeleteDelegate <NSObject>

- (void)insertTextStringToCurrentPosition:(NSString *)textString; // Without any checking of text
- (void)deleteTap;
- (void)deleteLongTapBegin;
- (void)deleteLongTapEnd;

@end

@protocol KeyboardContainerDelegate <NSObject>

- (void)functionButton:(UIButton *)sender;
- (void)openMainAppFromFeatureType:(NSUInteger)featureType;

- (void)showKeyboard;
- (void)hideKeyboard;
- (void)userDidSelectTextField;
- (void)nextKeyboardAction;
- (void)showRecentAction;
- (void)showFeedAction;
- (void)keyboardContainerDidPrepareForInsertText;
- (void)keyboardContainerDidInsertText:(NSString *)text;
- (void)keyboardContainerDidInsertKeyboardText:(NSString *)text;

@end

@protocol KeyboardAppearingDelegate <NSObject>

- (void)keyboardWasHidden:(BOOL)wasHidden;

@end

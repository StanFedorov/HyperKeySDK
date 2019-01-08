//
//  ExtendedBaseVC.h
//  Better Word
//
//  Created by Sergey Vinogradov on 19.05.16.
//
//

#import "BaseVC.h"

extern NSString *const kSearchFieldImageNameShow;
extern NSString *const kSearchFieldImageNameHide;

@interface ExtendedBaseVC : BaseVC

@property (weak, nonatomic) IBOutlet UIButton *showKeyboardButton;
@property (weak, nonatomic) id<UITextFieldIndirectDelegate, KeyboardContainerDelegate> delegate;

- (void)keyboardDidDisappear;
- (void)showKeyboardButtonTap:(id)sender;

@end

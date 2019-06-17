//
//  PhoneKeyboardMetrics.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 10/12/14.
//
//

#import <UIKit/UIKit.h>

typedef struct {
    CGRect yoButton;
    
    CGRect numberPadButtonFrame;
    CGRect overlayButtonFrame;
    CGRect leftShiftButtonFrame;
    CGRect deleteButtonFrame;

    CGRect nextKeyboardButtonFrame;
    CGRect spaceButtonFrame;
    CGRect returnButtonFrame;
    CGRect letterPadFrames[5][10];
    CGRect letterPadFramesReal[5][10];
    CGRect symbolPadFrames[5][10];
    CGRect symbolPadFramesReal[5][10];
} PhoneKeyboardMetrics;

PhoneKeyboardMetrics getPhoneLinearKeyboardMetrics(CGFloat keyboardWidth, CGFloat keyboardHeight);
PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone5(CGFloat keyboardWidth, CGFloat keyboardHeight);
PhoneKeyboardMetrics getPhoneXLinearKeyboardMetrics(CGFloat keyboardWidth, CGFloat keyboardHeight);
PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone5Transparent(CGFloat keyboardWidth, CGFloat keyboardHeight);
PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone6Transparent(CGFloat keyboardWidth, CGFloat keyboardHeight);
PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone6PlusTransparent(CGFloat keyboardWidth, CGFloat keyboardHeight);

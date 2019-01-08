//
//  PadKeyboardMetrics.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 10/12/14.
//
//

#import <UIKit/UIKit.h>

typedef struct {
    CGRect yoButton;
    
    CGRect leftShiftButtonFrame;
    CGRect rightShiftButtonFrame;
    CGRect deleteButtonFrame;
    
    CGRect nextKeyboardButtonFrame;
    CGRect spaceButtonFrame;
    CGRect returnButtonFrame;
    CGRect hideButtonFrame;
    CGRect leftNumberButtonFrame;
    CGRect rightNumberButtonFrame;
    CGRect overlayButtonFrame;
    CGRect letterPadFrames[5][10];
    CGRect letterPadFramesReal[5][10];
    CGRect undoButtonFrame;
    
} PadKeyboardMetrics;

PadKeyboardMetrics getPadLinearKeyboardMetrics(CGFloat keyboardWidth, CGFloat keyboardHeight);
PadKeyboardMetrics getPadLinearKeyboardMetricsTransparent(CGFloat keyboardWidth, CGFloat keyboardHeight);

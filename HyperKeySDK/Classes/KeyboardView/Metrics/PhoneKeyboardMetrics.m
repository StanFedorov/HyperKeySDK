//
//  PhoneKeyboardMetrics.c
//  ACKeyboard
//
//  Created by Arnaud Coomans on 10/12/14.
//
//

#import "PhoneKeyboardMetrics.h"

#import "Linear.h"
#import "UIDevice+Hardware.h"

CGFloat const kPhoneKeyboardPortraitWidth = 320.0;
CGFloat const kPhoneKeyboardLandscapeWidth = 568.0;
CGFloat const kPhoneKeyboardPortraitHeight = 226.0;
CGFloat const kPhoneKeyboardLandscapeHeight = 172.0;

PhoneKeyboardMetrics getPhoneLinearKeyboardMetrics(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    CGFloat edgeMargin = 3.0;
    CGFloat bottomMargin = kPhoneKeyboardLandscapeHeight == keyboardHeight ? 11 : 13; // Landscape/Portrait
    CGFloat bottomMidleRowReduce = kPhoneKeyboardLandscapeHeight == keyboardHeight ? 0.0 : 3.0 - 0.5; // Landscape/portrait
    
    CGFloat rowMargin = LINEAR_EQ(keyboardHeight, kPhoneKeyboardPortraitHeight, 11.3 - 0.1, kPhoneKeyboardLandscapeHeight, 4.5);
    CGFloat columnMargin = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 6.0, kPhoneKeyboardLandscapeWidth, 7.0);
    CGFloat keyHeight = LINEAR_EQ(keyboardHeight, kPhoneKeyboardPortraitHeight, 41.5 + 0.4, kPhoneKeyboardLandscapeHeight, 33.0);
    CGFloat letterKeyWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 26.0, kPhoneKeyboardLandscapeWidth, 50.0);
    
    CGFloat nextKeyboardButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 34.0, kPhoneKeyboardLandscapeWidth, 50.0);
    CGFloat returnButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 74.0, kPhoneKeyboardLandscapeWidth, 107.0);
    CGFloat deleteButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 36.0, kPhoneKeyboardLandscapeWidth, 69.0);
    CGFloat leftShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 36.0, kPhoneKeyboardLandscapeWidth, 68.0);
    
    CGFloat lettersBottomRowMargin = (keyboardWidth - 7 * letterKeyWidth - 6 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    CGFloat lettersMediumRowMargin = (keyboardWidth - 9 * letterKeyWidth - 8 * columnMargin - edgeMargin * 2) / 2;
    CGFloat symbolBottomRowMargin = (keyboardWidth - 5 * leftShiftButtonWidth - 4 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;

    
    PhoneKeyboardMetrics metrics = {
        .numberPadButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            nextKeyboardButtonWidth,
            keyHeight
        },
        .overlayButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            nextKeyboardButtonWidth,
            keyHeight
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - bottomMargin - keyHeight,
            returnButtonWidth,
            keyHeight
        },
        .spaceButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            keyboardWidth - (edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + columnMargin + returnButtonWidth + edgeMargin),
            keyHeight
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight) + bottomMidleRowReduce,
            deleteButtonWidth,
            keyHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight) + bottomMidleRowReduce,
            leftShiftButtonWidth,
            keyHeight
        },
        .yoButton = {
            (keyboardWidth - letterKeyWidth) / 2,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            letterKeyWidth,
            keyHeight
        },
    };
    
    
    CGRect rect = CGRectZero;
    
    // Real letter keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 1; i < 8; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin  /2;
        rect.origin.y =  keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    rect.origin.x = 0;
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][0] = rect;

    rect.origin.x = keyboardWidth - (letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin);
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][8] = rect;

    // 3d row
    for (int i = 1; i < 6; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + 6 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][6] = rect;
    
    // Letter keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 7; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[2][i] = rect;
    }
    
    // Real symbol keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[1][i] = rect;
    }

    
    // 3d row
    for (int i = 1; i < 4; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = leftShiftButtonWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin + bottomMidleRowReduce;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + 2 * leftShiftButtonWidth + columnMargin / 2 + symbolBottomRowMargin + 4 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][4] = rect;
    
    // Symbol keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.symbolPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.symbolPadFrames[1][i] = rect;
    }

    // 3d row
    for (int i = 0; i < 5; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce;
        rect.size.width = leftShiftButtonWidth;
        rect.size.height = keyHeight;
        metrics.symbolPadFrames[2][i] = rect;
    }
    return metrics;
}

PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone5(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    BOOL isPortrait = (keyboardHeight == 225);
    CGFloat edgeMargin = isPortrait ? 3 : 2;
    // Sorry: Lots of Magic constants. Hint - look at layoutViewForSize: from KeyboardViewController.h
    CGFloat bottomMargin            = isPortrait ? 12 : 13; // Landscape/portrait
    CGFloat rowMargin               = isPortrait ? 15 : 7;
    CGFloat columnMargin            = isPortrait ? 6 : 5;
    CGFloat keyHeight               = isPortrait ? 39 : 33;
    CGFloat letterKeyWidth          = isPortrait ? 26 : 52;
    CGFloat nextKeyboardButtonWidth = isPortrait ? 34 : 50;
    CGFloat returnButtonWidth       = isPortrait ? 74 : 107;
    CGFloat deleteButtonWidth       = isPortrait ? 36 : 69;
    CGFloat leftShiftButtonWidth    = isPortrait ? 36 : 68;
    
    CGFloat lettersBottomRowMargin = (keyboardWidth - 7 * letterKeyWidth - 6 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    CGFloat lettersMediumRowMargin = (keyboardWidth - 9 * letterKeyWidth - 8 * columnMargin - edgeMargin * 2) / 2;
    
    CGFloat symbolBottomRowMargin = (keyboardWidth - 5 * leftShiftButtonWidth - 4 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    
    PhoneKeyboardMetrics metrics = {
        .numberPadButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            nextKeyboardButtonWidth,
            keyHeight
        },
        .overlayButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            nextKeyboardButtonWidth,
            keyHeight
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - bottomMargin - keyHeight,
            returnButtonWidth,
            keyHeight
        },
        .spaceButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            keyboardWidth - (edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + columnMargin + returnButtonWidth + edgeMargin),
            keyHeight
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth - (isPortrait ? 0 : 1),
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            deleteButtonWidth,
            keyHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin + (isPortrait ? 0 : 1),
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            leftShiftButtonWidth,
            keyHeight
        },
        .yoButton = {
            (keyboardWidth - letterKeyWidth) / 2,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            letterKeyWidth,
            keyHeight
        },
    };
    
    CGRect rect = CGRectZero;
    
    // Real letter keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 1; i < 8; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    rect.origin.x = 0;
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][0] = rect;
    
    rect.origin.x = keyboardWidth - (letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin);
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][8] = rect;
    
    // 3d row
    for (int i = 1; i < 6; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + 6 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][6] = rect;
    
    // Letter keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && i == 0) ? 1 : 0) - ((!isPortrait && (i == 6 || i == 7 || i == 8 || i == 9)) ? 1 : 0);
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 0 || i == 5 || i == 9)) ? 1 : 0);
        rect.size.height = keyHeight;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && (i == 0 || i == 1 || i == 2 || i == 8)) ? 1 : 0) - ((!isPortrait && (i == 8)) ? 2 : 0);
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 2 || i == 6 || i == 7)) ? 1 : 0);
        rect.size.height = keyHeight;
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 7; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth +lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && (i == 0 || i == 1)) ? 1.5 : 0) +((!isPortrait && (i == 2 || i == 3 || i == 4 || i == 5 || i == 6)) ? 0.5 : 0);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 1 || i == 5 || i == 6)) ? 1 : 0);
        rect.size.height = keyHeight;
        metrics.letterPadFrames[2][i] = rect;
    }
    
    // Real symbol keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[1][i] = rect;
    }
    
    // 3d row
    for (int i = 1; i < 4; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = leftShiftButtonWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + 2 * leftShiftButtonWidth + columnMargin / 2 + symbolBottomRowMargin + 4 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][4] = rect;
    
    // Symbol keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.symbolPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.symbolPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 5; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = leftShiftButtonWidth;
        rect.size.height = keyHeight;
        metrics.symbolPadFrames[2][i] = rect;
    }
    return metrics;
}


#pragma mark - Transparent Theme

PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone5Transparent(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    // TODO: not good definition
    BOOL isPortrait = (keyboardHeight == 225);
    CGFloat shrinkHyperkeyButton    = isPortrait ? 12 : 0; // Landscape/portrait
    CGFloat bottomRowUpShift        = isPortrait ? 6 : 0;
    CGFloat lastRowUpShift          = isPortrait ? 3 : 0;
    CGFloat edgeMargin              = isPortrait ? 3 : 2;
    CGFloat commaRightShift         = isPortrait ? 10 : 0;
    // Sorry: Lots of Magic constants. Hint - look at layoutViewForSize: from KeyboardViewController.h
    CGFloat bottomMargin            = isPortrait ? 12 : 13;
    CGFloat rowMargin               = isPortrait ? 15 : 7;
    CGFloat columnMargin            = isPortrait ? 6 : 5;
    CGFloat keyHeight               = isPortrait ? 39 : 33;
    CGFloat letterKeyWidth          = isPortrait ? 26 : 52;
    CGFloat nextKeyboardButtonWidth = isPortrait ? 34 : 50;
    CGFloat returnButtonWidth       = isPortrait ? 74 : 107;
    CGFloat deleteButtonWidth       = isPortrait ? 36 : 69;
    CGFloat leftShiftButtonWidth    = isPortrait ? 36 : 68;
    
    const CGFloat pixel = 0.5;
    
    CGFloat lettersBottomRowMargin = (keyboardWidth - 7 * letterKeyWidth - 6 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    CGFloat lettersMediumRowMargin = (keyboardWidth - 9 * letterKeyWidth - 8 * columnMargin - edgeMargin * 2) / 2;
    
    CGFloat symbolBottomRowMargin = (keyboardWidth - 5 * leftShiftButtonWidth - 4 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    
    PhoneKeyboardMetrics metrics = {
        .numberPadButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            leftShiftButtonWidth,
            keyHeight+bottomRowUpShift
        },
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin - 2,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            nextKeyboardButtonWidth,
            keyHeight+bottomRowUpShift
        },
        .overlayButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            nextKeyboardButtonWidth - shrinkHyperkeyButton,
            keyHeight + bottomRowUpShift
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            returnButtonWidth,
            keyHeight + bottomRowUpShift
        },
        .spaceButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            keyboardWidth - (edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + columnMargin + returnButtonWidth + edgeMargin),
            keyHeight + bottomRowUpShift
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth - (isPortrait ? 0 : 1),
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            deleteButtonWidth,
            keyHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin + (isPortrait ? 0 : 1),
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            leftShiftButtonWidth,
            keyHeight
        },
        .yoButton = {
            (keyboardWidth - letterKeyWidth) / 2,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            letterKeyWidth,
            keyHeight
        },
    };
    
    CGRect rect = CGRectZero;
    
    // Real letter keys :
    // 1st row
    
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 1; i < 8; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    rect.origin.x = 0;
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][0] = rect;
    
    rect.origin.x = keyboardWidth - (letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin);
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][8] = rect;
    
    // 3d row
    for (int i = 1; i < 6; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 - lastRowUpShift;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin + lastRowUpShift;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 - lastRowUpShift;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin + lastRowUpShift;
    metrics.letterPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + 6 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 - lastRowUpShift;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin + lastRowUpShift;
    metrics.letterPadFramesReal[2][6] = rect;
    
    // Letter keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && i ==0) ? 1 : 0) - ((!isPortrait && (i == 6 || i == 7 || i == 8 || i == 9)) ? 1 : 0) + (isPortrait ? 0 : (2 + (i == 0 ? -2 : 0) + (i == 1 ? 1 : 0) + (i == 5 ? -1 : 0) + (i == 6 ? 1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + (isPortrait ? -14 : -2) * pixel;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 0 || i == 5 || i == 9)) ? 1 : 0) + (isPortrait ? -1 : (-3 + (i == 0 ? 3 : 0) + (i== 1 ? - 1 : 0) + (i == 4 ? -1 : 0) + (i == 5 ? 2 : 0) + (i == 6 ? -1 : 0) + (i == 9 ? 1 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 20 : 2) * pixel;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && (i == 0 || i == 1 || i == 2 || i == 8)) ? 1 : 0) - ((!isPortrait && (i == 8)) ? 2 : 0) + (isPortrait ? (i > 3 ? 1 : 0) : (3 + (i == 1 || i == 2 ? -1 : 0) + (i == 4 ? 1 : 0) + (i == 6 || i == 7 ? -1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + (isPortrait ? -5 : 5) * pixel;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 2 || i == 6 || i == 7)) ? 1 : 0) + (isPortrait ? ((i != 3) ? -1 : 0) : (-4 + (i == 1 ? 1 : 0) + (i == 2 ? 2 : 0) + (i == 3 ? 2 : 0) + (i == 6 ? 3 : 0) + (i == 7 ? 2 : 0) + (i == 8 ? 1 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 9 : -7) * pixel;
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 7; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && (i == 0 || i == 1)) ? 1.5 : 0) + ((!isPortrait && (i == 2 || i == 3 || i == 4 || i == 5 || i == 6)) ? 0.5 : 0) + (isPortrait ? (i > 2 ? 1 : 0) : (2 + (i == 2 ? 1 : 0) + (i == 3 ? 2 : 0) + (i == 4 ? 1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - lastRowUpShift + (isPortrait ? -1 : 3) * pixel;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 1 || i == 5 || i == 6)) ? 1 : 0) + (isPortrait ? ((i != 2) ? -1 : 0) : (-3 + (i == 1 || i == 2 || i == 6 ? 1 : 0) + (i == 3 || i == 4 ? -1 : 0) + (i == 5 ? 2 : 0))) * pixel;
        rect.size.height = keyHeight + lastRowUpShift + (isPortrait ? 2 : -5) * pixel;
        metrics.letterPadFrames[2][i] = rect;
    }
    
    // Real symbol keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[1][i] = rect;
    }
    
    
    //3d row
    for (int i = 1; i < 4; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = leftShiftButtonWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 - lastRowUpShift;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin + lastRowUpShift;
    metrics.symbolPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + 2 * leftShiftButtonWidth + columnMargin / 2 + symbolBottomRowMargin + 4 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 - lastRowUpShift;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin + lastRowUpShift;
    metrics.symbolPadFramesReal[2][4] = rect;
    
    // Symbol keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && i == 0) ? 1 : 0) - ((!isPortrait && (i == 6 || i == 7 || i == 8 || i == 9)) ? 1 : 0) + (isPortrait ? 0 : (2 + (i == 0 ? -2 : 0) + (i == 1 ? 1 : 0) + (i == 5 ? -1 : 0) + (i == 6 ? 1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + (isPortrait ? -14 : -2) * pixel;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 0 || i == 5 || i==9)) ? 1 : 0) + (isPortrait ? -1 : (-3 + (i == 0 ? 3 : 0) + (i == 1 ? -1 : 0) + (i == 4 ? -1 : 0) + (i == 5 ? 2 : 0) + (i == 6 ? -1 : 0) + (i == 9 ? 1 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 20 : 2) * pixel;
        metrics.symbolPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + ((!isPortrait && i == 0) ? 1 : 0) - ((!isPortrait && (i == 6 || i == 7 || i == 8 || i == 9)) ? 1 : 0) + (isPortrait ? 0 : (2 + (i == 0 ? -2 : 0) + (i == 1 ? 1 : 0) + (i == 5 ? -1 : 0) + (i == 6 ? 1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + (isPortrait ? -5 : 5) * pixel;
        rect.size.width = letterKeyWidth - ((!isPortrait && (i == 0 || i == 5 || i == 9)) ? 1 : 0) + (isPortrait ? - 1 : (-3 + (i == 0 ? 3 : 0) + (i == 1 ? -1 : 0) + (i == 4 ? -1 : 0) + (i == 5? 2 : 0) + (i == 6 ? -1 : 0) + (i == 9 ? 1 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 9 : -7) * pixel;
        metrics.symbolPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 5; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - ((i == 0) ? commaRightShift : 0) + (isPortrait ? ((i == 0 ? 6 : 0) + (i == 1 ? -2 : 0) + (i == 2 ? 2 : 0) + (i == 3 ? 2 : 0) + (i == 4 ? 2 : 0)) : (2 + (i == 0 ? -31 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - lastRowUpShift + (isPortrait ? -1 : 3) * pixel;
        rect.size.width = leftShiftButtonWidth + ((i == 0 || i == 4) ? commaRightShift : 0) + (isPortrait ? ((i == 0 ? -9 : 0) + (i == 1 ? 3 : 0) + (i == 2 ? -1 : 0) + (i == 3 ? -1 : 0) + (i == 4 ? -8 : 0)) : (-3 + (i == 0 ? 31 : 0) + (i == 4 ? 34 : 0))) * pixel;
        rect.size.height = keyHeight + lastRowUpShift + (isPortrait ? 2 : -5) * pixel;
        metrics.symbolPadFrames[2][i] = rect;
    }
    
    return metrics;
}


PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone6Transparent(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    const CGFloat pixel = 0.33;
    
    // TODO: not good definition
    BOOL isPortrait = (keyboardHeight == 226.0);
    CGFloat shrinkHyperkeyButton =  isPortrait ? 5 : 0;
    CGFloat commaRightShift = isPortrait ? 8 : 0;
    CGFloat edgeMargin = 3.0;
    CGFloat bottomMargin = kPhoneKeyboardLandscapeHeight == keyboardHeight ? 11 : 13; // Landscape/Portrait
    CGFloat bottomMidleRowReduce = kPhoneKeyboardLandscapeHeight == keyboardHeight ? 0 : 3 - 0.5; // Landscape/Portrait
    
    CGFloat rowMargin = LINEAR_EQ(keyboardHeight, kPhoneKeyboardPortraitHeight, 11.3 - 0.1, kPhoneKeyboardLandscapeHeight, 4.5);
    CGFloat columnMargin = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 6.0, kPhoneKeyboardLandscapeWidth, 7.0);
    CGFloat keyHeight = LINEAR_EQ(keyboardHeight, kPhoneKeyboardPortraitHeight, 41.5 + 0.4, kPhoneKeyboardLandscapeHeight, 33.0);
    CGFloat letterKeyWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 26.0, kPhoneKeyboardLandscapeWidth, 50.0);
    
    CGFloat nextKeyboardButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 34.0, kPhoneKeyboardLandscapeWidth, 50.0);
    CGFloat returnButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 74.0, kPhoneKeyboardLandscapeWidth, 107.0);
    CGFloat deleteButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 36.0, kPhoneKeyboardLandscapeWidth, 69.0);
    CGFloat leftShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 36.0, kPhoneKeyboardLandscapeWidth, 68.0);
    
    CGFloat lettersBottomRowMargin = (keyboardWidth - 7 * letterKeyWidth - 6 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    CGFloat lettersMediumRowMargin = (keyboardWidth - 9 * letterKeyWidth - 8 * columnMargin - edgeMargin * 2) / 2;
    CGFloat symbolBottomRowMargin = (keyboardWidth - 5 * leftShiftButtonWidth - 4 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    
    PhoneKeyboardMetrics metrics = {
        .numberPadButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            nextKeyboardButtonWidth,
            keyHeight
        },
        .overlayButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            nextKeyboardButtonWidth - shrinkHyperkeyButton,
            keyHeight
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - bottomMargin - keyHeight,
            returnButtonWidth,
            keyHeight
        },
        .spaceButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            keyboardWidth - (edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + columnMargin + returnButtonWidth + edgeMargin),
            keyHeight
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight) + bottomMidleRowReduce,
            deleteButtonWidth,
            keyHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight) + bottomMidleRowReduce,
            leftShiftButtonWidth,
            keyHeight
        },
        .yoButton = {
            (keyboardWidth - letterKeyWidth) / 2,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            letterKeyWidth,
            keyHeight
        },
    };
    
    CGRect rect = CGRectZero;
    
    // Real letter keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 1; i < 8; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    rect.origin.x = 0;
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][0] = rect;
    
    rect.origin.x = keyboardWidth - (letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin);
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][8] = rect;
    
    // 3d row
    for (int i = 1; i < 6; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + 6 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][6] = rect;
    
    // Letter keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (i >= 6 ? -1 : 0) : 0) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce - (isPortrait ? 15 : 19) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? -1 : 3) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 19 : 12) * pixel;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (i < 6 ? 1 : 0) : ((i == 0 ? 5 : 0) + ((i > 0 && i < 5) ? 3 : 0) + ((i == 2 || i == 5) ? 1 : 0) - ((i == 8) ? 2 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? 0 : 9) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? (i == 5 ? -2 : -1) : (1 + ((i == 0 || i == 3 || i == 6) ? 1 : 0) + (i == 1 || i == 8 ? 2 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 0 : (-14 * pixel));
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 7; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) + pixel + (isPortrait ? 0 : ((i == 0 || i == 1 ? 5 : 0) + (i == 2 || i == 3 ? 3 : 0) + (i == 4 ? 2 : 0) + (i == 5 ? 1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -4 : 11) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? -1 : (2 + (i == 1 ? -1 : 0) + (i == 2 ? 1 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 0 : -4);
        metrics.letterPadFrames[2][i] = rect;
    }
    
    // Real symbol keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[1][i] = rect;
    }
    
    // 3d row
    for (int i = 1; i < 4; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = leftShiftButtonWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin + bottomMidleRowReduce;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + 2 * leftShiftButtonWidth + columnMargin / 2 + symbolBottomRowMargin + 4 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][4] = rect;
    
    // Symbol keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (i >= 6 ? -1 : 0) : 0) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 4*(keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce - (isPortrait ? 15 : 19) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? -1 : 3) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 19 : 12) * pixel;
        metrics.symbolPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (i >= 6 ? -1 : 0) : 0) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? 0 : (9 * pixel));
        rect.size.width = letterKeyWidth + (isPortrait ? -1 : 3) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 0 : (-14 * pixel));
        metrics.symbolPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 5; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - (i == 0 ? commaRightShift : 0) + (isPortrait ? ((i == 0 ? 1 : 0) + (i == 3 ? 2 : 0)) : ((i == 0 ? -37 : 0) + (i == 1 ? -1 : 0) + (i == 3 ? -2 : 0) + (i == 4 ? 10 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -4 : 11) * pixel;
        rect.size.width = leftShiftButtonWidth + ((i == 0 || i == 4) ? commaRightShift : 0) + (isPortrait ? ((i == 0 ? -2 : 0) + (i == 2 ? 2 : 0) + (i == 3 ? -3 : 0)) : ((i == 0 || i == 4) ? 39 : 1) + (i == 1 ? 3 : 0) + (i == 3 ? 13 : 0)) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 0 : -4);
        metrics.symbolPadFrames[2][i] = rect;
    }
    
    return metrics;
}

PhoneKeyboardMetrics getPhoneLinearKeyboardMetricsiPhone6PlusTransparent(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    const CGFloat pixel = 0.33;
    
    // TODO: not good definition
    BOOL isPortrait = (keyboardHeight == 236.0);
    CGFloat bottomRowUpShift = isPortrait? -6 : 0;
    CGFloat commaRightShift = isPortrait ? 8 : 0;
    CGFloat edgeMargin = 3.0;
    CGFloat bottomMargin = kPhoneKeyboardLandscapeHeight == keyboardHeight ? 11 : 13; // Landscape/Portrait
    CGFloat bottomMidleRowReduce = kPhoneKeyboardLandscapeHeight == keyboardHeight ? 0 : 3 - 0.5; // Landscape/Portrait
    
    CGFloat rowMargin = LINEAR_EQ(keyboardHeight, kPhoneKeyboardPortraitHeight, 11.3 - 0.1, kPhoneKeyboardLandscapeHeight, 4.5);
    CGFloat columnMargin = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 6.0, kPhoneKeyboardLandscapeWidth, 7.0);
    CGFloat keyHeight = LINEAR_EQ(keyboardHeight, kPhoneKeyboardPortraitHeight, 41.5 + 0.4, kPhoneKeyboardLandscapeHeight, 33.0);
    CGFloat letterKeyWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 26.0, kPhoneKeyboardLandscapeWidth, 50.0);
    
    CGFloat nextKeyboardButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 34.0, kPhoneKeyboardLandscapeWidth, 50.0);
    CGFloat returnButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 74.0, kPhoneKeyboardLandscapeWidth, 107.0);
    CGFloat deleteButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 36.0, kPhoneKeyboardLandscapeWidth, 69.0);
    CGFloat leftShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPhoneKeyboardPortraitWidth, 36.0, kPhoneKeyboardLandscapeWidth, 68.0);
    
    CGFloat lettersBottomRowMargin = (keyboardWidth - 7 * letterKeyWidth - 6 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    CGFloat lettersMediumRowMargin = (keyboardWidth - 9 * letterKeyWidth - 8 * columnMargin - edgeMargin * 2) / 2;
    CGFloat symbolBottomRowMargin = (keyboardWidth - 5 * leftShiftButtonWidth - 4 * columnMargin - edgeMargin * 2 - deleteButtonWidth - leftShiftButtonWidth) / 2;
    
    PhoneKeyboardMetrics metrics = {
        .numberPadButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            leftShiftButtonWidth,
            keyHeight+bottomRowUpShift
        },
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            nextKeyboardButtonWidth,
            keyHeight + bottomRowUpShift
        },
        .overlayButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            nextKeyboardButtonWidth,
            keyHeight + bottomRowUpShift
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            returnButtonWidth,
            keyHeight + bottomRowUpShift
        },
        .spaceButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight - bottomRowUpShift,
            keyboardWidth - (edgeMargin + leftShiftButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + nextKeyboardButtonWidth + columnMargin + columnMargin + returnButtonWidth + edgeMargin),
            keyHeight + bottomRowUpShift
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight) + bottomMidleRowReduce,
            deleteButtonWidth,
            keyHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight) + bottomMidleRowReduce,
            leftShiftButtonWidth,
            keyHeight
        },
        .yoButton = {
            (keyboardWidth - letterKeyWidth) / 2,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            letterKeyWidth,
            keyHeight
        },
    };
    
    CGRect rect = CGRectZero;
    
    // Real letter keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 1; i < 8; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    rect.origin.x = 0;
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][0] = rect;
    
    
    rect.origin.x = keyboardWidth - (letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin);
    rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + edgeMargin + lettersMediumRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[1][8] = rect;
    
    // 3d row
    for (int i = 1; i < 6; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + 6 * (letterKeyWidth + columnMargin) - columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = letterKeyWidth + columnMargin + lettersBottomRowMargin / 2;
    rect.size.height = keyHeight + rowMargin;
    metrics.letterPadFramesReal[2][6] = rect;
    
    // Letter keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? ((i == 2 || i == 3 || i == 4 ? -1 : 0) + (i == 5 ? -1 : 0) + (i > 5 ? -2 : 0)) : 0) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -15 : -20) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? (i == 1 ? -1 : 0) : 4) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 22 : 13) * pixel;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + lettersMediumRowMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (((i == 0 || i == 1) ? 1 : 0) + ((i== 7 || i==8) ? -1 : 0)) : ((i == 0 ? 6 : 0) + (i == 1 ? 3 : 0) + (i == 2 ? 4 : 0) + (i == 3 ? 1 : 0) + (i == 4 ? 2 : 0) + (i == 5 ? 1 : 0) + ((i == 6 || i==7) ? -1 : 0) + (i == 8 ? -3 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -2 : 9) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? ((i == 6 ? -1 : 0) + (i == 8 ? 1 : 0)) : ((i == 0 ? 1 : 0) + (i == 1 ? 5 : 0) + (i == 2 ? 1 : 0) + (i == 3 ? 5 : 0) + (i == 4 ? 3 : 0) + (i == 5 ? 2 : 0) + (i == 6 ? 4 : 0) + (i == 7 ? 2 : 0) + (i == 8 ? 3 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 5 : -14) * pixel;
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 7; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + lettersBottomRowMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? ((i == 0 ? 2 : 0) + (i == 1 || i == 2 || i == 4 ? 1 : 0)) : ((i == 0 ? 5 : 0) + (i == 1 ? 7 : 0) + (i == 2 ? 4 : 0) + (i == 3 ? 5 : 0) + (i == 4 ? 3 : 0) + (i == 5 || i == 6 ? 1 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -6 : 11) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? ((i == 0 ? -1 : 0) + ((i == 2 || i == 4) ? -1 : 0) + (i == 3 ? 1 : 0)) : ((i == 0 ? 6 : 0) + (i == 1 ? 1 : 0) + (i == 2 ? 5 : 0) + (i == 3 ? 2 : 0) + (i == 4 ? 2 : 0) + (i == 5 ? 5 : 0) + (i == 6 ? 3 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 2 : -13) * pixel;
        metrics.letterPadFrames[2][i] = rect;
    }
    
    // Real symbol keys :
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = letterKeyWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[1][i] = rect;
    }
    
    
    // 3d row
    for (int i = 1; i < 4; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
        rect.size.width = leftShiftButtonWidth + columnMargin;
        rect.size.height = keyHeight + rowMargin;
        metrics.symbolPadFramesReal[2][i] = rect;
    }
    
    rect.origin.x = edgeMargin + leftShiftButtonWidth + columnMargin / 2;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2 + bottomMidleRowReduce;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin + bottomMidleRowReduce;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][0] = rect;
    
    rect.origin.x = edgeMargin + 2*leftShiftButtonWidth + columnMargin/2 + symbolBottomRowMargin + 4*(letterKeyWidth + columnMargin) - columnMargin/2;
    rect.origin.y = keyboardHeight - bottomMargin - 2*(keyHeight + rowMargin) + rowMargin - rowMargin/2 + bottomMidleRowReduce;
    rect.size.width = leftShiftButtonWidth + symbolBottomRowMargin;
    rect.size.height = keyHeight + rowMargin;
    metrics.symbolPadFramesReal[2][4] = rect;
    
    // Symbol keys:
    // 1st row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (((i == 2 || i == 3 || i == 4) ? -1 : 0) + (i == 5 ? -1 : 0) + (i > 5 ? -2 : 0)) : 0) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -15 : -20) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? (i == 1 ? -1 : 0) : 4) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 22 : 13) * pixel;
        metrics.symbolPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) + (isPortrait ? (((i == 2 || i == 3 || i == 4) ? -1 : 0) + (i == 5 ? -1 : 0) + (i > 5 ? -2 : 0)) : 0) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -2 : 9) * pixel;
        rect.size.width = letterKeyWidth + (isPortrait ? (i == 1 ? -1 : 0) : 4) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 5 : -14) * pixel;
        metrics.symbolPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 5; ++i) {
        rect.origin.x = edgeMargin + leftShiftButtonWidth + symbolBottomRowMargin + i * (leftShiftButtonWidth + columnMargin) - (i == 0 ? commaRightShift : 0) + (isPortrait ? ((i == 0 ? -1 : 0) + ((i == 1 || i == 2 || i == 3) ? 1 : 0)) : ((i == 0 ? -41 : 0) + ((i == 1 || i == 2) ? -1 : 0) + (i == 3 ? -2 : 0) + (i == 4 ? 11 : 0))) * pixel;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin + bottomMidleRowReduce + (isPortrait ? -6 : 11) * pixel;
        rect.size.width = leftShiftButtonWidth + ((i == 0 || i == 4) ? commaRightShift : 0) + (isPortrait ? ((i == 3 ? -1 : 0) + ((i == 0 || i==4) ? 2 : 0)) : ((i == 0 ? 44 : 0) + (i == 1 ? 4 : 0) + (i == 2 ? 3 : 0) + (i == 3 ? 17 : 0) + (i == 4 ? 39 : 0))) * pixel;
        rect.size.height = keyHeight + (isPortrait ? 2 : -13) * pixel;
        metrics.symbolPadFrames[2][i] = rect;
    }
    
    return metrics;
}

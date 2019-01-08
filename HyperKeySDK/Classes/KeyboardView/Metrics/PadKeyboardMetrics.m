//
//  PadKeyboardMetrics.c
//  ACKeyboard
//
//  Created by Arnaud Coomans on 10/12/14.
//
//

#import "PadKeyboardMetrics.h"

#import "Linear.h"
#import "UIScreen+Orientation.h"

CGFloat const kPadKeyboardPortraitWidth = 768.0;
CGFloat const kPadKeyboardLandscapeWidth = 1024.0;
CGFloat const kPadKeyboardPortraitHeight = 264.0;
CGFloat const kPadKeyboardLandscapeHeight = 352.0;


PadKeyboardMetrics getPadLinearKeyboardMetrics(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    CGFloat edgeMargin = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 6.0, kPadKeyboardLandscapeWidth, 7.0);
    CGFloat bottomMargin = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 7.0, kPadKeyboardLandscapeHeight, 9.0);
    CGFloat columnMargin = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 12.0, kPadKeyboardLandscapeWidth, 14.0);
    CGFloat rowMargin = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 8.0, kPadKeyboardLandscapeHeight, 11.0);
    CGFloat keyHeight = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 56.0, kPadKeyboardLandscapeHeight, 75.0);
    CGFloat letterKeyWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 57.0, kPadKeyboardLandscapeWidth, 78.0);
    CGFloat returnButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 106.0, kPadKeyboardLandscapeWidth, 144.0);
    CGFloat rightShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 76.0, kPadKeyboardLandscapeWidth, 105.0);
    CGFloat lastRowExtraMargin = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 2.0, kPadKeyboardLandscapeHeight, 0.0);
    
    CGFloat lastRowHeight = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 58.0, kPadKeyboardLandscapeHeight, 75.0);
    CGFloat deleteButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 61.0, kPadKeyboardLandscapeWidth, 80.0);
    CGFloat leftShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 56.0, kPadKeyboardLandscapeWidth, 77.0);
    
    CGFloat bottomRowLetterKeyWidth = (keyboardWidth - 3 * letterKeyWidth - 2 * edgeMargin - 7 * columnMargin) / 6;
    
    PadKeyboardMetrics metrics = {
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            returnButtonWidth,
            keyHeight
        },
        .spaceButtonFrame = {
            edgeMargin + 3 * (leftShiftButtonWidth + columnMargin),
            keyboardHeight - bottomMargin - keyHeight,
            keyboardWidth - (edgeMargin + 4 * leftShiftButtonWidth + rightShiftButtonWidth + 5 * columnMargin + edgeMargin),
            keyHeight
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight + lastRowExtraMargin),
            deleteButtonWidth,
            lastRowHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            leftShiftButtonWidth,
            keyHeight
        },
        .rightShiftButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            deleteButtonWidth,
            keyHeight
        },
        .hideButtonFrame = {
            keyboardWidth - edgeMargin - leftShiftButtonWidth,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .leftNumberButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .rightNumberButtonFrame = {
            keyboardWidth - edgeMargin - leftShiftButtonWidth - rightShiftButtonWidth - columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            rightShiftButtonWidth,
            keyHeight
        },
        .overlayButtonFrame = {
            edgeMargin + 2 * (leftShiftButtonWidth + columnMargin),
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
    };
    
    CGRect rect = CGRectZero;
    
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth / 2 + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[2][i] = rect;
    }
    
    for (int i = 0; i < 6; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (bottomRowLetterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = bottomRowLetterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[3][i] = rect;
    }

    
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth / 2 + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 6; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (bottomRowLetterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = bottomRowLetterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[3][i] = rect;
    }

    rect.origin.x = edgeMargin + letterKeyWidth + columnMargin;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
    rect.size.width = 2 * letterKeyWidth + columnMargin;
    rect.size.height = keyHeight;
    metrics.undoButtonFrame = rect;

    return metrics;
}


#pragma mark - Transparent Theme

PadKeyboardMetrics getPadLinearKeyboardMetricsTransparent(CGFloat keyboardWidth, CGFloat keyboardHeight) {
    CGFloat edgeMargin = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 6.0, kPadKeyboardLandscapeWidth, 7.0);
    CGFloat bottomMargin = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 7.0, kPadKeyboardLandscapeHeight, 9.0);
    CGFloat columnMargin = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 12.0, kPadKeyboardLandscapeWidth, 14.0);
    CGFloat rowMargin = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 8.0, kPadKeyboardLandscapeHeight, 11.0);
    CGFloat keyHeight = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 56.0, kPadKeyboardLandscapeHeight, 75.0);
    CGFloat letterKeyWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 57.0, kPadKeyboardLandscapeWidth, 78.0);
    CGFloat returnButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 106.0, kPadKeyboardLandscapeWidth, 144.0);
    CGFloat rightShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 76.0, kPadKeyboardLandscapeWidth, 105.0);
    CGFloat lastRowExtraMargin = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 2.0, kPadKeyboardLandscapeHeight, 0.0);
    
    CGFloat lastRowHeight = LINEAR_EQ(keyboardHeight, kPadKeyboardPortraitHeight, 58.0, kPadKeyboardLandscapeHeight, 75.0);
    CGFloat deleteButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 61.0, kPadKeyboardLandscapeWidth, 80.0);
    CGFloat leftShiftButtonWidth = LINEAR_EQ(keyboardWidth, kPadKeyboardPortraitWidth, 56.0, kPadKeyboardLandscapeWidth, 77.0);
    
    CGFloat bottomRowLetterKeyWidth = (keyboardWidth - 3 * letterKeyWidth - 2 * edgeMargin - 7 * columnMargin) / 6;
    
    PadKeyboardMetrics metrics = {
        .nextKeyboardButtonFrame = {
            edgeMargin + leftShiftButtonWidth + columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .returnButtonFrame = {
            keyboardWidth - edgeMargin - returnButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight),
            returnButtonWidth,
            keyHeight
        },
        .spaceButtonFrame = {
            edgeMargin + 3 * (leftShiftButtonWidth + columnMargin),
            keyboardHeight - bottomMargin - keyHeight,
            keyboardWidth - (edgeMargin + 4 * leftShiftButtonWidth + rightShiftButtonWidth + 5 * columnMargin + edgeMargin),
            keyHeight
        },
        .deleteButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight + rowMargin + keyHeight + lastRowExtraMargin),
            deleteButtonWidth,
            lastRowHeight
        },
        .leftShiftButtonFrame = {
            edgeMargin,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            leftShiftButtonWidth,
            keyHeight
        },
        .rightShiftButtonFrame = {
            keyboardWidth - edgeMargin - deleteButtonWidth,
            keyboardHeight - (bottomMargin + keyHeight + rowMargin + keyHeight),
            deleteButtonWidth,
            keyHeight
        },
        .hideButtonFrame = {
            keyboardWidth - edgeMargin - leftShiftButtonWidth,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .leftNumberButtonFrame = {
            edgeMargin,
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
        .rightNumberButtonFrame = {
            keyboardWidth - edgeMargin - leftShiftButtonWidth - rightShiftButtonWidth - columnMargin,
            keyboardHeight - bottomMargin - keyHeight,
            rightShiftButtonWidth,
            keyHeight
        },
        .overlayButtonFrame = {
            edgeMargin + 2 * (leftShiftButtonWidth + columnMargin),
            keyboardHeight - bottomMargin - keyHeight,
            leftShiftButtonWidth,
            keyHeight
        },
    };
    
    CGRect rect = CGRectZero;
    
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth / 2 + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (letterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = letterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[2][i] = rect;
    }
    
    for (int i = 0; i < 6; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (bottomRowLetterKeyWidth + columnMargin);
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
        rect.size.width = bottomRowLetterKeyWidth;
        rect.size.height = keyHeight;
        metrics.letterPadFrames[3][i] = rect;
    }
    
    for (int i = 0; i < 10; ++i) {
        rect.origin.x = edgeMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 4 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin-1;
        metrics.letterPadFramesReal[0][i] = rect;
    }
    
    // 2d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth / 2 + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 3 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[1][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 9; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (letterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = letterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[2][i] = rect;
    }
    
    // 3d row
    for (int i = 0; i < 6; ++i) {
        rect.origin.x = edgeMargin + letterKeyWidth + columnMargin + i * (bottomRowLetterKeyWidth + columnMargin) - columnMargin / 2;
        rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin - rowMargin / 2;
        rect.size.width = bottomRowLetterKeyWidth + columnMargin - 1;
        rect.size.height = keyHeight + rowMargin - 1;
        metrics.letterPadFramesReal[3][i] = rect;
    }
    
    rect.origin.x = edgeMargin + letterKeyWidth + columnMargin;
    rect.origin.y = keyboardHeight - bottomMargin - 2 * (keyHeight + rowMargin) + rowMargin;
    rect.size.width = 2 * letterKeyWidth + columnMargin;
    rect.size.height = keyHeight;
    metrics.undoButtonFrame = rect;
    
    return metrics;
}
//
//  KeyboardView.m
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/17/14.
//
//

#import "KeyboardView.h"

#import "ACKeyMat.h"
#import "ACLockKey.h"
#import "ACActivatedKey.h"
#import "ACLockActivatedKey.h"
#import "UIImage+Resize.h"
#import "Config.h"
#import "Macroses.h"
#import "KeyboardConfig.h"
#import "UIImage+Additions.h"
#import "UIFont+Hyperkey.h"

#import <mach/mach.h>

NSString *const kKeyboardViewRowComponentSeparator = @" ";

NSUInteger const kKeyboardViewACKeyOvelayTag = -12;

@interface KeyboardView () <UIGestureRecognizerDelegate>

@property (assign, nonatomic) KBTheme currentKBTheme;
@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) ACKey *spaceButton;

@property (assign, nonatomic) BOOL letterPadCreated;
@property (assign, nonatomic) BOOL numberPadCreated;
@property (assign, nonatomic) BOOL symbolPadCreated;
@property (assign, nonatomic) BOOL sizesCreated;
@property (assign, nonatomic) PhoneKeyboardMetrics phoneKeyboardMetrics;
@property (assign, nonatomic) PadKeyboardMetrics padKeyboardMetrics;
@property (assign, nonatomic) CGSize currentSize;

// iPad:
@property (strong, nonatomic) ACKey *hideButton;
@property (strong, nonatomic) ACKey *leftNumberPadButton;
@property (strong, nonatomic) ACKey *rightNumberPadButton;
@property (strong, nonatomic) NSArray *letterPadTopRowPad;
@property (strong, nonatomic) NSArray *letterPadMiddleRowPad;
@property (strong, nonatomic) NSArray *letterPadBottomRowPad;
@property (strong, nonatomic) NSArray *letterPadTopRowPadReal;
@property (strong, nonatomic) NSArray *letterPadMiddleRowPadReal;
@property (strong, nonatomic) NSArray *letterPadBottomRowPadReal;
@property (strong, nonatomic) ACKey *undoButton;
@property (strong, nonatomic) ACKey *redoButton;
@property (strong, nonatomic) ACKey *leftSymbolPadButtonPad;
@property (strong, nonatomic) ACKey *rightSymbolPadButtonPad;
@property (strong, nonatomic) ACKey *leftLetterPadButtonPad;
@property (strong, nonatomic) ACKey *rightLetterPadButtonPad;
@property (strong, nonatomic) ACKey *leftNumberPadButtonOnSymbolPad;
@property (strong, nonatomic) ACKey *rightNumberPadButtonOnSymbolPad;

@property (strong, nonatomic) ACKey *numberPadButton;
@property (strong, nonatomic) ACKey *symbolPadButton;
@property (strong, nonatomic) ACKey *letterPadButton;
@property (strong, nonatomic) ACKey *numberPadButtonOnSymbolPad;

@property (strong, nonatomic) NSArray *letterPadTopRow;
@property (strong, nonatomic) NSArray *letterPadMiddleRow;
@property (strong, nonatomic) NSArray *letterPadBottomRow;
@property (strong, nonatomic) NSArray *letterPadTopRowReal;
@property (strong, nonatomic) NSArray *letterPadMiddleRowReal;
@property (strong, nonatomic) NSArray *letterPadBottomRowReal;

@property (strong, nonatomic) NSArray *symbolPadTopRow;
@property (strong, nonatomic) NSArray *symbolPadMiddleRow;
@property (strong, nonatomic) NSArray *symbolPadBottomRow;
@property (strong, nonatomic) NSArray *symbolPadTopRowReal;
@property (strong, nonatomic) NSArray *symbolPadMiddleRowReal;
@property (strong, nonatomic) NSArray *symbolPadBottomRowReal;

@property (strong, nonatomic) UIImageView *cellImage;

@end

@implementation KeyboardView

- (instancetype)init {
    if (self = [super init]) {
        self.letterPadCreated = NO;
        self.numberPadCreated = NO;
        self.symbolPadCreated = NO;
        self.currentPad = KeyboardViewPadTypeLetter;
        
        self.isPortraitOrientation = YES;
        self.cellImage = [[UIImageView alloc] init];
        [self addSubview:self.cellImage];
        [self updateCellImage];
    }
    return self;
}


#pragma mark - Property

- (void)setCurrentPad:(KeyboardViewPadType)currentPad {
    _currentPad = currentPad;
    
    [self updateCellImage];
}

- (void)updateCellImage {
    if (self.currentKBTheme != KBThemeTransparent) {
        return;
    }
    
    NSString *imageName = nil;
    if (IS_IPAD) {
        if (self.currentPad == KeyboardViewPadTypeLetter) {
            imageName = (self.isPortraitOrientation) ? @"cell_iPad_landscape" : @"cell_iPad_portrait";
        } else {
            imageName = (self.isPortraitOrientation) ? @"cell_iPad_landscape_num" : @"cell_iPad_portrait_num";
        }
    } else {
        if (IS_IPHONE_5) {
            if (self.currentPad == KeyboardViewPadTypeLetter) {
                imageName = (self.isPortraitOrientation) ? @"cell_i5_landscape" : @"cell_i5_portrait";
            } else {
                imageName = (self.isPortraitOrientation) ? @"cell_i5_landscape_num" : @"cell_i5_portrait_num";
            }
        } else if (IS_IPHONE_6) {
            if (self.currentPad == KeyboardViewPadTypeLetter) {
                imageName = (self.isPortraitOrientation) ? @"cell_i6_landscape" : @"cell_i6_portrait";
            } else {
                imageName = (self.isPortraitOrientation) ? @"cell_i6_landscape_num" : @"cell_i6_portrait_num";
            }
            
        } else if (IS_IPHONE_6_PLUS) {
            if (self.currentPad == KeyboardViewPadTypeLetter) {
                imageName = (self.isPortraitOrientation) ? @"cell_i6p_landscape" : @"cell_i6p_portrait";
            } else {
                imageName = (self.isPortraitOrientation) ? @"cell_i6p_landscape_num" : @"cell_i6p_portrait_num";
            }
        }
    }

    self.cellImage.image = [[UIImage imageNamed:imageName] tranlucentWithAlpha:0.1];
}

- (void)arrangeKeys {
    if (IS_IPAD) {
        self.deleteButton.frame = self.padKeyboardMetrics.deleteButtonFrame;
        self.deleteButton.cornerRadius = self.cornerRadius;
        
        self.leftNumberPadButton.frame = self.padKeyboardMetrics.leftNumberButtonFrame;
        self.leftNumberPadButton.cornerRadius = self.cornerRadius;
        
        self.overlayButton.frame = self.padKeyboardMetrics.overlayButtonFrame;
        self.overlayButton.cornerRadius = self.cornerRadius;
        
        self.hideButton.frame = self.padKeyboardMetrics.hideButtonFrame;
        self.hideButton.cornerRadius = self.cornerRadius;
        
        self.rightNumberPadButton.frame = self.padKeyboardMetrics.rightNumberButtonFrame;
        self.rightNumberPadButton.cornerRadius = self.cornerRadius;
        
        for (int i = 0; i < [self.letterPadTopRowPad count]; i ++) {
            [self.letterPadTopRowPad[i] setFrame:self.padKeyboardMetrics.letterPadFrames[0][i]];
            [(ACKey *)(self.letterPadTopRowPad[i]) setCornerRadius:self.cornerRadius];
            [self.letterPadTopRowPadReal[i] setFrame:self.padKeyboardMetrics.letterPadFramesReal[0][i]];
        }
        
        NSUInteger middleLineRowCount = [self.letterPadMiddleRow count];
        for (int i = 0; i < [self.letterPadMiddleRow count]; i ++) {
            if (middleLineRowCount == 9) {
                [self.letterPadMiddleRow[i] setFrame:self.phoneKeyboardMetrics.letterPadFrames[1][i]];
                [self.letterPadMiddleRowReal[i] setFrame:self.phoneKeyboardMetrics.letterPadFramesReal[1][i]];
            } else {
                [self.letterPadMiddleRow[i] setFrame:self.phoneKeyboardMetrics.symbolPadFrames[1][i]];
                [self.letterPadMiddleRowReal[i] setFrame:self.phoneKeyboardMetrics.letterPadFramesReal[1][i]];
            }
            [(ACKey *)self.letterPadMiddleRow[i] setCornerRadius:self.cornerRadius];
        }

        for (int i = 0; i < [self.letterPadMiddleRowPad count]; i ++) {
            [self.letterPadMiddleRowPad[i] setFrame:self.padKeyboardMetrics.letterPadFrames[1][i]];
            [(ACKey *)self.letterPadMiddleRowPad[i] setCornerRadius:self.cornerRadius];
            [self.letterPadMiddleRowPadReal[i] setFrame:self.padKeyboardMetrics.letterPadFramesReal[1][i]];
        }
        
        NSInteger secondIndex = (self.currentPad == KeyboardViewPadTypeLetter) ? 2 : 3;
        for (int i = 0; i < [self.letterPadBottomRowPad count]; i ++) {
            [self.letterPadBottomRowPad[i] setFrame:self.padKeyboardMetrics.letterPadFrames[secondIndex][i]];
            [(ACKey *)self.letterPadBottomRowPad[i] setCornerRadius:self.cornerRadius];
            [self.letterPadBottomRowPadReal[i] setFrame:self.padKeyboardMetrics.letterPadFramesReal[secondIndex][i]];
        }
        
        if (self.currentPad == KeyboardViewPadTypeNumber || self.currentPad == KeyboardViewPadTypeSymbol) {
            self.leftSymbolPadButtonPad.frame = self.padKeyboardMetrics.leftShiftButtonFrame;
            self.leftSymbolPadButtonPad.cornerRadius = self.cornerRadius;
            
            self.rightSymbolPadButtonPad.frame = self.padKeyboardMetrics.rightShiftButtonFrame;
            self.rightSymbolPadButtonPad.cornerRadius = self.cornerRadius;
            
            self.leftLetterPadButtonPad.frame = self.padKeyboardMetrics.leftNumberButtonFrame;
            self.leftLetterPadButtonPad.cornerRadius = self.cornerRadius;
            
            self.rightLetterPadButtonPad.frame = self.padKeyboardMetrics.rightNumberButtonFrame;
            self.rightLetterPadButtonPad.cornerRadius = self.cornerRadius;
            
            self.leftNumberPadButtonOnSymbolPad.frame = self.padKeyboardMetrics.leftShiftButtonFrame;
            self.leftNumberPadButtonOnSymbolPad.cornerRadius = self.cornerRadius;
            
            self.rightNumberPadButtonOnSymbolPad.frame = self.padKeyboardMetrics.rightShiftButtonFrame;
            self.rightNumberPadButtonOnSymbolPad.cornerRadius = self.cornerRadius;
        }
        
        self.returnButton.frame = self.padKeyboardMetrics.returnButtonFrame;
        self.returnButton.cornerRadius = self.cornerRadius;
        
        self.leftShiftButton.frame = self.padKeyboardMetrics.leftShiftButtonFrame;
        self.leftShiftButton.cornerRadius = self.cornerRadius;
        self.rightShiftButton.frame = self.padKeyboardMetrics.rightShiftButtonFrame;
        self.rightShiftButton.cornerRadius = self.cornerRadius;
        
        self.nextKeyboardButton.frame = self.padKeyboardMetrics.nextKeyboardButtonFrame;
        self.nextKeyboardButton.cornerRadius = self.cornerRadius;
        self.spaceButton.frame = self.padKeyboardMetrics.spaceButtonFrame;
        self.spaceButton.cornerRadius = self.cornerRadius;
    } else {
        [self createLetterPadPhone];
        if (self.currentPad == KeyboardViewPadTypeLetter) {
            [self showLetterPad];
            self.currentPad = KeyboardViewPadTypeLetter;
        }
        
        self.overlayButton.frame = self.phoneKeyboardMetrics.overlayButtonFrame;
        self.overlayButton.cornerRadius = self.cornerRadius;
        
        self.deleteButton.frame = self.phoneKeyboardMetrics.deleteButtonFrame;
        self.deleteButton.cornerRadius = self.cornerRadius;
        
        self.nextKeyboardButton.frame = self.phoneKeyboardMetrics.nextKeyboardButtonFrame;
        self.nextKeyboardButton.cornerRadius = self.cornerRadius;
        
        self.spaceButton.frame = self.phoneKeyboardMetrics.spaceButtonFrame;
        self.spaceButton.cornerRadius = self.cornerRadius;
        
        self.returnButton.frame = self.phoneKeyboardMetrics.returnButtonFrame;
        self.returnButton.cornerRadius = self.cornerRadius;
        
        self.letterPadButton.cornerRadius = self.cornerRadius;
    }
}

- (void)recalculateFramesForSize:(CGSize)newSize {
    self.currentSize = newSize;
    
    CGRect frame = self.cellImage.frame;
    frame.size = newSize;
    frame.origin = CGPointZero;
    self.cellImage.frame = frame;
    
    [self updateCellImage];
    [self updateLinearKeyboardMetrics];
    [self arrangeKeys];
}

- (PhoneKeyboardMetrics)phoneKeyboardMetrics {
    return _phoneKeyboardMetrics;
}

- (PadKeyboardMetrics)padKeyboardMetrics {
    return _padKeyboardMetrics;
}

- (void)createLetterPadPhone {
    for (int i = 0; i < [self.letterPadTopRow count]; i ++) {
        [self.letterPadTopRow[i] setFrame:self.phoneKeyboardMetrics.letterPadFrames[0][i]];
        [self.letterPadTopRowReal[i] setFrame:self.phoneKeyboardMetrics.letterPadFramesReal[0][i]];
        [(ACKey*)self.letterPadTopRow[i] setCornerRadius:self.cornerRadius];
    }
    
    NSUInteger middleLineRowCount = [self.letterPadMiddleRow count];
    for (int i = 0; i < [self.letterPadMiddleRow count]; i ++) {
        if (middleLineRowCount == 9) {
            [self.letterPadMiddleRow[i] setFrame:self.phoneKeyboardMetrics.letterPadFrames[1][i]];
            [self.letterPadMiddleRowReal[i] setFrame:self.phoneKeyboardMetrics.letterPadFramesReal[1][i]];
        } else {
            [self.letterPadMiddleRow[i] setFrame:self.phoneKeyboardMetrics.symbolPadFrames[1][i]];
            [self.letterPadMiddleRowReal[i] setFrame:self.phoneKeyboardMetrics.symbolPadFramesReal[1][i]];
        }
        
        [(ACKey *)self.letterPadMiddleRow[i] setCornerRadius:self.cornerRadius];
    }
    for (int i = 0; i < [self.letterPadBottomRow count]; i ++) {
        
        [self.letterPadBottomRow[i] setFrame:self.phoneKeyboardMetrics.letterPadFrames[2][i]];
        [self.letterPadBottomRowReal[i] setFrame:self.phoneKeyboardMetrics.letterPadFramesReal[2][i]];
        [(ACKey *)self.letterPadBottomRow[i] setCornerRadius:self.cornerRadius];
    }
    self.numberPadButton.frame = self.phoneKeyboardMetrics.numberPadButtonFrame;
    self.numberPadButton.cornerRadius = self.cornerRadius;
    
    self.leftShiftButton.frame = self.phoneKeyboardMetrics.leftShiftButtonFrame;
    self.leftShiftButton.cornerRadius = self.cornerRadius;
    
    for (int i = 0; i < [self.symbolPadTopRowReal count]; i ++) {
        [self.symbolPadTopRowReal[i] setFrame:self.phoneKeyboardMetrics.symbolPadFramesReal[0][i]];
    }
    for (int i = 0; i < [self.symbolPadMiddleRowReal count]; i ++) {
        [self.symbolPadMiddleRowReal[i] setFrame:self.phoneKeyboardMetrics.symbolPadFramesReal[1][i]];
    }
    for (int i = 0;i < [self.symbolPadBottomRowReal count]; i ++) {
        [self.symbolPadBottomRowReal[i] setFrame:self.phoneKeyboardMetrics.symbolPadFramesReal[2][i]];
    }
    for (int i = 0; i < [self.symbolPadTopRow count]; i ++) {
        [self.symbolPadTopRow[i] setFrame:self.phoneKeyboardMetrics.symbolPadFrames[0][i]];
        [(ACKey *)self.symbolPadTopRow[i] setCornerRadius:self.cornerRadius];
    }
    for (int i = 0; i < [self.symbolPadMiddleRow count]; i ++) {
        [self.symbolPadMiddleRow[i] setFrame:self.phoneKeyboardMetrics.symbolPadFrames[1][i]];
        [(ACKey *)self.symbolPadMiddleRow[i] setCornerRadius:self.cornerRadius];
    }
    for (int i = 0; i < [self.symbolPadBottomRow count]; i ++) {
        [self.symbolPadBottomRow[i] setFrame:self.phoneKeyboardMetrics.symbolPadFrames[2][i]];
        [(ACKey *)self.symbolPadBottomRow[i] setCornerRadius:self.cornerRadius];
    }
    
    self.letterPadButton.frame = self.phoneKeyboardMetrics.numberPadButtonFrame;
    self.symbolPadButton.frame = self.phoneKeyboardMetrics.leftShiftButtonFrame;
    self.symbolPadButton.cornerRadius = self.cornerRadius;
    self.numberPadButtonOnSymbolPad.frame = self.phoneKeyboardMetrics.leftShiftButtonFrame;
    
    [self updateCapitalizationOfKeys];
}

- (void)showLetterPad {
    [self hideSymbolPad];
    [self.numberPadButtonOnSymbolPad removeFromSuperview];
    for (ACKey *key in self.letterPadTopRowReal) {
        [self addSubview:key];
    }
    for (ACKey *key in self.letterPadMiddleRowReal) {
        [self addSubview:key];
    }
    for (ACKey *key in self.letterPadBottomRowReal) {
        [self addSubview:key];
    }
    for (ACKey *key in self.letterPadTopRow) {
        [self addSubview:key];
    }
    for (ACKey *key in self.letterPadMiddleRow) {
        [self addSubview:key];
    }
    for (ACKey *key in self.letterPadBottomRow) {
        [self addSubview:key];
    }
    [self addSubview:self.numberPadButton];
    [self addSubview:self.leftShiftButton];
}

- (void)hideLetterPad {
    for (ACKey *key in self.letterPadTopRowReal) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.letterPadMiddleRowReal) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.letterPadBottomRowReal) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.letterPadTopRow) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.letterPadMiddleRow) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.letterPadBottomRow) {
        [key removeFromSuperview];
    }
    
    [self.numberPadButton removeFromSuperview];
    [self.leftShiftButton removeFromSuperview];
}

- (void)showSymbolPad {
    [self hideLetterPad];
    [self addSubview:self.numberPadButtonOnSymbolPad];
    for (ACKey *key in self.symbolPadTopRowReal) {
        [self addSubview:key];
    }
    for (ACKey *key in self.symbolPadMiddleRowReal) {
        [self addSubview:key];
    }
    for (ACKey *key in self.symbolPadBottomRowReal) {
        [self addSubview:key];
    }
    for (ACKey *key in self.symbolPadTopRow) {
        [self addSubview:key];
    }
    for (ACKey *key in self.symbolPadMiddleRow) {
        [self addSubview:key];
    }
    for (ACKey *key in self.symbolPadBottomRow) {
        [self addSubview:key];
    }
    
    self.letterPadButton.appearance = self.keyAppearance;
    self.symbolPadButton.appearance = self.keyAppearance;
    self.numberPadButtonOnSymbolPad.appearance = self.keyAppearance;
    
    [self addSubview:self.letterPadButton];
    [self addSubview:self.symbolPadButton];
}

- (void)hideSymbolPad {
    for (ACKey *key in self.symbolPadTopRowReal) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.symbolPadMiddleRowReal) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.symbolPadBottomRowReal) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.symbolPadTopRow) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.symbolPadMiddleRow) {
        [key removeFromSuperview];
    }
    for (ACKey *key in self.symbolPadBottomRow) {
        [key removeFromSuperview];
    }
    [self.letterPadButton removeFromSuperview];
    [self.symbolPadButton removeFromSuperview];
    [self.numberPadButtonOnSymbolPad removeFromSuperview];
}

- (void)changeSymbolToNumberPad {
    [self.numberPadButtonOnSymbolPad removeFromSuperview];
    self.symbolPadButton.frame = self.phoneKeyboardMetrics.leftShiftButtonFrame;
    [self addSubview:self.symbolPadButton];

    NSString *row = NSLocalizedStringFromTable(@"numberPadTop", kLocalizedTableSymbols, @"1 2 3 4 5 6 7 8 9 0 by default");
    NSArray *characters1 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"numberPadMiddleFull", kLocalizedTableSymbols, @"- / : ; ( ) $ & @ \ by default");
    NSArray *characters2 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    for (int i = 0; i < [self.symbolPadTopRow count]; ++i) {
        [self.symbolPadTopRow[i] setTitle:characters1[i]];
    }
    for (int i = 0; i < [self.symbolPadMiddleRow count]; ++i) {
        [self.symbolPadMiddleRow[i] setTitle:characters2[i]];
    }
}

- (void)changeNumberToSymbolPad {
    [self.symbolPadButton removeFromSuperview];
    [self addSubview:self.numberPadButtonOnSymbolPad];
    
    NSString *row = NSLocalizedStringFromTable(@"symbolPadTop", kLocalizedTableSymbols, @"[ ] { } # % ^ * + = by default");
    NSArray *characters1 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"symbolPadMiddle", kLocalizedTableSymbols, @"_ \ | ~ < > $ € £ ・ by default");
    NSArray *characters2 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];

    for (int i = 0; i < [self.symbolPadTopRow count]; ++i) {
        [self.symbolPadTopRow[i] setTitle:characters1[i]];
    }
    for (int i = 0; i < [self.symbolPadMiddleRow count]; ++i) {
        [self.symbolPadMiddleRow[i] setTitle:characters2[i]];
    }
}

- (CGFloat)cornerRadius {
    return cornerRadiusForTheme(self.currentKBTheme);
}

- (ACKey *)nextKeyboardButton {
    if (!_nextKeyboardButton) {
        _nextKeyboardButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:[UIImage imageNamed:@"global_portrait"]];
        [self.delegate setupNewNextKeyboardButton:_nextKeyboardButton];
        [self addSubview:_nextKeyboardButton];
        
        _nextKeyboardButton.needHighlighting = YES;
    }
    return _nextKeyboardButton;
}

- (ACKey *)returnButton {
    if (!_returnButton) {
        NSString *title = NSLocalizedStringFromTable(@"returnTitle", kLocalizedTableSymbols, @"title for return button");
        _returnButton = [ACKey keyWithStyle:ACKeyStyleBlue appearance:self.keyAppearance title:title];
        _returnButton.titleFont = [self currentFontSmall];
        [_returnButton addTarget:self action:@selector(returnButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_returnButton];
        
        _returnButton.needHighlighting = YES;
    }
    return _returnButton;
}

- (ACKey *)leftNumberPadButton {
    if (!_leftNumberPadButton) {
        _leftNumberPadButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@".?123"];
        _leftNumberPadButton.titleFont = [self currentFontSmall];
        [_leftNumberPadButton addTarget:self action:@selector(numberPadButtonPressedPad) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_leftNumberPadButton];
    }
    return _leftNumberPadButton;
}

- (ACKey *)hideButton {
    if (!_hideButton) {
        UIImage *image = [[UIImage imageNamed:@"kb_dismiss_pad.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _hideButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:image];
        [_hideButton addTarget:self action:@selector(hidePressedPad) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_hideButton];
    }
    return _hideButton;
}

- (ACKey *)rightNumberPadButton {
    if (!_rightNumberPadButton) {
        _rightNumberPadButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@".?123"];
        _rightNumberPadButton.titleFont = [self currentFontSmall];
        [_rightNumberPadButton addTarget:self action:@selector(numberPadButtonPressedPad) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightNumberPadButton];
    }
    return _rightNumberPadButton;
}

- (ACKey *)spaceButton {
    if (!_spaceButton) {
        if (IS_IPAD) {
            _spaceButton = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance];
        } else {
            NSString *title = NSLocalizedStringFromTable(@"spaceTitle", kLocalizedTableSymbols, @"title for space button");
            _spaceButton = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:title];
        }
        _spaceButton.titleFont = [self currentFontSmall];
        [_spaceButton addTarget:self action:@selector(spaceButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_spaceButton];
        //TODO: Enable setting self.requireQuickPeriod
        _spaceButton.needHighlighting = YES;
    }
    return _spaceButton;
}

- (ACKey *)deleteButton {
    if (!_deleteButton) {
        UIImage *image = [[UIImage imageNamed:@"delete_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _deleteButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:image];
        [self addSubview:_deleteButton];
        
        [self.delegate setupNewDeleteButton:_deleteButton];
    }
    return _deleteButton;
}

- (ACKey *)numberPadButton {
    if (!_numberPadButton) {
        _numberPadButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"123"];
        _numberPadButton.titleFont = [self currentFontSmall];
        [_numberPadButton addTarget:self action:@selector(numberPadButtonTapped:) forControlEvents:UIControlEventTouchDown];
        
        _numberPadButton.needHighlighting = YES;
    }
    return _numberPadButton;
}

- (ACKey *)symbolPadButton {
    if (!_symbolPadButton) {
        _symbolPadButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"#+="];
        _symbolPadButton.titleFont = [self currentFontSmall];
        [_symbolPadButton addTarget:self action:@selector(symbolPadButtonTapped:) forControlEvents:UIControlEventTouchDown];
    }
    return _symbolPadButton;
}

- (ACKey *)letterPadButton {
    if (!_letterPadButton) {
        _letterPadButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"ABC"];
        _letterPadButton.titleFont = [self currentFontSmall];
        [_letterPadButton addTarget:self action:@selector(letterPadButtonTapped:) forControlEvents:UIControlEventTouchDown];
        
        _letterPadButton.needHighlighting = YES;
    }
    return _letterPadButton;
}

- (ACKey *)numberPadButtonOnSymbolPad {
    if (!_numberPadButtonOnSymbolPad) {
        _numberPadButtonOnSymbolPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"123"];
        _numberPadButtonOnSymbolPad.titleFont = [self currentFontSmall];
        [_numberPadButtonOnSymbolPad addTarget:self action:@selector(numberPadButtonOnSymbolPadTapped:) forControlEvents:UIControlEventTouchDown];
    }
    return _numberPadButtonOnSymbolPad;
}

- (ACKey *)overlayButton {
    if (!_overlayButton) {
        UIImage *image = [UIImage imageNamed:@"kb_main_icon"];
        _overlayButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:image];
        _overlayButton.tag = kKeyboardViewACKeyOvelayTag;
        [_overlayButton addTarget:self action:@selector(overlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_overlayButton];
        
        _overlayButton.needHighlighting = YES;
    }
    return _overlayButton;
}

- (ACLockKey *)leftShiftButton {
    if (!_leftShiftButton) {
        _leftShiftButton = [ACLockKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance];
        _leftShiftButton.image = [[UIImage imageNamed:@"shift_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _leftShiftButton.lockImage = [[UIImage imageNamed:@"shift_lock_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_leftShiftButton addTarget:self action:@selector(shiftButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [_leftShiftButton addTarget:self action:@selector(shiftButtonDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];
        [self addSubview:_leftShiftButton];
    }
    return _leftShiftButton;
}

- (ACLockKey *)rightShiftButton {
    if (!_rightShiftButton) {
        _rightShiftButton = [ACLockKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance];
        _rightShiftButton.image = [[UIImage imageNamed:@"shift_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _rightShiftButton.lockImage = [[UIImage imageNamed:@"shift_lock_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_rightShiftButton addTarget:self action:@selector(shiftButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [_rightShiftButton addTarget:self action:@selector(shiftButtonDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];
        [self addSubview:_rightShiftButton];
    }
    return _rightShiftButton;
}


#pragma mark - Define mass keys for iPhone

- (NSArray *)letterPadTopRow {
    if (!_letterPadTopRow) {
        NSString *row = NSLocalizedStringFromTable(@"letterPadTop", kLocalizedTableSymbols, @"Q W E R T Y U I P by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [key setTitleFont:[self currentFontRegular]];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
        }
        _letterPadTopRow = [[NSArray alloc] initWithArray:buttons];
        _letterPadTopRowReal = [[NSArray alloc] initWithArray:mats];
    }
    return _letterPadTopRow;
}

- (NSArray *)letterPadTopRowReal {
    if (!_letterPadTopRowReal) {
        [self letterPadTopRow];
    }
    return _letterPadTopRowReal;
}

- (NSArray *)letterPadMiddleRow {
    if (!_letterPadMiddleRow) {
        NSString *row = NSLocalizedStringFromTable(@"letterPadMiddle", kLocalizedTableSymbols, @"A S D F G H J K L by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [key setTitleFont:[self currentFontRegular]];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
        }
        _letterPadMiddleRow = [[NSArray alloc] initWithArray:buttons];
        _letterPadMiddleRowReal = [[NSArray alloc] initWithArray:mats];
    }
    return _letterPadMiddleRow;
}

- (NSArray*)letterPadMiddleRowReal {
    if (!_letterPadMiddleRowReal) {
        [self letterPadMiddleRow];
    }
    return _letterPadMiddleRowReal;
}

- (NSArray*)letterPadBottomRow {
    if (!_letterPadBottomRow) {
        NSString *row = NSLocalizedStringFromTable(@"letterPadBottom", kLocalizedTableSymbols, @"Z X C V B N M by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];

        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [key setTitleFont:[self currentFontRegular]];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
        }
        _letterPadBottomRow = [[NSArray alloc] initWithArray:buttons];
        _letterPadBottomRowReal = [[NSArray alloc] initWithArray:mats];
    }
    return _letterPadBottomRow;
}

- (NSArray *)letterPadBottomRowReal {
    if (!_letterPadBottomRowReal) {
        [self letterPadBottomRow];
    }
    return _letterPadBottomRowReal;
}

- (NSArray *)symbolPadTopRow {
    if (!_symbolPadTopRow) {
        NSString *row = NSLocalizedStringFromTable(@"numberPadTop", kLocalizedTableSymbols, @"1 2 3 4 5 6 7 8 9 0 by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [key setTitleFont:[self currentFontRegular]];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
        }
        _symbolPadTopRow = [[NSArray alloc] initWithArray:buttons];
        _symbolPadTopRowReal = [[NSArray alloc] initWithArray:mats];
    }
    return _symbolPadTopRow;
}

- (NSArray *)symbolPadTopRowReal {
    if (!_symbolPadTopRowReal) {
        [self symbolPadTopRow];
    }
    return _symbolPadTopRowReal;
}

- (NSArray*)symbolPadMiddleRow {
    if (!_symbolPadMiddleRow) {
        NSString *row = NSLocalizedStringFromTable(@"numberPadMiddleFull", kLocalizedTableSymbols, @"- / : ; ( ) $ & @ \ by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [key setTitleFont:[self currentFontRegular]];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
        }
        _symbolPadMiddleRow = [[NSArray alloc] initWithArray:buttons];
        _symbolPadMiddleRowReal = [[NSArray alloc] initWithArray:mats];
    }
    return _symbolPadMiddleRow;
}

- (NSArray*)symbolPadMiddleRowReal {
    if (!_symbolPadMiddleRowReal) {
        [self symbolPadMiddleRow];
    }
    return _symbolPadMiddleRowReal;
}

- (NSArray *)symbolPadBottomRow {
    if (!_symbolPadBottomRow) {
        NSString *row = NSLocalizedStringFromTable(@"numberPadBottomShort", kLocalizedTableSymbols, @". , ? ! ' by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [key setTitleFont:[self currentFontRegular]];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
        }
        _symbolPadBottomRow = [[NSArray alloc] initWithArray:buttons];
        _symbolPadBottomRowReal = [[NSArray alloc] initWithArray:mats];
    }
    return _symbolPadBottomRow;
}

- (NSArray *)symbolPadBottomRowReal {
    if (!_symbolPadBottomRowReal) {
        [self symbolPadBottomRow];
    }
    return _symbolPadBottomRowReal;
}


#pragma mark - Define mass keys for iPad

- (NSArray *)letterPadTopRowPad {
    if (!_letterPadTopRowPad) {
        NSString *row = NSLocalizedStringFromTable(@"letterPadTop", kLocalizedTableSymbols, @"Q W E R T Y U I P by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
            
            // For iPad we do it right here
            [self addSubview:key];
            [self addSubview:mat];
        }
        _letterPadTopRowPad = [[NSArray alloc] initWithArray:buttons];
        _letterPadTopRowPadReal = [[NSArray alloc] initWithArray:mats];
    }
    return _letterPadTopRowPad;
}

- (NSArray *)letterPadTopRowPadReal {
    if (!_letterPadTopRowPadReal) {
        [self letterPadTopRowPad];
    }
    return _letterPadTopRowPadReal;
}

- (NSArray *)letterPadMiddleRowPad {
    if (!_letterPadMiddleRowPad) {
        NSString *row = NSLocalizedStringFromTable(@"letterPadMiddle", kLocalizedTableSymbols, @"A S D F G H J K L by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
            
            // For iPad we do it right here
            [self addSubview:key];
            [self addSubview:mat];
        }
        _letterPadMiddleRowPad = [[NSArray alloc] initWithArray:buttons];
        _letterPadMiddleRowPadReal = [[NSArray alloc] initWithArray:mats];
    }
    return _letterPadMiddleRowPad;
}

- (NSArray *)letterPadMiddleRowPadReal {
    if (!_letterPadMiddleRowPadReal) {
        [self letterPadMiddleRowPad];
    }
    return _letterPadMiddleRowPadReal;
}

- (NSArray *)letterPadBottomRowPad {
    if (!_letterPadBottomRowPad) {
        NSString *row = NSLocalizedStringFromTable(@"letterPadBottomiPad", kLocalizedTableSymbols, @"Z X C V B N M , . by default");
        NSArray *letters = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];

        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSMutableArray *mats = [[NSMutableArray alloc] init];
        
        ACKey *key = nil;
        ACKeyMat *mat = nil;
        for (NSString *letter in letters) {
            key = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:letter];
            [key addTarget:self action:@selector(letterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:key];
            
            mat = [ACKeyMat matForKey:key];
            [mats addObject:mat];
            
            // For iPad we do it right here
            [self addSubview:key];
            [self addSubview:mat];
        }
        _letterPadBottomRowPad = [[NSArray alloc] initWithArray:buttons];
        _letterPadBottomRowPadReal = [[NSArray alloc] initWithArray:mats];
    }
    return _letterPadBottomRowPad;
}

- (NSArray *)letterPadBottomRowPadReal {
    if (!_letterPadBottomRowPadReal) {
        [self letterPadBottomRowPad];
    }
    return _letterPadBottomRowPadReal;
}


#pragma mark - Continue definition of non-mass keys

- (ACKey *)undoButton {
    if (!_undoButton) {
        _undoButton = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:@"undo"];
        [_undoButton addTarget:self action:@selector(undoButtonTapped) forControlEvents:UIControlEventTouchDown];
    }
    return _undoButton;
}

- (ACKey *)redoButton {
    if (!_redoButton) {
        _redoButton = [ACKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance title:@"redo"];
        [_redoButton addTarget:self action:@selector(redoButtonTapped) forControlEvents:UIControlEventTouchDown];
    }
    return _redoButton;
}

- (ACKey *)leftSymbolPadButtonPad {
    if (!_leftSymbolPadButtonPad) {
        _leftSymbolPadButtonPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"#+="];
        [_leftSymbolPadButtonPad addTarget:self action:@selector(symbolPadButtonPadTapped) forControlEvents:UIControlEventTouchDown];
    }
    return _leftSymbolPadButtonPad;
}

- (ACKey *)rightSymbolPadButtonPad {
    if (!_rightSymbolPadButtonPad) {
        _rightSymbolPadButtonPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"#+="];
        [_rightSymbolPadButtonPad addTarget:self action:@selector(symbolPadButtonPadTapped) forControlEvents:UIControlEventTouchDown];
    }
    return _rightSymbolPadButtonPad;
}

- (ACKey *)leftLetterPadButtonPad {
    if (!_leftLetterPadButtonPad) {
        _leftLetterPadButtonPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"ABC"];
        [_leftLetterPadButtonPad addTarget:self action:@selector(letterPadButtonPadTapped) forControlEvents:UIControlEventTouchDown];
    }
    return _leftLetterPadButtonPad;
}

- (ACKey *)rightLetterPadButtonPad {
    if (!_rightLetterPadButtonPad) {
        _rightLetterPadButtonPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@"ABC"];
        [_rightLetterPadButtonPad addTarget:self action:@selector(letterPadButtonPadTapped) forControlEvents:UIControlEventTouchDown];
    }
    return _rightLetterPadButtonPad;
}

- (ACKey *)leftNumberPadButtonOnSymbolPad {
    if (!_leftNumberPadButtonOnSymbolPad) {
        _leftNumberPadButtonOnSymbolPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@".?123"];
        [_leftNumberPadButtonOnSymbolPad addTarget:self action:@selector(numberPadButtonPressedPad) forControlEvents:UIControlEventTouchDown];
    }
    return _leftNumberPadButtonOnSymbolPad;
}

- (ACKey *)rightNumberPadButtonOnSymbolPad {
    if (!_rightNumberPadButtonOnSymbolPad) {
        _rightNumberPadButtonOnSymbolPad = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance title:@".?123"];
        [_rightNumberPadButtonOnSymbolPad addTarget:self action:@selector(numberPadButtonPressedPad) forControlEvents:UIControlEventTouchDown];
    }
    return _rightNumberPadButtonOnSymbolPad;
}

- (ACKeyAppearance)keyAppearance {
    ACKeyAppearance appearance;
    switch (self.currentKBTheme) {
        case KBThemeOriginal:
            appearance = ACKeyAppearanceDark;
            break;
            
        case KBThemeClassic:
            appearance = ACKeyAppearanceLight;
            break;
            
        case KBThemeTransparent:
            appearance = ACKeyAppearanceClearWhite;
            break;
            
        default:
            break;
    }
    
    return appearance;
}

- (void)updateCapitalizationOfKeys {
    BOOL shiftIsPushed = self.leftShiftButton.selected || self.leftShiftButton.isLocked;
    
    NSString *title;
    
    if (IS_IPAD) {
        for (ACKey *button in self.letterPadTopRowPad) {
            title = button.title;
            [button setTitle:shiftIsPushed ? [title uppercaseString] : [title lowercaseString]];
            [button shiftToTop:!shiftIsPushed];
        }
        for (ACKey *button in self.letterPadMiddleRowPad) {
            title = button.title;
            [button setTitle:shiftIsPushed ? [title uppercaseString] : [title lowercaseString]];
            [button shiftToTop:!shiftIsPushed];
        }
        for (ACKey *button in self.letterPadBottomRowPad) {
            title = button.title;
            [button setTitle:shiftIsPushed ? [title uppercaseString] : [title lowercaseString]];
            [button shiftToTop:!shiftIsPushed];
        }
    } else {
        for (ACKey *button in self.letterPadTopRow) {
            title = button.title;
            [button setTitle:shiftIsPushed ? [title uppercaseString] : [title lowercaseString]];
            [button shiftToTop:!shiftIsPushed];
        }
        for (ACKey *button in self.letterPadMiddleRow) {
            title = button.title;
            [button setTitle:shiftIsPushed ? [title uppercaseString] : [title lowercaseString]];
            [button shiftToTop:!shiftIsPushed];
        }
        for (ACKey *button in self.letterPadBottomRow) {
            title = button.title;
            [button setTitle:shiftIsPushed ? [title uppercaseString] : [title lowercaseString]];
            [button shiftToTop:!shiftIsPushed];
        }
    }
}

- (void)updateFont {
    NSArray *arrSpec = nil;
    NSArray *allButtons = nil;
    if (IS_IPAD) {
        arrSpec = @[self.returnButton,
                    self.overlayButton,
                    
                    self.leftNumberPadButton,
                    self.rightNumberPadButton,
                    
                    self.leftSymbolPadButtonPad,
                    self.rightSymbolPadButtonPad,
                    
                    self.leftLetterPadButtonPad,
                    self.rightLetterPadButtonPad,
                    
                    self.leftNumberPadButtonOnSymbolPad,
                    self.rightNumberPadButtonOnSymbolPad];
        
        allButtons = @[self.letterPadTopRowPad,
                       self.letterPadMiddleRowPad,
                       self.letterPadBottomRowPad];
    } else {
        arrSpec = @[self.spaceButton,
                    self.returnButton,
                    self.numberPadButton,
                    self.symbolPadButton,
                    self.letterPadButton,
                    self.numberPadButtonOnSymbolPad];
        
        
        allButtons = @[arrSpec,
                       self.letterPadTopRow,
                       self.letterPadMiddleRow,
                       self.letterPadBottomRow,
                       
                       self.symbolPadTopRow,
                       self.symbolPadMiddleRow,
                       self.symbolPadBottomRow];
    }
    
    for (NSArray *array in allButtons) {
        for (ACKey *key in array) {
            key.titleFont = [self currentFontRegular];
        }
    }
    
    for (ACKey *key in arrSpec) {
        key.titleFont = [self currentFontSmall];
    }
}

- (void)updateAppearance {
    NSArray *arrSpec = nil;
    NSArray *allButtons = nil;
    if (IS_IPAD) {
        arrSpec = @[self.nextKeyboardButton,
                    
                    self.spaceButton,
                    self.returnButton,
                    
                    self.deleteButton,
                    self.overlayButton,
                    self.hideButton,
                    
                    self.leftNumberPadButton,
                    self.rightNumberPadButton,
                    
                    self.leftSymbolPadButtonPad,
                    self.rightSymbolPadButtonPad,
                    
                    self.leftLetterPadButtonPad,
                    self.rightLetterPadButtonPad,
                    
                    self.leftNumberPadButtonOnSymbolPad,
                    self.rightNumberPadButtonOnSymbolPad,
                    
                    self.leftShiftButton,
                    self.rightShiftButton];
        
        allButtons = @[arrSpec,
                       self.letterPadTopRowPad,
                       self.letterPadMiddleRowPad,
                       self.letterPadBottomRowPad];
        
    } else {
        arrSpec = @[self.nextKeyboardButton,
                    self.spaceButton,
                    self.returnButton,
                    self.deleteButton,
                    self.overlayButton,
                    self.numberPadButton,
                    self.symbolPadButton,
                    self.letterPadButton,
                    self.numberPadButtonOnSymbolPad,
                    self.leftShiftButton];
        
        allButtons = @[arrSpec,
                       self.letterPadTopRow,
                       self.letterPadMiddleRow,
                       self.letterPadBottomRow,
                       
                       self.symbolPadTopRow,
                       self.symbolPadMiddleRow,
                       self.symbolPadBottomRow];
    }
    
    
    for (NSArray *array in allButtons) {
        for (ACKey *key in array) {
            if ([key isKindOfClass:[ACKey class]]) {
                key.appearance = self.keyAppearance;
            }
        }
    }
}

- (void)updateLinearKeyboardMetrics {
    if (IS_IPAD) {
        if (self.currentKBTheme == KBThemeTransparent) {
            self.padKeyboardMetrics = getPadLinearKeyboardMetricsTransparent(self.currentSize.width, self.currentSize.height);
        } else {
            self.padKeyboardMetrics = getPadLinearKeyboardMetrics(self.currentSize.width, self.currentSize.height);
        }
    } else {
        if (self.currentKBTheme == KBThemeTransparent) {
            if (IS_IPHONE_5) {
                self.phoneKeyboardMetrics = getPhoneLinearKeyboardMetricsiPhone5Transparent(self.currentSize.width, self.currentSize.height);
            } else if (IS_IPHONE_6) {
                self.phoneKeyboardMetrics = getPhoneLinearKeyboardMetricsiPhone6Transparent(self.currentSize.width, self.currentSize.height);
            } else if (IS_IPHONE_6_PLUS || IS_IPHONE_X) {
                self.phoneKeyboardMetrics = getPhoneLinearKeyboardMetricsiPhone6PlusTransparent(self.currentSize.width, self.currentSize.height);
            }
        } else {
            if (IS_IPHONE_6 || IS_IPHONE_6_PLUS || IS_IPHONE_X) {
                self.phoneKeyboardMetrics = getPhoneLinearKeyboardMetrics(self.currentSize.width, self.currentSize.height);
            } else {
                self.phoneKeyboardMetrics = getPhoneLinearKeyboardMetricsiPhone5(self.currentSize.width, self.currentSize.height);
            }
        }
    }
}

- (void)returnButtonTapped:(id)sender {
    [self.delegate returnButtonTapped];
    
    [self.delegate playClick];
}

- (void)spaceButtonTapped:(id)sender {
    [self.delegate playClick];
    [self.delegate letterButtonTappedWithText:@" "];
    [self.delegate textDidChange:nil];
    
    if (self.currentPad == KeyboardViewPadTypeNumber ||
        self.currentPad == KeyboardViewPadTypeSymbol) {
        if (IS_IPAD) {
            [self letterPadButtonPadTapped];
        } else {
            [self letterPadButtonTapped:nil];
        }
    }
}

- (void)letterButtonTapped:(id)sender {
    [self.delegate playClick];
    
    NSString *text = ([sender isKindOfClass:[ACKeyMat class]]) ? [((ACKeyMat *)sender).key title] : [sender title];
    if (self.leftShiftButton.isLocked || self.leftShiftButton.selected) {
        [self.delegate letterButtonTappedWithText:[text uppercaseString]];
    } else {
        [self.delegate letterButtonTappedWithText:[text lowercaseString]];
    }
}

- (void)numberPadButtonTapped:(id)sender {
    [self.delegate playClick];
    [self hideLetterPad];
    [self showSymbolPad];
    self.currentPad = KeyboardViewPadTypeNumber;
    [self numberPadButtonOnSymbolPadTapped:nil];
}

- (void)letterPadButtonTapped:(id)sender {
    [self.delegate playClick];
    [self hideSymbolPad];
    if (!self.letterPadCreated) {
        [self createLetterPadPhone];
    }
    [self showLetterPad];
    self.currentPad = KeyboardViewPadTypeLetter;
}

- (void)symbolPadButtonTapped:(id)sender {
    [self.delegate playClick];
    [self changeNumberToSymbolPad];
    self.currentPad = KeyboardViewPadTypeSymbol;
}

- (void)numberPadButtonOnSymbolPadTapped:(id)sender {
    [self.delegate playClick];
    [self changeSymbolToNumberPad];
    self.currentPad = KeyboardViewPadTypeNumber;
}

- (void)overlayButtonTapped:(id)sender {
    [self.delegate overlayButtonTapped:sender];
}

- (void)shiftButtonTapped:(id)sender {
    [self.delegate playClick];
    if (self.leftShiftButton.isLocked) {
        self.leftShiftButton.selected = self.rightShiftButton.selected = NO;
        self.leftShiftButton.locked = self.rightShiftButton.locked = NO;
    } else {
        if (IS_IPAD) {
            self.rightShiftButton.selected = ! self.leftShiftButton.selected;
        }
        
        self.leftShiftButton.selected = ! self.leftShiftButton.selected;
    }
    [self updateCapitalizationOfKeys];
}

- (void)shiftButtonDoubleTapped:(id)sender {
    self.leftShiftButton.selected = _rightShiftButton.selected = YES;
    self.leftShiftButton.locked = _rightShiftButton.locked = ! self.leftShiftButton.isLocked;
    [self updateCapitalizationOfKeys];
}

- (void)hidePressedPad {
    [self.delegate hidePressedPad];
}

- (void)numberPadButtonPressedPad {
    [self.delegate playClick];
    [self.leftShiftButton removeFromSuperview];
    [self.rightShiftButton removeFromSuperview];
    [self.leftNumberPadButton removeFromSuperview];
    [self.rightNumberPadButton removeFromSuperview];
    
    self.currentPad = KeyboardViewPadTypeNumber;
    
    NSString *row = NSLocalizedStringFromTable(@"numberPadTop", kLocalizedTableSymbols, @"1 2 3 4 5 6 7 8 9 0 by default");
    NSArray *numbers1 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"numberPadMiddle", kLocalizedTableSymbols, @"- / : ; ( ) $ & @ by default");
    NSArray *numbers2 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"numberPadBottom", kLocalizedTableSymbols, @". , ? ! ' \ by default");
    NSArray *numbers3 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    for (int i = 0; i < [numbers1 count]; ++i) {
        [self.letterPadTopRowPad[i] setTitle:numbers1[i]];
    }
    for (int i = 0; i < [numbers2 count]; ++i) {
        [self.letterPadMiddleRowPad[i] setTitle:numbers2[i]];
    }
    for (int i = 0; i < [numbers3 count]; ++i) {
        [self.letterPadBottomRowPad[i] setTitle:numbers3[i]];
    }
    
    ACKey *key = nil;
    ACKeyMat *mat = nil;
    for (int i = 0; i < [self.letterPadBottomRowPad count]; i++) {
        key = (ACKey *)self.letterPadBottomRowPad[i];
        mat = (ACKeyMat *)self.letterPadBottomRowPadReal[i];
        if (i < [numbers3 count]) {
            key.frame = self.padKeyboardMetrics.letterPadFrames[3][i];
            key.cornerRadius = self.cornerRadius;
            mat.frame = self.padKeyboardMetrics.letterPadFramesReal[3][i];
        } else {
            key.hidden = YES;
            mat.hidden = YES;
        }
    }
    
    self.leftSymbolPadButtonPad.frame = self.padKeyboardMetrics.leftShiftButtonFrame;
    self.leftSymbolPadButtonPad.cornerRadius = self.cornerRadius;
    [self addSubview:self.leftSymbolPadButtonPad];
    self.rightSymbolPadButtonPad.frame = self.padKeyboardMetrics.rightShiftButtonFrame;
    self.rightSymbolPadButtonPad.cornerRadius = self.cornerRadius;
    [self addSubview:self.rightSymbolPadButtonPad];
    self.leftLetterPadButtonPad.frame = self.padKeyboardMetrics.leftNumberButtonFrame;
    self.leftLetterPadButtonPad.cornerRadius = self.cornerRadius;
    [self addSubview:self.leftLetterPadButtonPad];
    self.rightLetterPadButtonPad.frame = self.padKeyboardMetrics.rightNumberButtonFrame;
    self.rightLetterPadButtonPad.cornerRadius = self.cornerRadius;
    [self addSubview:self.rightLetterPadButtonPad];
}

- (void)symbolPadButtonPadTapped {
    [self.delegate playClick];
    
    self.currentPad = KeyboardViewPadTypeSymbol;
    
    NSString *row = NSLocalizedStringFromTable(@"symbolPadTop", kLocalizedTableSymbols, @"[ ] { } # % ^ * + = by default");
    NSArray *symbols1 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"symbolPadMiddleShort", kLocalizedTableSymbols, @"_ \ | ~ < > $ € £ by default");
    NSArray *symbols2 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"numberPadBottom", kLocalizedTableSymbols, @". , ? ! ' \ by default");
    NSArray *symbols3 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    for (int i = 0; i < [symbols1 count]; ++i) {
        [self.letterPadTopRowPad[i] setTitle:symbols1[i]];
    }
    for (int i = 0; i < [symbols2 count]; ++i) {
        [self.letterPadMiddleRowPad[i] setTitle:symbols2[i]];
    }
    for (int i = 0; i < [symbols3 count]; ++i) {
        [self.letterPadBottomRowPad[i + 2] setTitle:symbols3[i]];
        
    }
    
    ACKey *key = nil;
    ACKeyMat *mat = nil;
    for (int i = 0; i < [self.letterPadBottomRowPad count]; i++) {
        key = (ACKey *)self.letterPadBottomRowPad[i];
        mat = (ACKeyMat *)self.letterPadBottomRowPadReal[i];
        if (i < [symbols3 count]) {
            key.frame = self.padKeyboardMetrics.letterPadFrames[3][i];
            key.cornerRadius = self.cornerRadius;
            mat.frame = self.padKeyboardMetrics.letterPadFramesReal[3][i];
        } else {
            key.hidden = YES;
            mat.hidden = YES;
        }
    }
    [self.rightSymbolPadButtonPad removeFromSuperview];
    [self.leftSymbolPadButtonPad removeFromSuperview];
    
    self.leftNumberPadButtonOnSymbolPad.frame = self.padKeyboardMetrics.leftShiftButtonFrame;
    self.leftNumberPadButtonOnSymbolPad.cornerRadius = self.cornerRadius;
    [self addSubview:self.leftNumberPadButtonOnSymbolPad];
    self.rightNumberPadButtonOnSymbolPad.frame = self.padKeyboardMetrics.rightShiftButtonFrame;
    self.rightNumberPadButtonOnSymbolPad.cornerRadius = self.cornerRadius;
    [self addSubview:self.rightNumberPadButtonOnSymbolPad];
}

- (void)letterPadButtonPadTapped {
    [self.delegate playClick];
    
    self.currentPad = KeyboardViewPadTypeLetter;
    
    [self.leftSymbolPadButtonPad removeFromSuperview];
    [self.rightSymbolPadButtonPad removeFromSuperview];
    [self.leftLetterPadButtonPad removeFromSuperview];
    [self.rightLetterPadButtonPad removeFromSuperview];
    
    [self.leftNumberPadButtonOnSymbolPad removeFromSuperview];
    [self.rightNumberPadButtonOnSymbolPad removeFromSuperview];
    
    [self addSubview:self.leftShiftButton];
    [self addSubview:self.rightShiftButton];
    [self addSubview:self.leftNumberPadButton];
    [self addSubview:self.rightNumberPadButton];
    
    NSString *row = NSLocalizedStringFromTable(@"letterPadTop", kLocalizedTableSymbols, @"Q W E R T Y U I P by default");
    NSArray *numbers1 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];

    row = NSLocalizedStringFromTable(@"letterPadMiddle", kLocalizedTableSymbols, @"A S D F G H J K L by default");
    NSArray *numbers2 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    row = NSLocalizedStringFromTable(@"letterPadBottomiPad", kLocalizedTableSymbols, @"Z X C V B N M , . by default");
    NSArray *numbers3 = [row componentsSeparatedByString:kKeyboardViewRowComponentSeparator];
    
    for (int i = 0; i < [numbers1 count]; ++i) {
        [self.letterPadTopRowPad[i] setTitle:numbers1[i]];
    }
    for (int i = 0; i < [numbers2 count]; ++i) {
        [self.letterPadMiddleRowPad[i] setTitle:numbers2[i]];
    }
    
    ACKey *key = nil;
    ACKeyMat *mat = nil;
    for (int i = 0; i < [numbers3 count]; ++i) {
        key = (ACKey *)self.letterPadBottomRowPad[i];
        mat = (ACKeyMat *)self.letterPadBottomRowPadReal[i];
        
        [key setTitle:numbers3[i]];
        key.hidden = NO;
        key.frame = self.padKeyboardMetrics.letterPadFrames[2][i];
        mat.hidden = NO;
        mat.frame = self.padKeyboardMetrics.letterPadFramesReal[2][i];
    }
}

- (UIFont *)currentFontSmall {
    UIFont *font = nil;
    switch (self.currentKBTheme) {
        case KBThemeOriginal:
            if (IS_IPAD) {
                font = [UIFont systemFontOfSize: (self.frame.size.width >= 1024) ? kKeyPadPortraitTitleFontSize:kKeyPadPortraitTitleFontSize - 4];
            } else {
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0 )
                font = [UIFont systemFontOfSize:16];
#else
                font = [UIFont helveticaFontOfSize:19];
#endif
            }
            break;
            
        case KBThemeClassic:
        case KBThemeTransparent:
        default:
            if (IS_IPAD) {
                font = [UIFont systemFontOfSize:(self.frame.size.width >= 1024) ? 22.0 : 14.0  weight:UIFontWeightLight];
            } else {
                font = [UIFont fontWithName:@"SFUIDisplay-Light" size:16.0];
            }
            break;
    }
    return font;
}

- (UIFont *)currentFontRegular {
    UIFont *font = nil;
    switch (self.currentKBTheme) {
        case KBThemeOriginal:
            if (IS_IPAD) {
                font = [UIFont systemFontOfSize:(self.frame.size.width >= 1024) ? kKeyPadLandscapeTitleFontSize : kKeyPadPortraitTitleFontSize];
            } else {
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0 )
                font = [UIFont systemFontOfSize:23];
#else
                font = [UIFont helveticaFontOfSize:17];
#endif            
            }
            break;
            
        case KBThemeClassic:
        case KBThemeTransparent:
        default:
            if (IS_IPAD) {
                font = [UIFont systemFontOfSize:(self.frame.size.width >= 1024) ? 26.5 : 22.0 weight:UIFontWeightLight];
            } else {
                font = [UIFont fontWithName:@"SFUIDisplay-Light" size:24.0];
            }
            break;
    }
    return font;
}


#pragma mark - Keys State

- (void)updateReturnButtonTitle:(NSString*)title {
    if (title) {
        self.returnButton.title = title;
    }
    
    switch (self.currentKBTheme) {
        case KBThemeOriginal:
            self.returnButton.style = ACKeyStyleBlue;
            break;
            
        case KBThemeClassic:
            self.returnButton.style = ([self.returnButton.title isEqualToString:@"Search"])?ACKeyStyleBlue:ACKeyStyleDark;
            break;
            
        default:
            break;
    }
}

- (void)setTheme:(KBTheme)newKBTheme {
    _currentKBTheme = newKBTheme;
    
    self.cellImage.alpha = (_currentKBTheme == KBThemeTransparent)? 1.0 : 0.0;
    self.backgroundColor = colorBackgroundForTheme(_currentKBTheme);

    [self updateFont];
    [self updateLinearKeyboardMetrics];
    [self arrangeKeys];
    
    // Delete button
    {
        for (UIGestureRecognizer *gr in _deleteButton.gestureRecognizers) {
            [gr removeTarget:self action:nil];
        }
        
        [_deleteButton removeFromSuperview];
        _deleteButton = nil;
        switch (self.currentKBTheme) {
            case KBThemeTransparent: {
                UIImage *activeImage = [UIImage imageNamed:@"backspace_transparent_active"];
                UIImage *nonActiveImage = [UIImage imageNamed:@"backspace_transparent_inactive"];
                _deleteButton = [ACActivatedKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:nil];
                [((ACActivatedKey *)_deleteButton) setActiveImage:activeImage andInactiveImage:nonActiveImage];
            }   break;
                
            case KBThemeClassic:{
                UIImage *activeImage = [UIImage imageNamed:@"backspace_active"];
                UIImage *nonActiveImage = [UIImage imageNamed:@"backspace"];
                _deleteButton = [ACActivatedKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:nil];
                [((ACActivatedKey*)_deleteButton) setActiveImage:activeImage andInactiveImage:nonActiveImage];
            }   break;
                
            case KBThemeOriginal:
            default: {
                UIImage *image = [[UIImage imageNamed:@"delete_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                _deleteButton = [ACKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance image:image];
            }
                break;
        }
        [_deleteButton setFrame:(IS_IPAD) ? self.padKeyboardMetrics.deleteButtonFrame : self.phoneKeyboardMetrics.deleteButtonFrame];
        [self.delegate setupNewDeleteButton:_deleteButton];
        [self addSubview:_deleteButton];
    }
    
    // Shift
    {
        [_leftShiftButton removeTarget:self action:nil forControlEvents:UIControlEventAllTouchEvents];
        [_leftShiftButton removeFromSuperview];
        _leftShiftButton = nil;
        
        switch (self.currentKBTheme) {
            case KBThemeTransparent: {
                UIImage *activeImage = [UIImage imageNamed:@"shift_transparent_active"];
                UIImage *nonActiveImage = [UIImage imageNamed:@"shift_transparent_inactive"];
                _leftShiftButton = [ACLockActivatedKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance image:nil];
                _leftShiftButton.lockImage = [[UIImage imageNamed:@"shift_transparent_lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [((ACLockActivatedKey *)_leftShiftButton) setActiveImage:activeImage andInactiveImage:nonActiveImage];

            }   break;
                
            case KBThemeClassic: {
                UIImage *activeImage = [UIImage imageNamed:@"shift_classic_active"];
                UIImage *nonActiveImage = [UIImage imageNamed:@"shift_classic_inactive"];
                _leftShiftButton = [ACLockActivatedKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance image:nil];
                _leftShiftButton.lockImage = [[UIImage imageNamed:@"shift_lock_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [((ACLockActivatedKey *)_leftShiftButton) setActiveImage:activeImage andInactiveImage:nonActiveImage];
                
            }   break;
                
            case KBThemeOriginal:{
                _leftShiftButton = [ACLockKey keyWithStyle:ACKeyStyleDark appearance:self.keyAppearance];
                _leftShiftButton.image = [[UIImage imageNamed:@"shift_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                _leftShiftButton.lockImage = [[UIImage imageNamed:@"shift_lock_portrait"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }   break;
                
            default:
                break;
        }
        
        [_leftShiftButton addTarget:self action:@selector(shiftButtonTapped:) forControlEvents:UIControlEventTouchDown];
        [_leftShiftButton addTarget:self action:@selector(shiftButtonDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];
        
        _leftShiftButton.frame = (IS_IPAD) ? self.padKeyboardMetrics.leftShiftButtonFrame : self.phoneKeyboardMetrics.leftShiftButtonFrame;
        [self addSubview:_leftShiftButton];
        
        if (IS_IPAD) {
            [_rightShiftButton removeFromSuperview];
            [_rightShiftButton removeTarget:self action:nil forControlEvents:UIControlEventAllTouchEvents];
            
            switch (self.currentKBTheme) {
                case KBThemeClassic: {
                    _rightShiftButton = [ACLockActivatedKey keyWithStyle:ACKeyStyleLight appearance:self.keyAppearance image:nil];
                    _rightShiftButton.lockImage = _leftShiftButton.lockImage;
                    [((ACLockActivatedKey *)_rightShiftButton) setActiveImage:((ACLockActivatedKey *)_leftShiftButton).imageActive andInactiveImage:((ACLockActivatedKey *)_leftShiftButton).imageInactive];
                    
                }   break;
                    
                case KBThemeOriginal:{
                    _rightShiftButton = [ACLockKey keyWithStyle:_leftShiftButton.style appearance:self.keyAppearance];
                    _rightShiftButton.image = _leftShiftButton.image;
                    _rightShiftButton.lockImage = _leftShiftButton.lockImage;
                }   break;
                    
                default:
                break;
            }
            
            [_rightShiftButton addTarget:self action:@selector(shiftButtonTapped:) forControlEvents:UIControlEventTouchDown];
            [_rightShiftButton addTarget:self action:@selector(shiftButtonDoubleTapped:) forControlEvents:UIControlEventTouchDownRepeat];
            
            [_rightShiftButton setFrame:self.padKeyboardMetrics.rightShiftButtonFrame];
            [self addSubview:_rightShiftButton];
        }
    }
    
    [self updateAppearance];
    
    self.overlayButton.image = [UIImage imageNamed:@"kb_main_icon.png"];
}

- (void)undoButtonTapped {
    [self.delegate undoButtonTapped];
}

- (void)redoButtonTapped {
    [self.delegate redoButtonTapped];
}

@end

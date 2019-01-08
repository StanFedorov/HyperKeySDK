//
//  AutoCorrectionView.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 20.01.16.
//
//

#import "AutoCorrectionView.h"
#import "KeyboardThemesHelper.h"
#import "Macroses.h"
#import "MPTextChecker.h"
#import "ACCharacterOperation.h"
#import "ACSpaceOperation.h"
#import "UIImage+Additions.h"
#import "Macroses.h"

NSTimeInterval const kAutoCorrectionViewAnimationDuration = 0.45;
NSUInteger const kAutoCorrectionViewMaxOperations = 30;
NSUInteger const kAutoCorrectionViewMaxAutocorrection = 20;
NSString *const kAutoCorrectionViewLanguage = @"en_US";

CGFloat const kAutoCorrectionViewHeight = 40.0;

@interface AutoCorrectionView ()

@property (weak, nonatomic) IBOutlet UIButton *originalButton;
@property (weak, nonatomic) IBOutlet UIButton *correctionButton;
@property (weak, nonatomic) IBOutlet UIButton *otherButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsArray;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *splittersWidthConstraintsArray;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *originalThemeElements;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *classicThemeElements;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *transparentThemeElements;

@property (assign, nonatomic) KBTheme currentKBTheme;

@property (strong, nonatomic, readwrite) NSString *correction;
@property (strong, nonatomic, readwrite) NSCharacterSet *separatorCharacterSet;

@property (strong, nonatomic) NSCharacterSet *checkSeparateCharacterSet;

@property (strong, nonatomic) MPTextChecker *textChecker;
@property (assign, nonatomic) BOOL isDataCreated;
@property (assign, nonatomic) BOOL isLanguageDataCreated;
@property (strong, nonatomic) NSString *original;
@property (strong, nonatomic) NSString *prepareText;

@property (strong, atomic) NSOperationQueue *correctionQueue;

@end

@implementation AutoCorrectionView

- (void)awakeFromNib {
    [super awakeFromNib];

    [self initialization];
}


#pragma mark - Initialization

- (void)initialization {
    for (NSLayoutConstraint *splitterWidthConstraint in self.splittersWidthConstraintsArray) {
        splitterWidthConstraint.constant = 1 / [UIScreen mainScreen].scale;
    }
    
    self.isLanguageDataCreated = NO;
    self.isDataCreated = NO;
    
    self.correctionQueue = [[NSOperationQueue alloc] init];
    self.correctionQueue.maxConcurrentOperationCount = 1;
    self.correctionQueue.qualityOfService = NSQualityOfServiceBackground;
    
    self.textChecker = [[MPTextChecker alloc] init];
    
    __weak __typeof(self)weakSelf = self;
    [self.textChecker initializeLanguage:kAutoCorrectionViewLanguage dataCreation:NO completion:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.isLanguageDataCreated = YES;
            strongSelf.isDataCreated = NO;
            
            NSMutableCharacterSet *separator = [[NSMutableCharacterSet alloc] init];
            [separator formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [separator formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
            [separator removeCharactersInString:@"'"];
            strongSelf.separatorCharacterSet = separator;
        }
    }];
}


#pragma mark - Property

- (void)setSeparatorCharacterSet:(NSCharacterSet *)separatorCharacterSet {
    _separatorCharacterSet = separatorCharacterSet;
    
    NSMutableCharacterSet *check = [[NSMutableCharacterSet alloc] init];
    [check formUnionWithCharacterSet:separatorCharacterSet];
    [check removeCharactersInString:@"@"];
    self.checkSeparateCharacterSet = check;
}

- (void)setIsAutoCapitalize:(BOOL)isAutoCapitalize {
    _isAutoCapitalize = isAutoCapitalize;
    
    if (self.textChecker) {
        self.textChecker.isAutoCapitalize = isAutoCapitalize;
    }
}

- (void)setIsFullAccess:(BOOL)isFullAccess {
    _isFullAccess = isFullAccess;
    
    if (self.textChecker) {
        self.textChecker.isFullAccess = isFullAccess;
    }
}

- (void)setText:(NSString *)text {
    self.prepareText = text;
    
    if ([_text isEqualToString:text] || !self.isDataCreated) {
        return;
    }
    
    _text = text;
    
    NSArray *words = [self.text componentsSeparatedByCharactersInSet:self.textChecker.wordSeparatorCharacterSet];
    if (words.count > 0 && ((NSString *)words.lastObject).length > kAutoCorrectionViewMaxAutocorrection) {
        return;
    }
    
    // Remove excess operations
    @synchronized(self.correctionQueue) {
        if (self.correctionQueue.operationCount > 1) {
            NSArray *operations = self.correctionQueue.operations;
            __block NSInteger removeOperationIndex = operations.count - 2;
            [operations enumerateObjectsUsingBlock:^(NSOperation *operation, NSUInteger i, BOOL * _Nonnull stop) {
                if ([operation isKindOfClass:[ACSpaceOperation class]]) {
                    removeOperationIndex = i - 2;
                    (*stop) = YES;
                }
            }];
            if (operations.count > kAutoCorrectionViewMaxOperations) {
                removeOperationIndex = MAX(removeOperationIndex, operations.count - kAutoCorrectionViewMaxOperations);
            }
            if (removeOperationIndex >= 0) {
                for (NSInteger i = removeOperationIndex; i >= 0; i--) {
                    [((NSOperation *)operations[i]) cancel];
                }
            }
        }
    }
    
    ACCharacterOperation *operation = [[ACCharacterOperation alloc] initWithTextChecker:self.textChecker text:text];
    
    __weak __typeof(self)weakSelf = self;
    operation.willCompletionBlock = ^(NSString *text, NSString *original, MPTCString *correction, NSArray *other) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            @synchronized(strongSelf.correctionQueue) {
                if (strongSelf.correctionQueue.operationCount > 1) {
                    NSOperation *operation = strongSelf.correctionQueue.operations[1];
                    if ([operation isKindOfClass:[ACSpaceOperation class]] && !operation.isExecuting) {
                        ((ACSpaceOperation *)operation).text = text;
                        ((ACSpaceOperation *)operation).original = original;
                        ((ACSpaceOperation *)operation).correction = correction.string;
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf updateWithOriginal:original correction:correction other:other];
                if(original.length != 0) {
                    self.appsLine.alpha = 0.0f;
                }
            });
        }
    };
    
    [self.correctionQueue addOperation:operation];
}


#pragma mark - Public

- (void)createCorrectionData {
    if (self.isLanguageDataCreated && !self.isDataCreated) {
        __weak __typeof(self)weakSelf = self;
        [self.textChecker createCurrentLanguageDataWithCompletion:^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.isDataCreated = YES;
                if (![strongSelf.prepareText isEqualToString:strongSelf.text]) {
                    strongSelf.text = self.prepareText;
                }
            }
        }];
    }
}

- (void)clearCorrectionData {
    if (self.isLanguageDataCreated) {
        [self.correctionQueue cancelAllOperations];
        [self.textChecker clearCurrentLanguageDataWithCompletion:nil];
        
        self.isDataCreated = NO;
    }
}

- (void)setHidden:(BOOL)hidden animation:(BOOL)animation {
    CGFloat alpha = hidden ? 0 : 1;
    if (self.alpha != alpha) {
        if (alpha > 0) {
            [self createCorrectionData];
        } else {
            [self clearCorrectionData];
        }
        if (animation) {
            [UIView animateWithDuration:kAutoCorrectionViewAnimationDuration animations:^{
                self.alpha = alpha;
            }];
        } else {
            self.alpha = alpha;
        }
       // self.appsLine.alpha = alpha;
    }
}

- (void)addSeparate {
    ACSpaceOperation *operation = [[ACSpaceOperation alloc] initWithText:self.text original:self.original correction:self.correction];
    
    __weak __typeof(self)weakSelf = self;
    operation.willCompletionBlock = ^(NSString *text, NSString *original, NSString *correction) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf && correction) {
            @synchronized(strongSelf.correctionQueue) {
                if (strongSelf.correctionQueue.operationCount > 1) {
                    NSOperation *operation = strongSelf.correctionQueue.operations[1];
                    if ([operation isKindOfClass:[ACCharacterOperation class]] && !operation.isExecuting) {
                        [(ACCharacterOperation *)operation updateTextByReplaceString:original toString:correction];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([strongSelf.delegate respondsToSelector:@selector(autoCorrectionView:didReplaceString:toString:)]) {
                    [strongSelf.delegate autoCorrectionView:strongSelf didReplaceString:original toString:correction];
                }
                
                NSRange range = [text rangeOfString:original options:NSBackwardsSearch];
                if (range.location != NSNotFound) {
                    [strongSelf.textChecker addCorretedWord:original inRange:range];
                }
            });
        }
    };
    
    [self.correctionQueue addOperation:operation];
}

- (BOOL)checkNeedSeparateText:(NSString *)text before:(NSString *)before after:(NSString *)after {
    if (!self.isDataCreated) {
        return NO;
    }
    
    if (!self.isAutoCorrect) {
        return NO;
    }
    
    if (text.length != 1) {
        return NO;
    }
    
    if (before.length == 0) {
        return NO;
    }
    
    if ([text rangeOfCharacterFromSet:self.checkSeparateCharacterSet].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Actions

- (IBAction)actionButton {
    [self updateButtonsUI];
}

- (IBAction)actionSelectString:(UIButton *)button {
    NSString *selectedString = nil;
    if (button == self.originalButton && self.original.length > 0) {
        selectedString = self.original;
    } else {
        selectedString = [button titleForState:UIControlStateNormal];
    }
    
    if (selectedString) {
        if ([self.delegate respondsToSelector:@selector(autoCorrectionView:didSelectString:)]) {
            [self.delegate autoCorrectionView:self didSelectString:[selectedString copy]];
        }
    }
    
    [self updateButtonsUI];
}


#pragma mark - Private

- (void)updateWithOriginal:(NSString *)original correction:(MPTCString *)correction other:(NSArray *)other {
    self.originalButton.enabled = NO;
    self.correctionButton.enabled = NO;
    self.otherButton.enabled = NO;
    
    NSInteger index = 0;
    NSString *title = nil;
    self.correction = self.isAutoCorrect ? correction.string : nil;
    if (correction.string) {
        title = correction.string;
    } else {
        if (index < other.count) {
            title = ((MPTCString *)other[index ++]).string;
        }
    }
    [self.correctionButton setTitle:title forState:UIControlStateNormal];
    if (title) {
        self.correctionButton.enabled = YES;
    }
    
    title = nil;
    self.original = original;
    if (self.original) {
        title = self.original;
    } else {
        if (index < other.count) {
            title = ((MPTCString *)other[index ++]).string;
        }
    }
    [self.originalButton setTitle:title forState:UIControlStateNormal];
    if (title) {
        self.originalButton.enabled = YES;
    }
    
    title = nil;
    if (index < other.count) {
        title = ((MPTCString *)other[index ++]).string;
    }
    [self.otherButton setTitle:title forState:UIControlStateNormal];
    if (title) {
        self.otherButton.enabled = YES;
    }
    
    [self updateButtonsUI];
}


#pragma mark - Private UI

- (void)updateButtonsUI {
    BOOL isHighlighted = NO;
    for (UIButton *button in self.buttonsArray) {
        if (button.highlighted) {
            isHighlighted = YES;
            break;
        }
    }
    
    for (UIButton *button in self.buttonsArray) {
        UIView *selectedView = [self viewWithTag:button.tag + 10 + ((self.currentKBTheme == KBThemeTransparent) ? 10 : 0)];
        if (isHighlighted) {
            if (selectedView) {
                selectedView.hidden = !button.highlighted;
            }
            button.selected = NO;
        } else {
            if (button == self.originalButton && self.original && !self.correction) {
                if (self.currentKBTheme == KBThemeOriginal) {
                    button.selected = YES;
                } else {
                    button.selected = NO;
                }
                selectedView.hidden = NO;
            } else if (button == self.correctionButton && self.correction) {
                button.selected = YES;
                selectedView.hidden = NO;
            } else {
                button.selected = NO;
                selectedView.hidden = YES;
            }
        }
    }
}


#pragma mark - ThemeChangesResponderProtocol

- (void)setTheme:(KBTheme)theme {
    self.currentKBTheme = theme;
    
    UIImage *backImage = nil;
    UIColor *highlightedTextColor = nil;
    switch (theme) {
        case KBThemeOriginal:
            highlightedTextColor = [UIColor whiteColor];
            self.backgroundColor = colorAdditionalMenuForTheme(theme);
            break;
        
        case KBThemeTransparent:
            backImage = nil;
            highlightedTextColor = [UIColor whiteColor];
            self.backgroundColor = colorAdditionalMenuForTheme(theme);
            break;

        case KBThemeClassic:
            backImage = [UIImage patternImageWithColor:RGB(236, 237, 240)];
            highlightedTextColor = RGB(0, 80, 215);
            self.backgroundColor = colorAdditionalMenuForTheme(theme);
            break;
            
        default:
            break;
    }
    
    for (UIView *view in self.originalThemeElements) {
        view.alpha = (theme == KBThemeOriginal) ? 1 : 0;
    }
    
    for (UIView *view in self.classicThemeElements) {
        view.alpha = (theme == KBThemeClassic) ? 1 : 0;
    }
    
    for (UIView *view in self.transparentThemeElements) {
        view.alpha = (theme == KBThemeTransparent) ? 1 : 0;
    }
    
    for (UIButton *button in self.buttonsArray) {
        [button setBackgroundImage:backImage forState:UIControlStateSelected];
        [button setBackgroundImage:backImage forState:UIControlStateHighlighted];
        [button setBackgroundImage:backImage forState:UIControlStateHighlighted | UIControlStateSelected];
        
        [button setTitleColor:highlightedTextColor forState:UIControlStateSelected];
        [button setTitleColor:highlightedTextColor forState:UIControlStateHighlighted];
        [button setTitleColor:highlightedTextColor forState:UIControlStateHighlighted | UIControlStateSelected];
    }
    
    [self updateButtonsUI];
}

@end

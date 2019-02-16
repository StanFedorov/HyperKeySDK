//
//  ACCharacterOperation.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 15.02.16.
//
//

#import "ACCharacterOperation.h"

//#define kMPTCStepTimeLog
#ifdef kMPTCStepTimeLog
#define ALLTICK NSLog(@"===> CharacterOperation"); NSDate *startAllTime = [NSDate date];
#define ALLTOCK NSLog(@"<=== CharacterOperation: %.3f", -[startAllTime timeIntervalSinceNow]);
#else
#define ALLTICK
#define ALLTOCK
#endif

//#define kMPTCExecuteTimeLog
#ifdef kMPTCExecuteTimeLog
NSDate *startTime;
#define TICK startTime = [NSDate date];
#define TOCK(title) NSLog(@"%@: %.3f", title, -[startTime timeIntervalSinceNow]);
#else
#define TICK
#define TOCK(title)
#endif

NSInteger const kACCharacterOperationMaxGuesses = 10;
NSInteger const kACCharacterOperationMaxPredictions = 3;
NSInteger const kACCharacterOperationMinAutocorrectionsCharacters = 1;

@interface ACCharacterOperation ()

@property (copy, nonatomic, readwrite) NSString *text;
@property (strong, nonatomic) MPTextChecker *textChecker;

@property (copy, nonatomic) NSString *original;
@property (strong, nonatomic) MPTCString *correction;
@property (strong, nonatomic) NSMutableArray *other;

@end

@implementation ACCharacterOperation

#pragma mark - Public

- (instancetype)initWithTextChecker:(MPTextChecker *)textChecker text:(NSString *)text {
    self = [super init];
    if (self) {
        self.textChecker = textChecker;
        self.text = text;
    }
    return self;
}

- (void)updateTextByReplaceString:(NSString *)replaceString toString:(NSString *)toString {
    if (replaceString.length > 0 && toString.length > 0) {
        NSRange range = [self.text rangeOfString:replaceString options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            self.text = [self.text stringByReplacingCharactersInRange:range withString:toString];
        }
    }
}


#pragma mark - Main

- (void)main {
    ALLTICK
    
    self.original = nil;
    self.correction = nil;
    self.other = [[NSMutableArray alloc] init];
    
    TICK
    NSString *lastWord = [self.textChecker lastWordForString:self.text];
    if (lastWord.length > 0) {
        self.original = lastWord;
    }
    TOCK(@"= Last Word")
    
    if (self.cancelled) {
        return;
    }
    
    TICK
    if (self.original && ![self isCanCorrectedWord:self.original]) {
        ALLTOCK
        
        [self willCompletion];
        return;
    }
    TOCK(@"= Can Corrected Word")
    
    if (self.cancelled) {
        return;
    }
    
    TICK
    MPTCString *original = nil;
    // Corrections for string
    NSArray *corrections = [self.textChecker correctionsForString:self.text original:&original];
    TOCK(@"= Corrections For String")
    
    
    TICK
    if (corrections.count > 0) {
        [self.other addObjectsFromArray:corrections];
    }
    TOCK(@"= Add Corrections To Other")
    
    if (self.cancelled) {
        return;
    }
    
    TICK
    if (!self.original) {
        // Defaults for new word
        if (self.other.count == 0) {
            NSArray *defaults = [self.textChecker defaultsForString:self.text];
            if (defaults.count > 0) {
                [self.other addObjectsFromArray:defaults];
            }
        }
        
        ALLTOCK
        
        [self willCompletion];
        return;
    }
    TOCK(@"= Defaults For String")
    
    TICK
    MPTCString *replacement = [self.textChecker replacementForWord:self.original];
    TOCK(@"= Replacement For Word")
    
    if (self.cancelled) {
        return;
    }
    
    TICK
    // Set correction for first prediction
    if (self.other.count > 0) {
        ((MPTCString *)self.other.firstObject).type = MPTCStringTypeCorrection;
    }
    TOCK(@"= Set Correction For First Prediction")
    
    if (self.cancelled) {
        return;
    }
    
    TICK
    // Insert replacement as correction if original not exist in prediction
    if (replacement) {
        if (self.other.count > 0 && [((MPTCString *)self.other.firstObject).string isEqualToString:self.original]) {
            [self.other removeObjectAtIndex:0];
        } else {
            [self.other insertObject:replacement atIndex:0];
        }
    }
    TOCK(@"= Insert Replacement")
        
    if (self.cancelled) {
        return;
    }
    
    TICK
    // Set correction word
    if (self.other.count > 0 && ![self isEmailDomain:self.original intoString:self.text]) {
        MPTCString *mptcString = self.other.firstObject;
        
        if (mptcString.type == MPTCStringTypeReplacement) {
            [self setupCorrection:mptcString];
        } else if (mptcString.type == MPTCStringTypeCorrection && self.original.length > kACCharacterOperationMinAutocorrectionsCharacters) {
            if (!original || (original && original.sortWeight * 1000 < mptcString.sortWeight)) {
                [self setupCorrection:mptcString];
            }
        }
    }
    TOCK(@"= Set Correction Word")
    
    ALLTOCK
    
    [self willCompletion];
}


#pragma mark - Private

- (void)setupCorrection:(MPTCString *)correction {
    NSRange range = [self.text rangeOfString:self.original options:NSBackwardsSearch];
    if (![self.textChecker isAlreadyCorrectedWord:self.original inRange:range]) {
        self.correction = correction;
        [self.other removeObjectAtIndex:0];
    }
}

- (void)willCompletion {
    if (self.willCompletionBlock) {
        self.willCompletionBlock(self.text, self.original, self.correction, self.other);
    }
}

- (BOOL)isCanCorrectedWord:(NSString *)word {
    return ([word rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound);
}

- (BOOL)isEmailDomain:(NSString *)word intoString:(NSString *)string {
    if (!word) {
        return NO;
    }
    NSRange range = [string rangeOfString:word options:NSBackwardsSearch];
    if (range.location != NSNotFound && range.location > 0) {
        if ([string characterAtIndex:range.location - 1] == '@') {
            return YES;
        }
    }
    return NO;
}

@end

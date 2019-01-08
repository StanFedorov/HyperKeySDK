//
//  ACCharacterOperation.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 15.02.16.
//
//

#import "ACCharacterOperation.h"

//#define kMPTCExecuteTimeLog

#ifdef kMPTCExecuteTimeLog
#define TICK NSDate *startTime = [NSDate date];
#define TOCK(title) NSLog(@"%@: %.3f", title, -[startTime timeIntervalSinceNow]);
#else
#define TICK
#define TOCK(title)
#endif

NSInteger const kACCharacterOperationMaxGuesses = 10;
NSInteger const kACCharacterOperationMaxPredictions = 3;
NSInteger const kACCharacterOperationMinAutocorrectionsCharacters = 1;

@interface ACCharacterOperation ()

@property (strong, nonatomic, readwrite) NSString *text;
@property (strong, nonatomic) MPTextChecker *textChecker;

@property (strong, nonatomic) NSString *original;
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
    TICK
    
    self.original = nil;
    self.correction = nil;
    self.other = [[NSMutableArray alloc] init];
    
    NSArray *words = [self.text componentsSeparatedByCharactersInSet:self.textChecker.wordSeparatorCharacterSet];
    
    if (self.cancelled) {
        return;
    }
    
    if (words.count > 0 && ((NSString *)words.lastObject).length > 0) {
        self.original = words.lastObject;
    }
    
    if (self.cancelled) {
        return;
    }
    
    if (self.original && ![self isCanCorrectedWord:self.original]) {
        TOCK(@"==== CharacterOperation ====")
        
        [self willCompletion];
        return;
    }
    
    if (self.cancelled) {
        return;
    }
    
    BOOL isEmailDomain = [self isEmailDomain:self.original intoString:self.text];
    
    if (self.cancelled) {
        return;
    }
    
    MPTCString *original = nil;
    // Corrections for string
    NSArray *corrections = [self.textChecker correctionsForString:self.text original:&original];
    if (corrections.count > 0) {
        [self.other addObjectsFromArray:corrections];
    }
    
    if (self.cancelled) {
        return;
    }
    
    if (!self.original) {
        // Defaults for new word
        if (self.other.count == 0) {
            NSArray *defaults = [self.textChecker defaultsForString:self.text];
            if (defaults.count > 0) {
                [self.other addObjectsFromArray:defaults];
            }
        }
        
        TOCK(@"==== CharacterOperation ====")
        
        [self willCompletion];
        return;
    }
    
    MPTCString *replacement = [self.textChecker replacementForWord:self.original];
    
    if (self.cancelled) {
        return;
    }
    
    // Set correction for first prediction
    if (self.other.count > 0) {
        ((MPTCString *)self.other.firstObject).type = MPTCStringTypeCorrection;
    }
    
    if (self.cancelled) {
        return;
    }
    
    // Insert replacement as correction if original not exist in prediction
    if (replacement) {
        if (self.other.count > 0 && [((MPTCString *)self.other.firstObject).string isEqualToString:self.original]) {
            [self.other removeObjectAtIndex:0];
        } else {
            [self.other insertObject:replacement atIndex:0];
        }
    }
        
    if (self.cancelled) {
        return;
    }
        
    // Set correction word
    if (self.other.count > 0) {
        MPTCString *mptcString = self.other.firstObject;
        if (!isEmailDomain) {
            if (mptcString.type == MPTCStringTypeReplacement) {
                [self setupCorrection:mptcString];
            } else if (mptcString.type == MPTCStringTypeCorrection && self.original.length > kACCharacterOperationMinAutocorrectionsCharacters) {
                if (!original || (original && original.sortWeight * 1000 < mptcString.sortWeight)) {
                    [self setupCorrection:mptcString];
                }
            }
        }
    }
    
    TOCK(@"==== CharacterOperation ====")
    
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

//
//  MPTextChecker.m
//  WordPrediction
//
//  Created by Maxim Popov popovme@gmail.com on 27.01.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTextChecker.h"

#import "MPTCCorrect.h"
#import "MPTCConfig.h"
#import "Config.h"

//#define kMPTCExecuteTimeLog

#ifdef kMPTCExecuteTimeLog
#define TICK NSDate *startTime = [NSDate date];
#define TOCK(title) NSLog(@"%@: %.3f", title, -[startTime timeIntervalSinceNow]);
#else
#define TICK
#define TOCK(title)
#endif

NSUInteger const kMPTCDefaultCount = 3;

UInt8 const kMPTCCorretsMaxWords = 10;
UInt8 const kMPTCNgramsLength = 3;

UInt8 const kMPTCCompletionDistinction = 5;

UInt8 const kMPTCTyposSize = 123;

UInt8 const kMPTCGuessesMaxLength = 20;
UInt8 const kMPTCGuessesMinLength = 2;
UInt8 const kMPTCGuessesMaxErrors = 4;
UInt8 const kMPTCGuessesMaxHighErrors = 1;
Float32 const kMPTCGuessesMaxErrorsFactor = 0.4;

@interface MPTextChecker ()

@property (strong, nonatomic) UITextChecker *systemTextChecker;
@property (strong, nonatomic) NSCharacterSet *sentenceSeparatorCharacterSet;
@property (strong, nonatomic) NSCharacterSet *predictionSeparatorCharacterSet;
@property (strong, nonatomic, readwrite) NSCharacterSet *wordSeparatorCharacterSet;

@property (strong, nonatomic) NSString *language;
@property (strong, nonatomic) NSMutableArray *alreadyCorrectedWords;

@property (strong, nonatomic) NSData *unigramsData;
@property (strong, nonatomic) NSData *ngramsData;
@property (strong, nonatomic) NSData *replacementsData;
@property (strong, nonatomic) NSArray *defaults;
@property (assign, nonatomic) BOOL isDataCreated;

@end

@implementation MPTextChecker {
    dispatch_queue_t _backgroundQueue;
    UInt8 _calc[kMPTCGuessesMaxLength + 1][kMPTCGuessesMaxLength + 1];
    UInt8 _typos[kMPTCTyposSize][kMPTCTyposSize];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _backgroundQueue = dispatch_queue_create("net.hyperkey.keyboard.MPTextChecker", nil);
        
        NSMutableCharacterSet *sentence = [[NSMutableCharacterSet alloc] init];
        [sentence formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
        [sentence formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@".?!"]];
        self.sentenceSeparatorCharacterSet = sentence;
        
        // TODO: Store corrected to language data
        NSCharacterSet *corrected = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-"];
        NSMutableCharacterSet *correctedFull = [[NSMutableCharacterSet alloc] init];
        [correctedFull formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        [correctedFull formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
        [correctedFull formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]];
        [correctedFull formUnionWithCharacterSet:corrected];
        self.predictionSeparatorCharacterSet = [correctedFull invertedSet];
        
        NSMutableCharacterSet *word = [[NSMutableCharacterSet alloc] init];
        [word formUnionWithCharacterSet:self.predictionSeparatorCharacterSet];
        [word formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
        self.wordSeparatorCharacterSet = word;
        
        self.isDataCreated = NO;
        self.defaultCount = kMPTCDefaultCount;
        self.isAutoCapitalize = NO;
        self.isFullAccess = YES;
        self.systemTextChecker = [[UITextChecker alloc] init];
        self.alreadyCorrectedWords = [[NSMutableArray alloc] init];
        
        [self createCalcTable];
    }
    return self;
}


#pragma mark - Property

- (void)setDefaultCount:(NSUInteger)defaultCount {
    _defaultCount = MAX(defaultCount, 1);
}


#pragma mark - Public

- (void)initializeLanguage:(NSString *)language dataCreation:(BOOL)dataCreation completion:(void (^__nullable)(void))completion {
    self.language = language;
    
    dispatch_async(_backgroundQueue, ^{
        @synchronized (self) {
            [self createTypos];
            [self createDefaults];
            [self createReplacements];
            if (dataCreation) {
                [self createUnigrams];
                [self createNgrams];
                
                self.isDataCreated = YES;
            }
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)createCurrentLanguageDataWithCompletion:(void (^__nullable)(void))completion {
    if (self.language) {
        dispatch_async(_backgroundQueue, ^{
            @synchronized (self) {
                [self createUnigrams];
                [self createNgrams];
                
                self.isDataCreated = YES;
            }
            
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        });
    }
}

- (void)clearCurrentLanguageDataWithCompletion:(void (^__nullable)(void))completion {
    dispatch_async(_backgroundQueue, ^{
        @synchronized (self) {
            self.isDataCreated = NO;
            
            self.unigramsData = nil;
            self.ngramsData = nil;
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (BOOL)isAlreadyCorrectedWord:(NSString *)word inRange:(NSRange)range {
    MPTCCorrect *correct = [MPTCCorrect correctWithString:word range:range];
    if ([self.alreadyCorrectedWords indexOfObject:correct] != NSNotFound) {
        return YES;
    }
    return NO;
}

- (void)addCorretedWord:(NSString *)word inRange:(NSRange)range {
    MPTCCorrect *correct = [MPTCCorrect correctWithString:word range:range];
    [self.alreadyCorrectedWords addObject:correct];
    if (self.alreadyCorrectedWords.count > kMPTCCorretsMaxWords) {
        [self.alreadyCorrectedWords removeObjectAtIndex:0];
    }
}

- (NSArray *)stringsFromMPTCStrings:(NSArray *)mptcStrings {
    return [self stringsFromMPTCStrings:mptcStrings original:nil];
}

- (NSArray *)stringsFromMPTCStrings:(NSArray *)mptcStrings original:(nullable NSString *)original {
    NSMutableArray *strings = nil;
    if (mptcStrings.count > 0 || original.length > 0) {
        strings = [[NSMutableArray alloc] initWithCapacity:mptcStrings.count + 1];
        if (original.length > 0) {
            [strings addObject:original];
        }
        for (MPTCString *mptcString in mptcStrings) {
            [strings addObject:mptcString.string.lowercaseString];
        }
    }
    return strings;
}


#pragma mark - Public Guesses And Predictions

- (nullable NSArray *)defaultsForString:(NSString *)string {
    TICK
    BOOL isNeedCapitalized = YES;
    
    for (NSInteger i = string.length - 1; i >= 0; i --) {
        unichar character = [string characterAtIndex:i];
        if ([self.wordSeparatorCharacterSet characterIsMember:character]) {
            if ([self.sentenceSeparatorCharacterSet characterIsMember:character]) {
                break;
            }
        } else {
            isNeedCapitalized = NO;
            break;
        }
    }
    
    NSArray *defaults = self.defaults.count > 0 ? [[NSArray alloc] initWithArray:self.defaults copyItems:YES] : nil;
    
    TOCK(@"defaultsForString")
    
    return isNeedCapitalized ? [self capitalizeResults:defaults] : defaults;
}

- (nullable MPTCString *)replacementForWord:(NSString *)word {
    TICK
    
    UInt8 wordLength = word.length;
    if (word.length == 0) {
        return nil;
    }
    
    MPTCString *mptcString = nil;
    
    BOOL isNeedCapitalized = [self isCapitalizedString:word];
    
    UInt16 wordCharacters[wordLength];
    [word.lowercaseString getCharacters:wordCharacters range:NSMakeRange(0, wordLength)];
    
    @synchronized(self) {
        UInt8 *replacements = (UInt8 *)[self.replacementsData bytes];
        
        UInt8 unigramLength = 0;
        UInt8 replacementLength = 0;
        UInt32 index = 0;
        UInt32 lastIndex = (UInt32)self.replacementsData.length - 1;
        
        // [unigram length][replacement length][unigram][replacement]
        
        while (index < lastIndex) {
            unigramLength = replacements[index ++];
            replacementLength = replacements[index ++];
            
            if (wordLength != unigramLength) {
                index += (unigramLength + replacementLength);
                continue;
            }
            
            UInt8 i = 0;
            for (; i < unigramLength; i ++) {
                if (wordCharacters[i] != replacements[index + i]) {
                    break;
                }
            }
            if (i == unigramLength) {
                UInt8 *bytes = &replacements[index + unigramLength];
                NSString *string = [[NSString alloc] initWithBytes:bytes length:replacementLength encoding:NSUTF8StringEncoding];
                if (isNeedCapitalized) {
                    string = [self capitalizeString:string];
                }
                mptcString = [[MPTCString alloc] init];
                mptcString.string = string;
                mptcString.type = MPTCStringTypeReplacement;
                
                index = lastIndex;
            } else {
                index += (unigramLength + replacementLength);
            }
        }
    }
    
    TOCK(@"replacementForWord")
    
    return mptcString;
}

- (nullable NSArray *)correctionsForString:(NSString *)string original:(MPTCString * __nullable __autoreleasing * __nullable)original {
    return [self correctionsForString:string original:original count:self.defaultCount];
}

- (nullable NSArray *)correctionsForString:(NSString *)string original:(MPTCString * __nullable __autoreleasing * __nullable)original count:(NSUInteger)count {
    TICK
    
    if (original) {
        *original = nil;
    }
    
    if (!self.isDataCreated) {
        return nil;
    }
    
    // Find last words of the corresponding prediction
    NSString *wordsString = nil;
    NSRange range = [string rangeOfCharacterFromSet:self.predictionSeparatorCharacterSet options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        wordsString = [string copy];
    } else {
        wordsString = [string substringWithRange:NSMakeRange(range.location + 1, string.length - range.location - 1)];
    }
    
    // Separate string to words
    NSArray *words = [wordsString componentsSeparatedByCharactersInSet:self.wordSeparatorCharacterSet];
    if (words.count == 0) {
        return nil;
    }
    
    BOOL isNeedCapitalized = NO;
    
    // Find last word for correction (if exist)
    NSString *correctionWord = nil;
    NSInteger wordsIndex = words.count - 1;
    if (((NSString *)words.lastObject).length > 0) {
        NSString *word = words[wordsIndex --];
        isNeedCapitalized = [self isCapitalizedString:word];
        correctionWord = word;
    }
    
    // Correction character for correction word
    UInt8 wordLength = correctionWord.length;
    if (wordLength > kMPTCGuessesMaxLength) {
        return nil;
    }
    UInt16 wordCharacters[MAX(wordLength, 1)];
    if (wordLength > 0) {
        [correctionWord.lowercaseString getCharacters:wordCharacters range:NSMakeRange(0, wordLength)];
    }
    
    // Find word for ngrams
    NSMutableArray *ngramWords = [[NSMutableArray alloc] init];
    while (wordsIndex >= 0 && ngramWords.count < (kMPTCNgramsLength - 1)) {
        NSString *word = words[wordsIndex --];
        if (word.length > 0) {
            [ngramWords insertObject:word.lowercaseString atIndex:0];
        }
    }
    
    // Get characters form ngrams word 2
    NSString *word2 = nil;
    if (ngramWords.count > 0) {
        word2 = ngramWords.lastObject;
        [ngramWords removeLastObject];
    }
    UInt8 word2Length = word2.length;
    if (wordLength == 0 && word2Length == 0) {
        return nil;
    }
    UInt16 word2Characters[MAX(word2Length, 1)];
    if (word2Length > 0) {
        [word2.lowercaseString getCharacters:word2Characters range:NSMakeRange(0, word2Length)];
    }
    UInt32 word2DataIndex = 0;
    
    // Get characters form ngrams word 1
    NSString *word1 = nil;
    if (ngramWords.count > 0) {
        word1 = ngramWords.lastObject;
    }
    UInt8 word1Length = word1.length;
    UInt16 word1Characters[MAX(word1Length, 1)];
    if (word1Length > 0) {
        [word1.lowercaseString getCharacters:word1Characters range:NSMakeRange(0, word1Length)];
    }
    UInt32 word1DataIndex = 0;
    
    NSMutableArray *corrections = [[NSMutableArray alloc] init];
    NSMutableArray *completions = [[NSMutableArray alloc] init];
    
    UInt16 i = 0;
    UInt16 correctionsCount = 0;

    UInt8 minLenght = MAX(wordLength - 1, kMPTCGuessesMinLength);
    UInt8 maxLenght = MIN(wordLength + 1, kMPTCGuessesMaxLength);
    
    UInt8 minSeparatorsLenght = kMPTCGuessesMinLength;
    UInt8 maxSeparatorsLenght = wordLength - kMPTCGuessesMinLength;
    UInt32 separatorsData[maxSeparatorsLenght][2];
    for (i = 0; i < maxSeparatorsLenght; i ++) {
        separatorsData[i][0] = 0;
        separatorsData[i][1] = 0;
    }
    
    UInt8 guessesMaxErrors = MIN(ceilf(wordLength * kMPTCGuessesMaxErrorsFactor), kMPTCGuessesMaxErrors);
    UInt8 errorsWeight = 1;
    UInt8 highErrorsWeight = 10;
    UInt8 nearbyErrorsWeight = highErrorsWeight + errorsWeight;
    UInt8 maxErrorsWeight = guessesMaxErrors + (kMPTCGuessesMaxHighErrors * 2 + 1);
    UInt8 maxHighErrorsWeight = (kMPTCGuessesMaxHighErrors * 2 + 1) * highErrorsWeight + maxErrorsWeight;
    
    @synchronized(self) {
        UInt8 *unigrams = (UInt8 *)[self.unigramsData bytes];
        
        UInt8 unigramLength = 0;
        UInt8 spelling = 0;
        UInt8 bytesLength = 0;
        UInt32 index = 1;
        UInt32 lastIndex = (UInt32)self.unigramsData.length - 1;
        
        // [unigram lenght][?(is spelling)][unigram characters][spelling characters][weight]
        // [unigram length][unigram characters][weight]
        while (index < lastIndex) {
            unigramLength = unigrams[index ++];
            bytesLength = unigramLength;
            
            // Get spelling bytes if exist spelling
            spelling = 0;
            if (unigrams[index] == '?') {
                index ++;
                spelling = 1;
                bytesLength *= 2;
            }
            bytesLength += 2;
            
            // Get unigram data index for ngrams word 1
            if (word1DataIndex == 0 && unigramLength == word1Length) {
                for (i = 0; i < unigramLength; i ++) {
                    if (unigrams[index + i] != word1Characters[i]) {
                        break;
                    }
                }
                if (i == unigramLength) {
                    word1DataIndex = index - 1 - (spelling > 0 ? 1 : 0);
                }
            }
            
            // Get unigram data index for ngrams word 2
            if (word2DataIndex == 0 && unigramLength == word2Length) {
                for (i = 0; i < unigramLength; i ++) {
                    if (unigrams[index + i] != word2Characters[i]) {
                        break;
                    }
                }
                if (i == unigramLength) {
                    word2DataIndex = index - 1 - (spelling > 0 ? 1 : 0);
                }
            }
            
            // Find completion
            if (wordLength > 0 && unigramLength > (wordLength + kMPTCGuessesMaxHighErrors) && unigramLength <= (wordLength + kMPTCCompletionDistinction)) {
                for (i = 0; i < wordLength; i ++) {
                    if (unigrams[index + i] != wordCharacters[i]) {
                        break;
                    }
                }
                if (i == wordLength) {
                    UInt8 *bytes = spelling > 0 ? &unigrams[index + unigramLength] : &unigrams[index];
                    
                    MPTCString *mptcString = [[MPTCString alloc] init];
                    mptcString.string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
                    mptcString.weight = int16FromBytes(unigrams, index + bytesLength - 2);
                    mptcString.type = MPTCStringTypeCompletion;
                    [completions addObject:mptcString];
                }
            }
            
            // Find separators
            if (unigramLength >= minSeparatorsLenght && unigramLength <= maxSeparatorsLenght) {
                // Find word from left
                for (i = 0; i < unigramLength; i ++) {
                    if (unigrams[index + i] != wordCharacters[i]) {
                        break;
                    }
                }
                if (i == unigramLength) {
                    separatorsData[unigramLength - minSeparatorsLenght][0] = index - 1 - (spelling > 0 ? 1 : 0);
                }
                
                // Find word from right
                for (i = 0; i < unigramLength; i ++) {
                    if (unigrams[index + unigramLength - 1 - i] != wordCharacters[wordLength - 1 - i]) {
                        break;
                    }
                }
                if (i == unigramLength) {
                    separatorsData[wordLength - i - minSeparatorsLenght][1] = index - 1 - (spelling > 0 ? 1 : 0);
                }
            }
            
            // Ignore for only predictions or guesses min length or correction word with different length more than 1
            if (wordLength < kMPTCGuessesMinLength || unigramLength < minLenght || unigramLength > maxLenght) {
                index += bytesLength;
                continue;
            }
            
            // Ignore for fist character is transposition or first character is not low error (typos error)
            if (wordCharacters[0] != unigrams[index]) {
                BOOL isTransposition = (wordCharacters[0] == unigrams[index + 1] && wordCharacters[1] == unigrams[index]);
                BOOL isTypos = (wordCharacters[0] <= kMPTCTyposSize && _typos[wordCharacters[0]][unigrams[index]] > 0);
                if (!isTransposition && !isTypos) {
                    index += bytesLength;
                    continue;
                }
            }
            
            UInt8 lastStringCharacter = 0;
            for (i = 1; i <= unigramLength; i ++) {
                UInt8 unigramCharacter = unigrams[index + i - 1];
                
                UInt8 from = MAX(i - kMPTCGuessesMaxHighErrors, 1);
                UInt8 to = MIN(i + kMPTCGuessesMaxHighErrors, wordLength);
                
                UInt8 lastWordCharacter = 0;
                for (UInt8 j = from; j <= to; j ++) {
                    UInt8 wordCharacter = wordCharacters[j - 1];
                    
                    UInt8 cost = 0;
                    if (wordCharacter != unigramCharacter) {
                        cost = errorsWeight;
                        if (!_typos[wordCharacter][unigramCharacter]) {
                            cost += highErrorsWeight;
                        }
                    };
                    UInt8 weight = MIN(MIN(_calc[i][j - 1] + nearbyErrorsWeight, _calc[i - 1][j] + nearbyErrorsWeight), _calc[i - 1][j - 1] + cost);
                    
                    if (wordCharacter == lastStringCharacter && unigramCharacter == lastWordCharacter && wordCharacter != unigramCharacter) {
                        UInt8 weightHightError = weight / highErrorsWeight * highErrorsWeight;
                        UInt8 weightError = weight % highErrorsWeight;
                        UInt8 prevWeightHighError = _calc[i - 2][j - 2] / highErrorsWeight * highErrorsWeight;
                        UInt8 prevWeightError = _calc[i - 2][j - 2] % highErrorsWeight;
                        if (prevWeightError == 9) {
                            prevWeightError = 0;
                        }
                        weight = MIN(weightHightError, prevWeightHighError) + MIN(weightError, prevWeightError + 1);
                    }
                    
                    if (weight > maxHighErrorsWeight || weight % highErrorsWeight > maxErrorsWeight) {
                        _calc[unigramLength][wordLength] = weight;

                        i = unigramLength;
                        j = wordLength;
                        continue;
                    }
                    
                    _calc[i][j] = weight;
                    lastWordCharacter = wordCharacter;
                }
                lastStringCharacter = unigramCharacter;
            }
            
            UInt8 weight = _calc[unigramLength][wordLength];
            UInt8 errorsCount = weight % highErrorsWeight;
            UInt8 highErrorsCount = weight / highErrorsWeight;
            
            if (errorsCount <= guessesMaxErrors && highErrorsCount <= kMPTCGuessesMaxHighErrors) {
                UInt8 *bytes = spelling > 0 ? &unigrams[index + unigramLength] : &unigrams[index];
                NSString *string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
                
                MPTCString *mptcString = [[MPTCString alloc] init];
                mptcString.dataIndex = index - 1 - (spelling > 0 ? 1 : 0);
                mptcString.string = string;
                mptcString.errorsCount = errorsCount;
                mptcString.lowErrorsCount = errorsCount - highErrorsCount;
                mptcString.highErrorsCount = highErrorsCount;
                mptcString.lengthErrorsCount = abs(wordLength - unigramLength);
                mptcString.weight = int16FromBytes(unigrams, index + bytesLength - 2);
                mptcString.type = MPTCStringTypeGuesses;
                [corrections addObject:mptcString];
                
                if ([(isNeedCapitalized ? [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[string substringToIndex:1] uppercaseString]] : string) isEqualToString:correctionWord]) {
                    if (original) {
                        *original = mptcString;
                    }
                }
            }
            
            index += bytesLength;
        }
        
        // Get ngrams data
        UInt8 *ngrams = (UInt8 *)[self.ngramsData bytes];
        UInt32 ngrams2Index = int24FromBytes(ngrams, 0);
        
        // [ngram2Index]
        // [ngram3word3 count][ngram3word1][ngram3word2]{[word][weight],[word][weight],...}
        // [ngram2word3 count][ngram2word2]{[word][weight],[word][weight],...}
        
        correctionsCount = corrections.count;
        
        BOOL existGuesses = (correctionsCount > 0);
        
        // Predictions with 3 gramms
        if (word1DataIndex > 0 && (existGuesses || wordLength == 0)) {
            index = 3;
            lastIndex = ngrams2Index;
            
            while (index < lastIndex) {
                UInt16 ngramsCount = int16FromBytes(ngrams, index);
                index += 2;
                
                UInt32 ngramsWord1DataIndex = int24FromBytes(ngrams, index);
                index += 3;
                
                if (ngramsWord1DataIndex == word1DataIndex) {
                    UInt32 ngramsWord2DataIndex = int24FromBytes(ngrams, index);
                    index += 3;
                    if (ngramsWord2DataIndex == word2DataIndex) {
                        findNgrams(ngrams, ngramsCount, index, unigrams, &corrections, correctionsCount, &completions, wordCharacters, wordLength, MPTCStringTypePrediction3ngram);
                        
                        index = lastIndex;
                    } else {
                        index += (5 * ngramsCount);
                    }
                } else {
                    index += (3 + 5 * ngramsCount);
                }
            }
        }
        
        correctionsCount = corrections.count;
        
        // Predictions with 2 gramms
        if (word2DataIndex > 0 && (existGuesses || wordLength == 0)) {
            index = ngrams2Index;
            lastIndex = (UInt32)self.ngramsData.length;
            
            while (index < lastIndex) {
                UInt16 ngramsCount = int16FromBytes(ngrams, index);
                index += 2;
                
                UInt32 ngrams2Word1DataIndex = int24FromBytes(ngrams, index);
                index += 3;
                
                if (ngrams2Word1DataIndex == word2DataIndex) {
                    findNgrams(ngrams, ngramsCount, index, unigrams, &corrections, correctionsCount, &completions, wordCharacters, wordLength, MPTCStringTypePrediction2ngram);
                    
                    index = lastIndex;
                } else {
                    index += (5 * ngramsCount);
                }
            }
        }
        
        // Filter separators
        for (i = 0; i < maxSeparatorsLenght; i ++) {
            if (separatorsData[i][0] > 0 && separatorsData[i][1] > 0) {
                MPTCString *mptcString = [[MPTCString alloc] init];
                mptcString.string = @"";
                mptcString.type = MPTCStringTypeSeparators;
                mptcString.errorsCount = 1;
                mptcString.highErrorsCount = 1;
                
                for (UInt8 j = 0; j <= 1; j ++) {
                    index = separatorsData[i][j];
                    
                    unigramLength = unigrams[index ++];
                    bytesLength = unigramLength;
                    spelling = 0;
                    if (unigrams[index] == '?') {
                        index ++;
                        spelling = 1;
                        bytesLength *= 2;
                    }
                    bytesLength += 2;
                    
                    UInt8 *bytes = spelling > 0 ? &unigrams[index + unigramLength] : &unigrams[index];
                    NSString *string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
                    UInt16 weight = int16FromBytes(unigrams, index + bytesLength - 2);
                    
                    if (mptcString.string.length > 0) {
                        mptcString.string = [mptcString.string stringByAppendingString:@" "];
                    }
                    mptcString.string = [mptcString.string stringByAppendingString:string];
                    mptcString.weight += (weight / 2);
                }
                
                [corrections addObject:mptcString];
            }
        }
    }
    
    if (corrections.count > 0) {
        sortWeightOfArray(&corrections);
        
        // Remove original from corrections
        if (original && *original) {
            [corrections removeObject:*original];
        }
    }
    
    if (completions.count > 0) {
        sortWeightOfArray(&completions);
        
        // Insert completions into correctios
        // TODO: Update to count params
        if (corrections.count == 0 || wordLength == 1) {
            [corrections insertObject:completions[0] atIndex:0];
            if (completions.count > 1) {
                [corrections insertObject:completions[1] atIndex:1];
            }
        } else {
            [corrections insertObject:completions.firstObject atIndex:1];
        }
    }
    
    NSArray *result = nil;
    if (corrections.count > 0) {
        // Remove dublicates
        UInt16 from = 1;
        correctionsCount = corrections.count;
        while (from < count && from < (correctionsCount - 1)) {
            MPTCString *correct = corrections[from];
            for (i = 0; i < from; i ++) {
                if ([((MPTCString *)corrections[i]).string isEqualToString:correct.string]) {
                    break;
                }
            }
            if (i < from) {
                [corrections removeObjectAtIndex:from];
                correctionsCount --;
            } else {
                from ++;
            }
        }
        
        // Return result count
        result = corrections.count > count ? [corrections subarrayWithRange:NSMakeRange(0, count)] : corrections;
        
        if (isNeedCapitalized) {
            result = [self capitalizeResults:result];
        }
    } else if (wordLength > 0 && self.isFullAccess) {
        result = [self systemGuessesForWord:correctionWord count:count];
    }
    
    TOCK(@"correctionsForString")
    
    return result;
}


// Method not used, this is alpha version of base separations
- (nullable NSArray *)separationsForString:(NSString *)string {
    TICK
    
    NSMutableArray *separators = [[NSMutableArray alloc] init];
    
    NSString *correctionWord = string.lowercaseString;
    UInt8 wordLength = correctionWord.length;
    UInt16 wordCharacters[wordLength];
    [correctionWord.lowercaseString getCharacters:wordCharacters range:NSMakeRange(0, wordLength)];
    
    UInt8 *unigrams = (UInt8 *)[self.unigramsData bytes];
    
    UInt8 unigramLength = 0;
    UInt8 spelling = 0;
    UInt8 bytesLength = 0;
    UInt32 index = 1;
    UInt32 lastIndex = (UInt32)self.unigramsData.length - 1;
    
    UInt16 i = 0;
    
    UInt8 minLenght = kMPTCGuessesMinLength;
    UInt8 maxLenght = wordLength - kMPTCGuessesMinLength;
    
    UInt32 separatorsData[maxLenght][2];
    for (i = 0; i < maxLenght; i ++) {
        separatorsData[i][0] = 0;
        separatorsData[i][1] = 0;
    }
    
    // [unigram lenght][?(is spelling)][unigram characters][spelling characters][weight]
    // [unigram length][unigram characters][weight]
    
    while (index < lastIndex) {
        bytesLength = unigramLength = unigrams[index ++];
        
        // Get spelling bytes if exist spelling
        spelling = 0;
        if (unigrams[index] == '?') {
            index ++;
            spelling = 1;
            bytesLength *= 2;
        }
        bytesLength += 2;
        
        if (unigramLength < minLenght || unigramLength > maxLenght) {
            index += bytesLength;
            continue;
        }
        
        // Find word from left
        for (i = 0; i < unigramLength; i ++) {
            if (unigrams[index + i] != wordCharacters[i]) {
                break;
            }
        }
        if (i == unigramLength) {
            separatorsData[unigramLength - minLenght][0] = index - 1 - (spelling > 0 ? 1 : 0);
            [self testShowWordFromUnigramDataIndex:separatorsData[unigramLength - minLenght][0]];
        }
        
        // Find word from right
        for (i = 0; i < unigramLength; i ++) {
            if (unigrams[index + unigramLength - 1 - i] != wordCharacters[wordLength - 1 - i]) {
                break;
            }
        }
        if (i == unigramLength) {
            separatorsData[wordLength - i - minLenght][1] = index - 1 - (spelling > 0 ? 1 : 0);
            //[self testShowWordFromUnigramDataIndex:separatorsData[wordLength - 1 - i - minLenght][1]];
        }
        
        index += bytesLength;
    }
    
    // Find separators
    for (i = 0; i < maxLenght; i ++) {
        if (separatorsData[i][0] > 0 && separatorsData[i][1] > 0) {
            MPTCString *mptcString = [[MPTCString alloc] init];
            mptcString.string = @"";
            mptcString.type = MPTCStringTypeSeparators;
            mptcString.errorsCount = 1;
            mptcString.highErrorsCount = 1;
            
            for (UInt8 j = 0; j <= 1; j ++) {
                index = separatorsData[i][j];
                
                bytesLength = unigramLength = unigrams[index ++];
                spelling = 0;
                if (unigrams[index] == '?') {
                    index ++;
                    spelling = 1;
                    bytesLength *= 2;
                }
                bytesLength += 2;
                
                UInt8 *bytes = spelling > 0 ? &unigrams[index + unigramLength] : &unigrams[index];
                NSString *string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
                UInt16 weight = int16FromBytes(unigrams, index + bytesLength - 2);
                
                if (mptcString.string.length > 0) {
                    mptcString.string = [mptcString.string stringByAppendingString:@" "];
                }
                mptcString.string = [mptcString.string stringByAppendingString:string];
                mptcString.weight += weight;
            }
            mptcString.weight /= 2;
            
            [separators addObject:mptcString];
        }
    }
    
    TOCK(@"separationsForString")
    
    return separators.count > 0 ? separators : nil;
}


#pragma mark - Private Data Creator

- (void)createCalcTable {
    for (NSInteger i = 0; i <= kMPTCGuessesMaxLength; i ++) {
        for (NSInteger j = 0; j <= kMPTCGuessesMaxLength; j ++) {
            _calc[i][j] = 99;
        }
    }
    _calc[0][0] = 0;
    _calc[0][1] = 12;
    _calc[1][0] = 12;
}

- (void)createTypos {
    for (UInt8 i = 0; i < kMPTCTyposSize; i ++) {
        for (UInt8 j = 0; j < kMPTCTyposSize; j ++) {
            _typos[i][j] = 0;
        }
    }
    
    NSData *data = [self dataWithFilePrefix:kMPTCTyposPrefix];
    if (!data) {
        return;
    }
    
    UInt8 *typosData = (UInt8 *)[data bytes];
    
    NSUInteger index = 0;
    NSUInteger lastIndex = data.length - 1;
    
    while (index < lastIndex) {
        UInt8 code = typosData[index ++];
        UInt8 length = typosData[index ++];
        for (UInt8 i = 0; i < length; i ++) {
            UInt8 typo = typosData[index ++];
            _typos[code][typo] = 1;
        }
    }
}

- (void)createDefaults {
    NSData *data = [self dataWithFilePrefix:kMPTCDefaultsPrefix];
    if (!data) {
        return;
    }
    
    NSMutableArray *defaults = [[NSMutableArray alloc] init];
    
    UInt8 *defaultsData = (UInt8 *)[data bytes];
    
    NSUInteger index = 0;
    NSUInteger lastIndex = data.length - 1;
    
    while (index < lastIndex) {
        UInt8 length = defaultsData[index ++];
        UInt8 *bytes = &defaultsData[index];
        
        MPTCString *mptcString = [[MPTCString alloc] init];
        mptcString.string = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
        mptcString.type = MPTCStringTypeDefaults;
        [defaults addObject:mptcString];
        
        index += length;
    }
    self.defaults = defaults;
}

- (void)createReplacements {
    self.replacementsData = [self dataWithFilePrefix:kMPTCReplacementsPrefix];
}

- (void)createUnigrams {
    self.unigramsData = [self dataWithFilePrefix:kMPTCUnigramsPrefix];
}

- (void)createNgrams {
    self.ngramsData = [self dataWithFilePrefix:kMPTCNgramsPrefix];
}

- (NSData *)dataWithFilePrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, self.language];
    NSString *filePath = [[NSBundle bundleForClass:NSClassFromString(@"HKKeyboardViewController")] pathForResource:fileName ofType:@"dat"];
    return [[NSData alloc] initWithContentsOfFile:filePath];
}


#pragma mark - Private

- (BOOL)isCapitalizedString:(NSString *)string {
    if (string.length > 0) {
        return [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[string characterAtIndex:0]];
    }
    return NO;
}

- (NSArray *)capitalizeResults:(NSArray *)results {
    for (MPTCString *mptcString in results) {
        if (mptcString.string.length > 0) {
            mptcString.string = [self capitalizeString:mptcString.string];
        }
    }
    return results;
}

- (NSString *)capitalizeString:(NSString *)string {
    return [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[string substringToIndex:1] uppercaseString]];
}


#pragma mark - Private System Guesses

- (NSArray *)systemGuessesForWord:(NSString *)word count:(NSUInteger)count {
    NSRange misspelledRange = [self.systemTextChecker rangeOfMisspelledWordInString:word range:NSMakeRange(0, word.length) startingAt:0 wrap:NO language:@"en_US"];
    
    if (misspelledRange.location != NSNotFound) {
        NSArray *systemGuesses = [self.systemTextChecker guessesForWordRange:NSMakeRange(0, word.length) inString:word language:@"en_US"];
        if (systemGuesses.count > 0) {
            NSUInteger guessesCount = MIN(count, systemGuesses.count);
            NSMutableArray *guesses = [[NSMutableArray alloc] initWithCapacity:guessesCount];
            for (NSInteger i = 0; i < guessesCount; i++) {
                NSString *string = systemGuesses[i];
                NSUInteger weight = guessesCount - i;
                [guesses addObject:[[MPTCString alloc] initWithString:string weight:weight type:MPTCStringTypeGuesses]];
            }
            return guesses;
        }
    }
    return nil;
}


#pragma mark - Inline

NS_INLINE UInt32 int24FromBytes(UInt8 *bytes, NSUInteger index) {
    return bytes[index] | *(UInt16 *)&bytes[index + 1] << 8;
}

NS_INLINE UInt16 int16FromBytes(UInt8 *bytes, NSUInteger index) {
    return *(UInt16 *)&bytes[index];
}

NS_INLINE void sortWeightOfArray(NSMutableArray **array) {
    [*array makeObjectsPerformSelector:@selector(calculateSortWeight)];
    
    // Sort completions by weight
    [*array sortUsingComparator:^NSComparisonResult(MPTCString *obj1, MPTCString *obj2) {
        if (obj1.sortWeight > obj2.sortWeight) {
            return NSOrderedAscending;
        } else if (obj1.sortWeight < obj2.sortWeight) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

NS_INLINE void findNgrams(UInt8 *ngrams, UInt16 ngramsCount, UInt32 index, UInt8 *unigrams, NSMutableArray **corrections, UInt16 correctionsCount, NSMutableArray **completions, UInt16 *wordCharacters, UInt8 wordLength, MPTCStringType type) {
    UInt32 lastIndex = 0;
    UInt16 correctionsIndex = 0;
    UInt8 unigramLength = 0;
    UInt8 spelling = 0;
    UInt8 i = 0;
    
    if (wordLength > 0 && correctionsCount > 0) {
        MPTCString *correction = (*corrections)[correctionsIndex ++];
        lastIndex = index + 5 * ngramsCount;
        
        UInt32 dataIndex = int24FromBytes(ngrams, index);
        index += 3;
        
        do {
            if (correction.dataIndex < dataIndex) {
                correctionsIndex ++;
                if (correctionsIndex < correctionsCount) {
                    correction = (*corrections)[correctionsIndex];
                } else {
                    break;
                }
            } else if (correction.dataIndex > dataIndex) {
                // Find completion for prediction
                unigramLength = unigrams[dataIndex];
                if (unigramLength > (wordLength + kMPTCGuessesMaxHighErrors) && unigramLength <= (wordLength + kMPTCCompletionDistinction)) {
                    UInt32 unigramDataIndex = dataIndex + 1;
                    spelling = 0;
                    if (unigrams[unigramDataIndex] == '?') {
                        unigramDataIndex ++;
                        spelling = 1;
                    }
                    
                    for (i = 0; i < wordLength; i ++) {
                        if (unigrams[unigramDataIndex + i] != wordCharacters[i]) {
                            break;
                        }
                    }
                    
                    if (i == wordLength) {
                        if (spelling > 0) {
                            unigramDataIndex += unigramLength;
                        }
                        UInt8 *bytes = &unigrams[unigramDataIndex];
                        
                        MPTCString *mptcString = [[MPTCString alloc] init];
                        mptcString.string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
                        mptcString.weight = int16FromBytes(unigrams, unigramDataIndex + unigramLength);
                        mptcString.predictionWeight = int16FromBytes(ngrams, index);
                        mptcString.lengthErrorsCount = abs(wordLength - unigramLength);
                        mptcString.type = type;
                        [(*completions) addObject:mptcString];
                    }
                }
                
                index += 2;
                if (index < lastIndex) {
                    dataIndex = int24FromBytes(ngrams, index);
                    index += 3;
                } else {
                    break;
                }
            } else {
                UInt16 weight = int16FromBytes(ngrams, index);
                index += 2;
                
                if (correction.type == MPTCStringTypeGuesses) {
                    correction.predictionWeight = weight;
                    correction.type = type;
                }
                
                // Find completion for prediction
                unigramLength = unigrams[dataIndex];
                if (unigramLength > (wordLength + kMPTCGuessesMaxHighErrors) && unigramLength <= (wordLength + kMPTCCompletionDistinction)) {
                    UInt32 unigramDataIndex = dataIndex + 1;
                    spelling = 0;
                    if (unigrams[unigramDataIndex] == '?') {
                        unigramDataIndex ++;
                        spelling = 1;
                    }
                    
                    for (i = 0; i < wordLength; i ++) {
                        if (unigrams[unigramDataIndex + i] != wordCharacters[i]) {
                            break;
                        }
                    }
                    
                    if (i == wordLength) {
                        if (spelling > 0) {
                            unigramDataIndex += unigramLength;
                        }
                        UInt8 *bytes = &unigrams[unigramDataIndex];
                        
                        MPTCString *mptcString = [[MPTCString alloc] init];
                        mptcString.string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
                        mptcString.weight = int16FromBytes(unigrams, unigramDataIndex + unigramLength);
                        mptcString.predictionWeight = weight;
                        mptcString.lengthErrorsCount = abs(wordLength - unigramLength);
                        mptcString.type = type;
                        [(*completions) addObject:mptcString];
                    }
                }
                
                correctionsIndex ++;
                if (correctionsIndex < correctionsCount && index < lastIndex) {
                    correction = (*corrections)[correctionsIndex];
                    dataIndex = int24FromBytes(ngrams, index);
                    index += 3;
                } else {
                    break;
                }
            }
        } while (1);
    } else {
        // Prediction without corrections
        lastIndex = index + (5 * ngramsCount);
        do {
            UInt32 wordDataIndex = int24FromBytes(ngrams, index);
            index += 3;
            
            UInt16 weight = int16FromBytes(ngrams, index);
            index += 2;
            
            unigramLength = unigrams[wordDataIndex ++];
            spelling = 0;
            if (unigrams[wordDataIndex] == '?') {
                wordDataIndex ++;
                spelling = 1;
            }
            
            UInt8 *bytes = spelling > 0 ? &unigrams[wordDataIndex + unigramLength] : &unigrams[wordDataIndex];
            
            MPTCString *mptcString = [[MPTCString alloc] init];
            mptcString.string = [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
            mptcString.predictionWeight = weight;
            mptcString.lengthErrorsCount = abs(wordLength - unigramLength);
            mptcString.type = type;
            [(*corrections) addObject:mptcString];
        } while (index < lastIndex);
    }
}


#pragma mark - Test Methods

- (NSString *)testWordFromUnigramDataIndex:(UInt32)dataIndex {
    UInt8 *unigrams = (UInt8 *)[self.unigramsData bytes];
    
    UInt16 unigramLength = unigrams[dataIndex ++];
    UInt16 spelling = 0;
    if (unigrams[dataIndex] == '?') {
        dataIndex ++;
        spelling = 1;
    }
    
    UInt8 *bytes = spelling > 0 ? &unigrams[dataIndex + unigramLength] : &unigrams[dataIndex];
    return [[NSString alloc] initWithBytes:bytes length:unigramLength encoding:NSUTF8StringEncoding];
}

- (void)testShowWordFromUnigramDataIndex:(UInt32)dataIndex {
    NSLog(@"%@", [self testWordFromUnigramDataIndex:dataIndex]);
}

- (void)testShowCalcWithCorrectionWord:(NSString *)word unigramDataIndex:(UInt32)dataIndex {
    UInt8 *unigrams = (UInt8 *)[self.unigramsData bytes];
    UInt8 wordLength = word.length;
    
    NSString *line = @"    ";
    for (UInt8 j = 0; j < wordLength; j ++) {
        line = [line stringByAppendingFormat:@" %C ", [word characterAtIndex:j]];
    }
    NSLog(@"%@", line);
    
    line = @" ";
    for (UInt8 j = 0; j < (wordLength + 1); j ++) {
        line = [line stringByAppendingFormat:@" %.2d", _calc[0][j]];
    }
    NSLog(@"%@", line);
    
    UInt8 unigramLength = unigrams[dataIndex ++];
    if (unigrams[dataIndex] == '?') {
        dataIndex ++;
    }
    for (UInt8 i = 1; i < (unigramLength + 1); i ++) {
        line = [NSString stringWithFormat:@"%C", (unichar)unigrams[dataIndex ++]];
        for (UInt8 j = 0; j < (wordLength + 1); j ++) {
            line = [line stringByAppendingFormat:@" %.2d", _calc[i][j]];
        }
        NSLog(@"%@", line);
    }
}

@end

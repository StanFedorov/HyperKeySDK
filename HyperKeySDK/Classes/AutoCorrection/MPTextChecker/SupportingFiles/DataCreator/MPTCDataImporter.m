//
//  MPTCDataImporter.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 20.05.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCDataImporter.h"

#import "MPTCConfig.h"
#import "MPTCDataUtils.h"

@interface MPTCDataImporter ()

@property (strong, nonatomic) NSMutableDictionary *removeDictionary;
@property (strong, nonatomic) NSMutableDictionary *ignoreDictionary;
@property (strong, nonatomic) NSMutableDictionary *replaceDictionary;

@property (strong, nonatomic) NSMutableDictionary *customDictionary;
@property (strong, nonatomic) NSMutableDictionary *ngramsDictionary;
@property (strong, nonatomic) NSMutableDictionary *unigramsDictionary;
@property (strong, nonatomic) NSMutableDictionary *yclistDictionary;
@property (strong, nonatomic) NSMutableDictionary *scowlDictionary;
@property (strong, nonatomic) NSMutableDictionary *scowlFrequencyDictionary;

@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (strong, nonatomic) NSMutableArray *ngrams2Array;
@property (strong, nonatomic) NSMutableArray *ngrams3Array;

@end

@implementation MPTCDataImporter

- (void)importDataForFanguage:(nonnull NSString *)language {
    NSParameterAssert(language);
    
    [MPTCDataUtils setLanguage:language];
    
    self.removeDictionary = [[NSMutableDictionary alloc] init];
    self.ignoreDictionary = [[NSMutableDictionary alloc] init];
    self.replaceDictionary = [[NSMutableDictionary alloc] init];
    
    self.customDictionary = [[NSMutableDictionary alloc] init];
    self.ngramsDictionary = [[NSMutableDictionary alloc] init];
    self.unigramsDictionary = [[NSMutableDictionary alloc] init];
    self.yclistDictionary = [[NSMutableDictionary alloc] init];
    self.scowlDictionary = [[NSMutableDictionary alloc] init];
    self.scowlFrequencyDictionary = [[NSMutableDictionary alloc] init];
    
    self.dictionary = [[NSMutableDictionary alloc] init];
    self.ngrams2Array = [[NSMutableArray alloc] init];
    self.ngrams3Array = [[NSMutableArray alloc] init];
    
    // Prepare
    [self readSpecialDictionaryWithPrefix:kMPTCBaseRemove toDictionary:self.removeDictionary valuesCount:1];
    [self readSpecialDictionaryWithPrefix:kMPTCBaseIgnore toDictionary:self.ignoreDictionary valuesCount:1];
    [self readSpecialDictionaryWithPrefix:kMPTCBaseReplace toDictionary:self.replaceDictionary valuesCount:2];
    
    // Dictionary Unigrams
    [self readDictionaryWithPrefix:kMPTCBaseUnigrams toDictionary:self.unigramsDictionary valuesCount:2];
    [self filterDictionary:self.unigramsDictionary];
    
    // Dictionary Custom
    [self readDictionaryWithPrefix:kMPTCBaseCustom toDictionary:self.customDictionary valuesCount:2];
    
    // Dictionary Ngrams
    [self readDictionaryWithPrefix:kMPTCBaseNgrams2 toDictionary:self.ngramsDictionary valuesCount:3];
    [self readDictionaryWithPrefix:kMPTCBaseNgrams3 toDictionary:self.ngramsDictionary valuesCount:4];
    [self filterDictionary:self.ngramsDictionary];
    
    // Dictionary Yclist
    [self readDictionaryWithPrefix:kMPTCBaseYclist toDictionary:self.yclistDictionary defaultWeight:700];
    [self filterDictionary:self.yclistDictionary];
    
    // Dictionary Scowl
    [self readDictionaryWithPrefix:kMPTCBaseScowl toDictionary:self.scowlDictionary defaultWeight:50];
    [self filterDictionary:self.scowlDictionary];
    
    // Dictionary Scowl Frequency
    [self readDictionaryWithPrefix:kMPTCBaseScowlFrequency toDictionary:self.scowlFrequencyDictionary valuesCount:2];
    [self filterDictionary:self.scowlFrequencyDictionary];
    [self normalizeDictionary:self.scowlFrequencyDictionary];
    
    // Dictionary merge
    [self mergeDictionary:self.scowlFrequencyDictionary];
    [self mergeDictionary:self.unigramsDictionary];
    [self mergeDictionary:self.ngramsDictionary];
    [self mergeDictionary:self.yclistDictionary];
    [self mergeDictionary:self.scowlDictionary];
    [self mergeDictionary:self.customDictionary];
    
    // Ngrams
    [self readNgramsWithPrefix:kMPTCBaseYclist defaultWeight:700];
    [self readNgramsWithPrefix:kMPTCBaseNgrams2];
    [self readNgramsWithPrefix:kMPTCBaseNgrams3];
    
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Unigrams custom count: %@", @(self.customDictionary.count));
    NSLog(@"Unigrams yclist count: %@", @(self.yclistDictionary.count));
    NSLog(@"Unigrams scowl count: %@", @(self.scowlDictionary.count));
    NSLog(@"Unigrams scowl frequency count: %@", @(self.scowlFrequencyDictionary.count));
    NSLog(@"Unigrams count: %@", @(self.dictionary.count));
    NSLog(@"Ngrams2 count: %@", @(self.ngrams2Array.count));
    NSLog(@"Ngrams3 count: %@", @(self.ngrams3Array.count));
    
    [MPTCDataUtils logSplitter];
    
    [self writeUnigrams:self.dictionary toFileWithPrefix:kMPTCSourceUnigrams];
    [self writeNgrams:self.ngrams2Array toFileWithPrefix:kMPTCSourceNgrams2];
    [self writeNgrams:self.ngrams3Array toFileWithPrefix:kMPTCSourceNgrams3];
    
    NSLog(@"Finished data import");
}


#pragma mark - Private Read Files

- (void)readSpecialDictionaryWithPrefix:(NSString *)prefix toDictionary:(NSMutableDictionary *)dictionary valuesCount:(NSUInteger)valuesCount {
    [MPTCDataUtils readValuesWithPrefix:prefix block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count != valuesCount) {
            (*critical) = YES;
            return;
        }
        
        dictionary[values[0]] = valuesCount > 1 ? values[1] : @(0);
    }];
}

- (void)readDictionaryWithPrefix:(NSString *)prefix toDictionary:(NSMutableDictionary *)dictionary valuesCount:(NSUInteger)valuesCount {
    [self readDictionaryWithPrefix:prefix toDictionary:dictionary valuesCount:valuesCount defaultWeight:0];
}

- (void)readDictionaryWithPrefix:(NSString *)prefix toDictionary:(NSMutableDictionary *)dictionary defaultWeight:(NSUInteger)defaultWeight {
    [self readDictionaryWithPrefix:prefix toDictionary:dictionary valuesCount:2 defaultWeight:defaultWeight];
}

- (void)readDictionaryWithPrefix:(NSString *)prefix toDictionary:(NSMutableDictionary *)dictionary valuesCount:(NSUInteger)valuesCount defaultWeight:(NSUInteger)defaultWeight {
    __block NSUInteger removesCount = 0;
    __block NSUInteger replacesCount = 0;
    
    
    [MPTCDataUtils readValuesWithPrefix:prefix block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count > valuesCount) {
            (*critical) = YES;
            return;
        }
        
        NSInteger weight = defaultWeight > 0 ? defaultWeight : [values[valuesCount - 1] integerValue];
        
        for (NSInteger index = 0; index < valuesCount - 1; index ++) {
            NSString *word = values[index];
            NSInteger wordWeight = weight;
            
            // Remove words
            if (self.removeDictionary[word.lowercaseString]) {
                removesCount ++;
                
                NSLog(@"Remove word: %@", word);
                continue;
            }
                
            // Replace words
            NSString *replaceWord = self.replaceDictionary[word];
            if (replaceWord) {
                replacesCount ++;
                word = replaceWord;
                
                NSLog(@"Replace word: %@", replaceWord);
            }
        
            // If Unigrams
            if (values.count <= 2) {
                // Create Dictionary with more than one word
                NSArray *words = [self wordsFromString:values[0]];
                if (words.count > 1) {
                    for (NSString *word in words) {
                        dictionary[word] = @(wordWeight);
                    }
                    return;
                } else if (words.count != 1) {
                    (*critical) = YES;
                    return;
                }
            }
            
            
            // Sum all equals word weight
            /*NSNumber *dictionaryWeight = dictionary[word];
            if (dictionaryWeight) {
                wordWeight += [dictionaryWeight integerValue];
            }*/
            dictionary[word] = @(wordWeight);
        }
    }];
    
    NSLog(@"Removes: %@, Replaces: %@", @(removesCount), @(replacesCount));
}

- (void)readNgramsWithPrefix:(NSString *)prefix {
    [self readNgramsWithPrefix:prefix defaultWeight:0];
}

- (void)readNgramsWithPrefix:(NSString *)prefix defaultWeight:(NSUInteger)defaultWeight {
    [MPTCDataUtils readValuesWithPrefix:prefix block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count > (kMPTCNgramsLevels + 1)) {
            (*critical) = YES;
            return;
        }
        
        // If Dictionary Names with more than one word
        if (values.count == 1) {
            NSArray *words = [self wordsFromString:values[0]];
            if (words.count > 1) {
                values = words;
            } else {
                return;
            }
        }
        
        NSMutableArray *ngram = [[NSMutableArray alloc] initWithArray:values];
        
        if (defaultWeight > 0) {
            [ngram addObject:@(defaultWeight)];
        } else {
            // Replace NSString weight to NSNumber
            NSInteger lastIndex = ngram.count - 1;
            NSUInteger weight = [ngram[lastIndex] integerValue];
            [ngram replaceObjectAtIndex:lastIndex withObject:@(weight)];
        }
        
        NSUInteger count = ngram.count;
        NSInteger level = count - 1;
        
        NSMutableArray *ngrams = [self ngramsForLevel:level];
        if (!ngrams) {
            return;
        }
        
        if (defaultWeight == 0) {
            // Filter words by min weight
            if ([ngram[level] integerValue] < [self minWeightForLevel:level]) {
                NSLog(@"Ngrams minWeightError ngrams: %@", ngram);
                return;
            }
            
            // Replace words
            for (NSInteger i = 0; i < level; i ++) {
                NSString *replaceWord = self.replaceDictionary[ngram[i]];
                if (replaceWord) {
                    [ngram replaceObjectAtIndex:i withObject:replaceWord];
                    NSLog(@"Ngrams replace word: %@", replaceWord);
                }
            }
        }
        
        // Verify from dictionary
        for (NSInteger i = 0; i < level; i ++) {
            NSString *word = ngram[i];
            if (!self.dictionary[word]) {
                NSLog(@"Ngrams notExistInDictionary word: %@", word);
                return;
            }
        }
        
        [ngrams addObject:ngram];
    }];
}


#pragma mark - Utils

- (NSMutableArray *)ngramsForLevel:(NSUInteger)level {
    switch (level) {
        case 2:
            return self.ngrams2Array;
            break;
            
        case 3:
            return self.ngrams3Array;
            break;
            
        default:
            break;
    }
    return nil;
}

- (NSUInteger)minWeightForLevel:(NSUInteger)level {
    switch (level) {
        case 2:
            return kMPTCNgrams2MinWeight;
            break;
            
        case 3:
            return kMPTCNgrams3MinWeight;
            break;
            
        default:
            break;
    }
    return 0;
}

- (void)mergeDictionary:(NSDictionary *)dictionary {
    [self mergeDictionary:dictionary replace:NO];
}

- (void)mergeDictionary:(NSDictionary *)dictionary replace:(BOOL)replace {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started filter dictionary count: %@", @(dictionary.count));
    
    NSInteger addCount = 0;
    NSInteger existCount = 0;
    
    NSArray *words = [dictionary allKeys];
    for (NSString *word in words) {
        if (self.dictionary[word]) {
            if (replace) {
                self.dictionary[word] = dictionary[word];
            }
            existCount ++;
        } else {
            self.dictionary[word] = dictionary[word];
            addCount ++;
        }
    }
    
    NSLog(@"Finished filter dictionary count: %@; exist: %@, add: %@, result: %@", @(dictionary.count), @(existCount), @(addCount), @(self.dictionary.count));
}

- (NSArray *)wordsFromString:(NSString *)string {
    NSCharacterSet *whitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    
    NSRange range = [string rangeOfCharacterFromSet:whitespaceCharacters];
    if (range.location != NSNotFound || range.location != 0) {
        NSString *trimString = [string stringByTrimmingCharactersInSet:whitespaceCharacters];
        NSArray *words = [trimString componentsSeparatedByCharactersInSet:whitespaceCharacters];
        if (words.count <= kMPTCNgramsLevels) {
            for (NSString *word in words) {
                if (word.length == 0 || [self isNotCorrectWord:word]) {
                    return nil;
                }
            }
        } else {
            return nil;
        }
        return words;
    }
    return [NSArray arrayWithObject:string];
}

- (void)normalizeDictionary:(NSMutableDictionary *)dictionary {
    Float32 currentMaxWeight = 0;
    Float32 currentMinWeight = FLT_MAX;
    for (NSNumber *numWeight in dictionary.allValues) {
        Float32 weight = [numWeight floatValue];
        if (currentMaxWeight < weight) {
            currentMaxWeight = weight;
        }
        if (currentMinWeight > weight) {
            currentMinWeight = weight;
        }
    }
    Float32 maxWeight = kMPTCMaxWordWeight;
    Float32 minFactor = kMPTCMinWordWeightFactor;
    Float32 calcMaxWeight = currentMaxWeight - currentMinWeight;
    Float32 factor = (calcMaxWeight - maxWeight * minFactor) / (maxWeight * calcMaxWeight);
    
    for (NSString *key in dictionary.allKeys) {
        Float32 weight = [dictionary[key] floatValue] - currentMinWeight;
        NSInteger normalizeWeight = MAX(weight / (minFactor + weight * factor), 1);
        dictionary[key] = @(normalizeWeight);
    }
}

- (void)sortArrayByWeight:(NSMutableArray *)array {
    NSInteger lastIndex = ((NSArray *)array.firstObject).count - 1;
    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [obj2[lastIndex] compare:obj1[lastIndex]];
    }];
}


#pragma mark - Private Filters

- (void)filterDictionary:(NSMutableDictionary *)dictionary {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started filter dictionary count: %@", @(dictionary.count));
    
    NSArray *words = [dictionary allKeys];
    for (NSString *word in words) {
        if ([self isNotCorrectWord:word]) {
            [dictionary removeObjectForKey:word];
        }
    }
    
    NSLog(@"Finished filter dictionary count: %@", @(dictionary.count));
}

- (BOOL)isNotCorrectWord:(NSString *)word {
    if ([self isNotCorrectCharactersForWord:word] && !self.ignoreDictionary[word]) {
        NSLog(@"NotCorrectCharacters word: %@", word);
        return YES;
    }
    
    if ([self isNotCorrectOnlyOneCharactersForWord:word] && !self.ignoreDictionary[word]) {
        NSLog(@"NotCorrectOnlyOneCharacters word: %@", word);
        return YES;
    }
    
    if ([self isTrimCharactersForWord:word] && !self.ignoreDictionary[word]) {
        NSLog(@"TrimCharacters word: %@", word);
        return YES;
    }
    
    if ([self isTripleCharactersForWord:word] && !self.ignoreDictionary[word]) {
        NSLog(@"TripleCharactersForWord word: %@", word);
        return YES;
    }
    
    if ([self isOnlyDoubleCharacters:word] && !self.ignoreDictionary[word]) {
        NSLog(@"OnlyDoubleCharacters word: %@", word);
        return YES;
    }
    
    if ([self isMoreOneHyphen:word] && !self.ignoreDictionary[word]) {
        NSLog(@"MoreOneHyphen word: %@", word);
        return YES;
    }
    
    if ([self isNotCorrectLengthForWord:word] && !self.ignoreDictionary[word]) {
        NSLog(@"NotCorrectLength word: %@", word);
        return YES;
    }
    
    return NO;
}

- (BOOL)isNotCorrectCharactersForWord:(NSString *)word {
    return ![[MPTCDataUtils correctCharacters] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:word]];
}

- (BOOL)isNotCorrectOnlyOneCharactersForWord:(NSString *)word {
    return (word.length == 1 && ![[MPTCDataUtils oneCorrectCharacters] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:word]]);
}

- (BOOL)isTrimCharactersForWord:(NSString *)word {
    if ([[MPTCDataUtils trimCharacters] characterIsMember:[word characterAtIndex:0]]) {
        return YES;
    } else if (word.length > 1 && [[MPTCDataUtils trimCharacters] characterIsMember:[word characterAtIndex:word.length - 1]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isTripleCharactersForWord:(NSString *)word {
    NSUInteger length = word.length;
    if (length > 2) {
        unichar previousCharacter = 0;
        NSUInteger count = 0;
        for (NSInteger i = 0; i < length; i ++) {
            unichar character = [word characterAtIndex:i];
            if (character == previousCharacter) {
                count ++;
                if (count >= 3) {
                    return YES;
                }
            } else {
                count = 1;
                previousCharacter = character;
            }
        }
    }
    return NO;
}

- (BOOL)isOnlyDoubleCharacters:(NSString *)word {
    return (word.length == 2 && [word characterAtIndex:0] == [word characterAtIndex:1]);
}

- (BOOL)isMoreOneHyphen:(NSString *)word {
    NSUInteger length = word.length;
    if (length > 1) {
        unichar character = '-';
        NSUInteger count = 0;
        for (NSInteger i = 0; i < length; i ++) {
            if (character == [word characterAtIndex:i]) {
                count ++;
                if (count >= 2) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)isNotCorrectLengthForWord:(NSString *)word {
    return (word.length > [MPTCDataUtils maxCharacters]);
}


#pragma mark - Private Write Data

- (void)writeUnigrams:(NSDictionary *)unigrams toFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started unigrams write: %@", prefix);
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSArray *keys = [unigrams allKeys];
    for (NSString *word in keys) {
        [data addObject:@[word, unigrams[word]]];
    }
    
    [self removeDublicatesArray:data];
    [self sortArrayByWeight:data];
    
    [MPTCDataUtils writeArray:data toFileWithPrefix:prefix];
    
    NSLog(@"Finished unigrams write: %@", prefix);
}

- (void)writeNgrams:(NSMutableArray *)ngrams toFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started ngrams write: %@", prefix);
    
    [self removeDublicatesArray:ngrams];
    [self removeByOverMaxFirstRepeatsArray:ngrams];
    [self sortArrayByWeight:ngrams];
    
    [MPTCDataUtils writeArray:ngrams toFileWithPrefix:prefix];
    
    NSLog(@"Finished ngrams write: %@", prefix);
}

- (void)removeDublicatesArray:(NSMutableArray *)array {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started remove dublicates, array count: %@", @(array.count));
    
    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [self comparisonArray1:obj1 withArray2:obj2 index:0];
    }];
    
    for (NSInteger i = array.count - 1; i > 0; i --) {
        NSArray *objects1 = array[i];
        NSArray *objects2 = array[i - 1];
        NSInteger lastIndex = objects1.count - 1;
        BOOL equal = YES;
        for (NSInteger j = 0; j < lastIndex; j ++) {
            if (![objects1[j] isEqualToString:objects2[j]]) {
                equal = NO;
                break;
            }
        }
        if (equal) {
            if ([objects1[lastIndex] integerValue] > [objects2[lastIndex] integerValue]) {
                NSLog(@"Remove: %@", array[i - 1]);
                
                [array removeObjectAtIndex:i - 1];
            } else {
                NSLog(@"Remove: %@", array[i]);
                
                [array removeObjectAtIndex:i];
            }
        }
    }
                      
    NSLog(@"Finished remove dublicates, array count: %@", @(array.count));
}

- (NSComparisonResult)comparisonArray1:(NSArray *)array1 withArray2:(NSArray *)array2 index:(NSInteger)index {
    NSComparisonResult result = [array1[index] compare:array2[index]];
    if (result == NSOrderedSame && index < (array1.count - 2)) {
        result = [self comparisonArray1:array1 withArray2:array2 index:index + 1];
    }
    return result;
}

- (void)removeByOverMaxFirstRepeatsArray:(NSMutableArray *)array {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started removeByOverMaxFirstRepeats, array count: %@", @(array.count));
    
    // Sort by first word and weight
    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        NSComparisonResult result = [obj1[0] compare:obj2[0]];
        if (result == NSOrderedSame) {
            NSInteger lastIndex = obj1.count - 1;
            NSUInteger weight1 = [obj1[lastIndex] integerValue];
            NSUInteger weight2 = [obj2[lastIndex] integerValue];
            if (weight1 > weight2) {
                result = NSOrderedDescending;
            } else if (weight1 < weight2) {
                result = NSOrderedAscending;
            }
        }
        return result;
    }];
    
    // Remove many repeated first words
    NSString *previousWord = nil;
    NSUInteger count = 0;
    for (NSInteger i = array.count - 1; i > 0; i --) {
        NSString *word = array[i][0];
        if ([word isEqualToString:previousWord]) {
            count ++;
            if (count > kMPTCMaxNgramsFirstRepeats) {
                [array removeObjectAtIndex:i];
            }
        } else {
            previousWord = word;
            count = 1;
        }
    }
    
    NSLog(@"Finished removeByOverMaxFirstRepeats, array count: %@", @(array.count));
}

@end

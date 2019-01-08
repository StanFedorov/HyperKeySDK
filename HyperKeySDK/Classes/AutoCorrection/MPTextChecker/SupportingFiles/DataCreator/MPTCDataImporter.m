//
//  MPTCDataImporter.m
//  ACFastMemory
//
//  Created by Maxim Popov popovme@gmail.com on 20.05.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCDataImporter.h"

#import "MPTCDataUtils.h"

NSString *const kMPTCDataImporterIgnoreDictionary = @"ignore_dictionary";
NSUInteger const kMPTCDataImporterMinNgrams2FilterWeight = 85;
NSUInteger const kMPTCDataImporterMinNgrams3FilterWeight = 160;
NSUInteger const kMPTCDataImporterMaxNgramsFirstRepeats = 999;
NSUInteger const kMPTCDataImporterMaxWordWeight = 50000;
NSUInteger const kMPTCDataImporterMinimumWordWeightFactor = 5;

@interface MPTCDataImporter ()

@property (strong, nonatomic) NSCharacterSet *correctCharacters;
@property (strong, nonatomic) NSCharacterSet *uppercaseCharacters;
@property (strong, nonatomic) NSCharacterSet *trimCharacters;
@property (strong, nonatomic) NSCharacterSet *oneCorrectCharacters;
@property (assign, nonatomic) NSUInteger maxCharacters;

@property (strong, nonatomic) NSMutableDictionary *ignoreDictionary;
@property (strong, nonatomic) NSMutableDictionary *replaceDictionary;
@property (strong, nonatomic) NSMutableDictionary *dictionary;
@property (strong, nonatomic) NSMutableArray *ngrams2Array;
@property (strong, nonatomic) NSMutableArray *ngrams3Array;

@end

@implementation MPTCDataImporter

- (void)importDataForFanguage:(nonnull NSString *)language {
    NSParameterAssert(language);
    
    [MPTCDataUtils setLanguage:language];
    
    self.ignoreDictionary = [[NSMutableDictionary alloc] init];
    self.replaceDictionary = [[NSMutableDictionary alloc] init];
    self.dictionary = [[NSMutableDictionary alloc] init];
    self.ngrams2Array = [[NSMutableArray alloc] init];
    self.ngrams3Array = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *ngramsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *customDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *organozationDictionary = [[NSMutableDictionary alloc] init];
    
    NSLog(@"Started data import");
    
    [self readSettingsWithPrefix:@"base_settings"];
    [self readIgnoreDictionaryWithPrefix:@"base_ignore_dict"];
    [self readReplaceDictionaryWithPrefix:@"base_replace_dict"];
    
    // Ngrams
    [self readNgramsDictionaryWithPrefix:@"base_ngram_3" toDictionary:ngramsDictionary];
    [self readNgramsDictionaryWithPrefix:@"base_ngram_2" toDictionary:ngramsDictionary];
    [self filterDictionary:ngramsDictionary];
    [self filterCaseSensitivityDictionary:ngramsDictionary];
    [self addDictionary:ngramsDictionary replace:NO];
    
    // Custom unigrams
    [self readNgramsDictionaryWithPrefix:@"base_custom" toDictionary:customDictionary];
    [self addDictionary:customDictionary replace:YES];
    
    // Organizations
    [self readDictionaryWithPrefix:@"base_org_1" toDictionary:organozationDictionary defaultWeight:2000];
    [self readDictionaryWithPrefix:@"base_org_2" toDictionary:organozationDictionary defaultWeight:2000];
    [self readDictionaryWithPrefix:@"base_abbr" toDictionary:organozationDictionary defaultWeight:500];
    [self filterDictionary:organozationDictionary];
    [self addDictionary:organozationDictionary replace:NO];
    
    // Ngrams
    [self readNgramsWithPrefix:@"base_ngram_2"];
    [self readNgramsWithPrefix:@"base_ngram_3"];
    [self readNgramsWithPrefix:@"base_org_1" defaultWeight:2000];
    [self readNgramsWithPrefix:@"base_org_2" defaultWeight:2000];
    [self readNgramsWithPrefix:@"base_abbr" defaultWeight:500];
    
    // Write Data
    [self writeUnigrams:self.dictionary toFileWithPrefix:@"mptc_unigrams"];
    [self writeNgrams:self.ngrams2Array toFileWithPrefix:kMPTCDataUtilsNgram2Prefix];
    [self writeNgrams:self.ngrams3Array toFileWithPrefix:kMPTCDataUtilsNgram3Prefix];
    
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Unigrams count: %@", @(self.dictionary.count));
    NSLog(@"Ngrams2 count: %@", @(self.ngrams2Array.count));
    NSLog(@"Ngrams3 count: %@", @(self.ngrams3Array.count));
    
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Finished data import");
}


#pragma mark - Read Files

- (void)readSettingsWithPrefix:(NSString *)prefix {
    [MPTCDataUtils readFileWithPrefix:prefix usingBlock:^(NSArray *values, NSUInteger index, NSUInteger *errorsCount) {
        if (values.count != 2) {
            (*errorsCount) ++;
            return;
        }
        
        switch (index) {
            case 0:
                self.correctCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
                break;
                
            case 1:
                self.uppercaseCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
                break;
                
            case 2:
                self.oneCorrectCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
                break;
                
            case 3:
                self.trimCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
                break;
                
            case 4:
                self.maxCharacters = [values[1] integerValue];
                
            default:
                break;
        }
    }];
}

- (void)readIgnoreDictionaryWithPrefix:(NSString *)prefix {
    [MPTCDataUtils readFileWithPrefix:prefix usingBlock:^(NSArray *values, NSUInteger index, NSUInteger *errorsCount) {
        if (values.count != 1) {
            (*errorsCount) ++;
            return;
        }
        
        self.ignoreDictionary[values[0]] = @(0);
    }];
}

- (void)readReplaceDictionaryWithPrefix:(NSString *)prefix {
    [MPTCDataUtils readFileWithPrefix:prefix usingBlock:^(NSArray *values, NSUInteger index, NSUInteger *errorsCount) {
        if (values.count != 2) {
            (*errorsCount) ++;
            return;
        }
        
        self.replaceDictionary[values[0]] = values[1];
    }];
}

- (void)readNgramsDictionaryWithPrefix:(NSString *)prefix toDictionary:(NSMutableDictionary *)dictionary {
    [self readDictionaryWithPrefix:prefix toDictionary:dictionary defaultWeight:0];
}

- (void)readDictionaryWithPrefix:(NSString *)prefix toDictionary:(NSMutableDictionary *)dictionary defaultWeight:(NSUInteger)defaultWeight {
    __block NSUInteger ignoresCount = 0;
    __block NSUInteger replacesCount = 0;
    
    [MPTCDataUtils readFileWithPrefix:prefix usingBlock:^(NSArray *values, NSUInteger index, NSUInteger *errorsCount) {
        if (values.count > (kMPTCDataUtilsNgramsLevels + 1)) {
            (*errorsCount) ++;
            return;
        }
        
        NSInteger weight = defaultWeight > 0 ? defaultWeight : [values[0] integerValue];
        NSInteger i = defaultWeight > 0 ? 0 : 1;
        
        for (; i < values.count; i ++) {
            NSString *word = values[i];
            NSInteger wordWeight = weight;
            
            if (defaultWeight == 0) {
                // Ignore words
                if (self.ignoreDictionary[word.lowercaseString]) {
                    ignoresCount ++;
                    continue;
                }
                
                // Replace words
                NSString *replaceWord = self.replaceDictionary[word];
                if (replaceWord) {
                    replacesCount ++;
                    word = replaceWord;
                }
            }
            
            // Sum all equals word weight
            NSNumber *dictionaryWeight = dictionary[word];
            if (dictionaryWeight) {
                wordWeight += [dictionaryWeight integerValue];
            }
            dictionary[word] = @(wordWeight);
        }
    }];
    
    NSLog(@"Ignores: %@, Replaces: %@", @(ignoresCount), @(replacesCount));
}

- (void)addDictionary:(NSDictionary *)dictionary replace:(BOOL)replace {
    NSArray *words = [dictionary allKeys];
    for (NSString *word in words) {
        if (replace || !self.dictionary[word]) {
            self.dictionary[word] = dictionary[word];
        }
    }
}

- (void)readNgramsWithPrefix:(NSString *)prefix {
    [self readNgramsWithPrefix:prefix defaultWeight:0];
}

- (void)readNgramsWithPrefix:(NSString *)prefix defaultWeight:(NSUInteger)defaultWeight {
    [MPTCDataUtils readFileWithPrefix:prefix usingBlock:^(NSArray *values, NSUInteger index, NSUInteger *errorsCount) {
        if (values.count > (kMPTCDataUtilsNgramsLevels + 1)) {
            (*errorsCount) ++;
            return;
        }
        
        NSMutableArray *ngram = [[NSMutableArray alloc] initWithArray:values];
        if (defaultWeight > 0) {
            [ngram insertObject:@(defaultWeight) atIndex:0];
        }
        NSUInteger count = ngram.count;
        NSUInteger level = count - 1;
        
        NSMutableArray *ngrams = [self ngramsForLevel:level];
        if (!ngrams) {
            return;
        }
        NSUInteger minFilterWeight = [self minFilterWeightForLevel:level];
    
        if (defaultWeight == 0) {
            // Filter words by min weight
            if ([ngram[0] integerValue] < minFilterWeight) {
                return;
            }
            
            // Replace words
            for (NSUInteger i = 1; i < count; i ++) {
                NSString *replaceWord = self.replaceDictionary[ngram[i]];
                if (replaceWord) {
                    [ngram replaceObjectAtIndex:i withObject:replaceWord];
                }
            }
        }
        
        // Verify from dictionary
        BOOL existDictionary = YES;
        for (NSUInteger i = 1; i < count; i ++) {
            if (!self.dictionary[ngram[i]]) {
                existDictionary = NO;
                break;
            }
        }
        if (!existDictionary) {
            return;
        }
        
        [ngrams addObject:ngram];
    }];
}

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

- (NSUInteger)minFilterWeightForLevel:(NSUInteger)level {
    switch (level) {
        case 2:
            return kMPTCDataImporterMinNgrams2FilterWeight;
            break;
            
        case 3:
            return kMPTCDataImporterMinNgrams3FilterWeight;
            break;
            
        default:
            break;
    }
    return 0;
}


#pragma mark - Filters

- (void)filterDictionary:(NSMutableDictionary *)dictionary {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started filter dictionary count: %@", @(dictionary.count));
    
    NSArray *words = [dictionary allKeys];
    for (NSString *word in words) {
        if ([self isNotCorrectCharactersForWord:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
        
        if ([self isNotCorrectOnlyOneCharactersForWord:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
        
        if ([self isTrimCharactersForWord:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
        
        if ([self isTripleCharactersForWord:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
        
        if ([self isOnlyDoubleCharacters:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
        
        if ([self isMoreOneHyphen:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
        
        if ([self isNotCorrectLengthForWord:word]) {
            [dictionary removeObjectForKey:word];
            continue;
        }
    }
    
    NSLog(@"Finished filter dictionary count: %@", @(dictionary.count));
}

- (void)filterCaseSensitivityDictionary:(NSMutableDictionary *)dictionary {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started filter case sensitivity dictionary count: %@", @(dictionary.count));
    
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary copyItems:YES];
    NSMutableDictionary *dublicatesDictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary removeAllObjects];
    
    NSArray *words = [tempDictionary allKeys];
    for (NSString *word in words) {
        NSMutableArray *dublicates = [[NSMutableArray alloc] init];
        NSArray *existDublicates = dublicatesDictionary[word.lowercaseString];
        if (existDublicates) {
            [dublicates addObjectsFromArray:existDublicates];
        }
        [dublicates addObject:word];
        dublicatesDictionary[word.lowercaseString] = dublicates;
    }
    
    // Find best weight for different case sensitivity word
    for (NSString *word in words) {
        NSNumber *resultWeight = tempDictionary[word];
        NSString *resultWord = word;
        
        NSArray *dublicates = dublicatesDictionary[word.lowercaseString];
        if (dublicates) {
            if (dublicates.count > 1) {
                NSString *tempWord = resultWord;
                NSNumber *tempWeight = resultWeight;
                for (NSString *dublicateWord in dublicates) {
                    NSNumber *dublicateWordWeight = tempDictionary[dublicateWord];
                    if (dublicateWordWeight && [dublicateWordWeight integerValue] > [tempWeight integerValue]) {
                        tempWord = dublicateWord;
                        tempWeight = dublicateWordWeight;
                    }
                }
                if (![tempWord isEqualToString:resultWord]) {
                    resultWord = tempWord;
                    resultWeight = tempWeight;
                }
            }
            
            [dublicatesDictionary removeObjectForKey:word.lowercaseString];
        } else {
            continue;
        }

        dictionary[resultWord] = resultWeight;
    }
    
    NSLog(@"Started filter case sensitivity dictionary count: %@", @(dictionary.count));
}

- (BOOL)isNotCorrectCharactersForWord:(NSString *)word {
    return ![self.correctCharacters isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:word]];
}

- (BOOL)isNotCorrectOnlyOneCharactersForWord:(NSString *)word {
    return (word.length == 1 && ![self.oneCorrectCharacters isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:word]]);
}

- (BOOL)isTrimCharactersForWord:(NSString *)word {
    if ([self.trimCharacters characterIsMember:[word characterAtIndex:0]]) {
        return YES;
    } else if (word.length > 1 && [self.trimCharacters characterIsMember:[word characterAtIndex:word.length - 1]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isTripleCharactersForWord:(NSString *)word {
    NSUInteger length = word.length;
    if (length > 2) {
        unichar previousCharacter = 0;
        NSUInteger count = 0;
        for (NSUInteger i = 0; i < length; i ++) {
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
        for (NSUInteger i = 0; i < length; i ++) {
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
    return (word.length > self.maxCharacters);
}

- (BOOL)isLowercaseWord:(NSString *)word {
    NSRange range = [word rangeOfCharacterFromSet:self.uppercaseCharacters];
    if (range.location == NSNotFound) {
        return YES;
    }
    return NO;
}


#pragma mark - Write Data

- (void)writeUnigrams:(NSDictionary *)unigrams toFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started unigrams write: %@", prefix);
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSArray *words = [unigrams allKeys];
    for (NSString *word in words) {
        [data addObject:@[unigrams[word], word]];
    }
    
    NSLog(@"Started count: %@", @(data.count));
    [self removeDublicatesArray:data];
    NSLog(@"After remove dublicate count: %@", @(data.count));
    
    [self sortByWeightArray:data];
    [self normalizeByWeightArray:data];
    [MPTCDataUtils writeArray:data toFileWithPrefix:prefix];
    
    NSLog(@"Finished unigrams write: %@", prefix);
}

- (void)writeNgrams:(NSMutableArray *)ngrams toFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started ngrams write: %@", prefix);
    
    NSLog(@"Started count: %@", @(ngrams.count));
    [self removeDublicatesArray:ngrams];
    NSLog(@"After remove dublicate count: %@", @(ngrams.count));
    [self removeByOverMaxFirstRepeatsArray:ngrams];
    NSLog(@"After remove over max first repeats count: %@", @(ngrams.count));
    
    [self sortByWeightArray:ngrams];
    [self normalizeByWeightArray:ngrams];
    [MPTCDataUtils writeArray:ngrams toFileWithPrefix:prefix];
    
    NSLog(@"Finished ngrams write: %@", prefix);
}

- (void)sortByWeightArray:(NSMutableArray *)array {
    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        NSUInteger weight1 = [obj1[0] integerValue];
        NSUInteger weight2 = [obj2[0] integerValue];
        if (weight1 > weight2) {
            return NSOrderedAscending;
        } else if (weight1 < weight2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
}

- (void)normalizeByWeightArray:(NSMutableArray *)array {
    Float32 currentMaxWeight = [array[0][0] integerValue];
    Float32 maxWeight = kMPTCDataImporterMaxWordWeight;
    Float32 minFactor = kMPTCDataImporterMinimumWordWeightFactor;
    Float32 factor = (currentMaxWeight - maxWeight * minFactor) / (maxWeight * currentMaxWeight);
    
    for (NSUInteger i = 0; i < array.count; i ++) {
        NSMutableArray *objects = [[NSMutableArray alloc] initWithArray:array[i]];
        Float32 weight = [objects[0] floatValue];
        Float32 normalizeWeight = MAX(weight / (minFactor + weight * factor), 1);
        [objects replaceObjectAtIndex:0 withObject:@((NSUInteger)normalizeWeight)];
        [array replaceObjectAtIndex:i withObject:objects];
    }
}

- (void)removeDublicatesArray:(NSMutableArray *)array {
    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [self comparisonArray1:obj1 withArray2:obj2 index:1];
    }];
    
    for (NSUInteger i = array.count - 1; i > 0; i --) {
        NSArray *objects1 = array[i];
        NSArray *objects2 = array[i - 1];
        BOOL equal = YES;
        for (NSUInteger j = 1; j < objects1.count; j ++) {
            if (![objects1[j] isEqualToString:objects2[j]]) {
                equal = NO;
                break;
            }
        }
        if (equal) {
            if ([objects1[0] integerValue] > [objects2[0] integerValue]) {
                [array removeObjectAtIndex:i - 1];
            } else {
                [array removeObjectAtIndex:i];
            }
        }
    }
}

- (NSComparisonResult)comparisonArray1:(NSArray *)array1 withArray2:(NSArray *)array2 index:(NSUInteger)index {
    NSComparisonResult result = [array1[index] compare:array2[index]];
    if (result == NSOrderedSame && index < (array1.count - 1)) {
        result = [self comparisonArray1:array1 withArray2:array2 index:index + 1];
    }
    return result;
}

- (void)removeByOverMaxFirstRepeatsArray:(NSMutableArray *)array {
    [array sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        NSComparisonResult result = [obj1[1] compare:obj2[1]];
        if (result == NSOrderedSame) {
            NSUInteger weight1 = [obj1[0] integerValue];
            NSUInteger weight2 = [obj2[0] integerValue];
            if (weight1 > weight2) {
                result = NSOrderedDescending;
            } else if (weight1 < weight2) {
                result = NSOrderedAscending;
            }
        }
        return result;
    }];
    
    NSString *previousWord = nil;
    NSUInteger count = 0;
    for (NSUInteger i = array.count - 1; i > 0; i --) {
        NSString *word = array[i][1];
        if ([word isEqualToString:previousWord]) {
            count ++;
            if (count > kMPTCDataImporterMaxNgramsFirstRepeats) {
                [array removeObjectAtIndex:i];
            }
        } else {
            previousWord = word;
            count = 1;
        }
    }
}

@end

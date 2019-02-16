//
//  MPTCDataCreator.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 10.02.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCDataCreator.h"

#import "MPTCConfig.h"
#import "MPTCDataUtils.h"

@interface MPTCDataCreator ()

@property (strong, nonatomic) NSString *language;

@property (strong, nonatomic) NSMutableDictionary *unigrams;
@property (strong, nonatomic) NSMutableDictionary *ngrams2;
@property (strong, nonatomic) NSMutableDictionary *ngrams3;
@property (strong, nonatomic) NSMutableData *ngramsData;

@end

@implementation MPTCDataCreator

#pragma mark - Public

- (void)createDataForFanguage:(NSString *)language {
    NSParameterAssert(language);
    
    [MPTCDataUtils setLanguage:language];
    
    self.unigrams = [[NSMutableDictionary alloc] init];
    self.ngrams2 = [[NSMutableDictionary alloc] init];
    self.ngrams3 = [[NSMutableDictionary alloc] init];
    self.ngramsData = [[NSMutableData alloc] init];
    
    NSLog(@"Started data create");
    
    [self createTypos];
    [self createDefaults];
    [self createReplacements];
    [self createUnigrams];
    [self createNgrams];
    
    NSLog(@"Finished data create");
}


#pragma mark - Private

- (void)createTypos {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started create typos: %@", kMPTCSourceTypos);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    UInt8 bytesData[UINT8_MAX];
    UInt8 *bytes = bytesData;
    
    [MPTCDataUtils readValuesWithPrefix:kMPTCSourceTypos block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count != 2 || ((NSString *)values[0]).length != 1) {
           (*critical) = YES;
            return;
        }
        
        UInt8 code = [((NSString *)values[0]) characterAtIndex:0];
        NSString *string = values[1];
        
        UInt8 length = string.length;
        UInt8 position = 0;
        
        bytes[position ++] = code;
        bytes[position ++] = length;
        for (UInt8 i = 0; i < length; i ++) {
            bytes[position ++] = (UInt8)[string characterAtIndex:i];
        }
        [data appendBytes:bytes length:position];
    }];
    
    [MPTCDataUtils writeData:data toFileWithPrefix:kMPTCTypos];
    
    NSLog(@"Finished create typos");
}

- (void)createDefaults {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started create defaults: %@", kMPTCSourceDefaults);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    UInt8 bytesData[UINT8_MAX];
    UInt8 *bytes = bytesData;
    
    [MPTCDataUtils readValuesWithPrefix:kMPTCSourceDefaults block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count != 1) {
            (*critical) = YES;
            return;
        }
        
        NSString *characters = values[0];
        
        UInt8 length = characters.length;
        UInt8 position = 0;
        
        bytes[position ++] = length;
        for (UInt8 i = 0; i < length; i ++) {
            bytes[position ++] = (UInt8)[characters characterAtIndex:i];
        }
        [data appendBytes:bytes length:position];
    }];
    
    [MPTCDataUtils writeData:data toFileWithPrefix:kMPTCDefaults];
    
    NSLog(@"Finished create defaults");
}

- (void)createReplacements {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started create replacements: %@", kMPTCSourceReplacements);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    UInt8 bytesData[UINT8_MAX];
    UInt8 *bytes = bytesData;
    
    [MPTCDataUtils readValuesWithPrefix:kMPTCSourceReplacements block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count < 2) {
            (*critical) = YES;
            return;
        }
        
        NSString *unigram = values[0];
        NSString *replace = values[1];
        
        UInt8 unigramLength = unigram.length;
        UInt8 replaceLength = replace.length;
        UInt8 position = 0;
        
        bytes[position ++] = unigramLength;
        bytes[position ++] = replaceLength;
        for (UInt8 i = 0; i < unigramLength; i ++) {
            bytes[position ++] = (UInt8)[unigram characterAtIndex:i];
        }
        for (UInt8 i = 0; i < replaceLength; i ++) {
            bytes[position ++] = (UInt8)[replace characterAtIndex:i];
        }
        [data appendBytes:bytes length:position];
    }];
    
    [MPTCDataUtils writeData:data toFileWithPrefix:kMPTCReplacements];
    
    NSLog(@"Finished create replacements");
}

- (void)createUnigrams {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started create unigrams: %@", kMPTCSourceUnigrams);
    
    NSArray *lines = [MPTCDataUtils readLinesFromFileWithPrefix:kMPTCSourceUnigrams];
    lines = [lines sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSArray *values1 = [MPTCDataUtils valuesFromLine:obj1];
        NSArray *values2 = [MPTCDataUtils valuesFromLine:obj2];
        return [((NSString *)values1[0]).lowercaseString compare:((NSString *)values2[0]).lowercaseString];
    }];
    NSUInteger count = lines.count;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    UInt8 bytes[UINT8_MAX];
    
    // Reserved symbol (First unigram characters character must be more 0)
    [data appendBytes:@"?" length:1];
    
    for (NSUInteger index = 0; index < count; index ++) {
        NSArray *values = [MPTCDataUtils valuesFromLine:lines[index]];
        
        if (values.count < 2) {
            NSLog(@"WARNING: Incorrect Uniram, line: %@", lines[index]);
            return;
        }
        if (index != 0 && index % kMPTCLogStepSize == 0) {
            NSLog(@"Unigram imported %@ of %@", @(index), @(count));
        }
        
        NSString *word = ((NSString *)values[0]).lowercaseString;
        NSString *spelling = (![word isEqualToString:values[0]]) ? values[0] : nil;
        UInt16 weight = (UInt16)[values[1] integerValue];
        
        UInt8 length = word.length;
        UInt8 position = 0;
        
        bytes[position ++] = length;
        if (spelling) {
            bytes[position ++] = '?';
        }
        for (UInt8 i = 0; i < length; i ++) {
            bytes[position ++] = (UInt8)[word characterAtIndex:i];
        }
        if (spelling) {
            for (UInt8 i = 0; i < length; i ++) {
                bytes[position ++] = (UInt8)[spelling characterAtIndex:i];
            }
        }
        *((UInt16 *)&bytes[position]) = weight;
        position += 2;
        
        // Data index for ngrams
        NSString *wordKey = (spelling != nil) ? spelling : word;
        self.unigrams[wordKey] = @(data.length);
        
        [data appendBytes:bytes length:position];
    }
    
    [MPTCDataUtils writeData:data toFileWithPrefix:kMPTCUnigrams];
    
    NSLog(@"Unigram imported %@ of %@", @(count), @(count));
    NSLog(@"Finished create unigram");
}

- (void)createNgrams {
    [self prepearedNgramsWithFileName:kMPTCSourceNgrams3];
    [self prepearedNgramsWithFileName:kMPTCSourceNgrams2];
    
    for (NSInteger level = kMPTCNgramsLevels; level >= 2; level --) {
        [self importNgramsForLevel:level];
    }
    
    [MPTCDataUtils writeData:self.ngramsData toFileWithPrefix:kMPTCNgrams];
}

- (void)prepearedNgramsWithFileName:(NSString *)fileName {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started prepeared ngrams: %@", fileName);
    
    NSArray *lines = [MPTCDataUtils readLinesFromFileWithPrefix:fileName];
    if (lines.count == 0) {
        NSLog(@"WARNING: Incorrect Ngrams File");
        return;
    }
    NSUInteger level = [MPTCDataUtils valuesFromLine:lines.firstObject].count - 1;
    NSUInteger count = lines.count;
    
    for (NSUInteger index = 0; index < count; index ++) {
        NSArray *values = [MPTCDataUtils valuesFromLine:lines[index]];
        
        if (values.count - 1 != level) {
            NSLog(@"WARNING: Incorrect Ngram, line: %@", lines[index]);
            return;
        }
        
        if (index != 0 && index % kMPTCLogStepSize == 0) {
            NSLog(@"Ngrams %@ prepeared %@ of %@", @(level), @(index), @(count));
        }
        
        NSUInteger weight = (NSUInteger)[values[level] integerValue];
        NSArray *words = [values subarrayWithRange:NSMakeRange(0, level)];
        
        NSString *word = words.lastObject;
        NSArray *prepareWords = [words subarrayWithRange:NSMakeRange(0, words.count - 1)];
        
        NSMutableDictionary *ngrams = [self ngramsForLevel:level];
        NSString *ngramsKey = [prepareWords componentsJoinedByString:@"_"];
        NSArray *ngram = ngrams[ngramsKey];
        
        NSMutableArray *newNgram = nil;
        if (!ngram) {
            newNgram = [[NSMutableArray alloc] initWithCapacity:level - 1];
            for (NSString *prepareWord in prepareWords) {
                [newNgram addObject:prepareWord];
            }
            [newNgram addObject:@[@[word, @(weight)]]];
        } else {
            newNgram = [[NSMutableArray alloc] initWithArray:ngram];
            NSMutableArray *lastWords = [[NSMutableArray alloc] initWithArray:ngram.lastObject];
            [lastWords addObject:@[word, @(weight)]];
            [newNgram replaceObjectAtIndex:level - 1 withObject:lastWords];
        }
        ngrams[ngramsKey] = newNgram;
    };
    
    NSLog(@"Ngrams %@ prepeared %@ of %@", @(level), @(count), @(count));
    NSLog(@"Finished prepeared ngrams: %@", fileName);
}

- (NSMutableDictionary *)ngramsForLevel:(NSUInteger)level {
    switch (level) {
        case 2:
            return self.ngrams2;
            
        case 3:
            return self.ngrams3;
            
        default:
            break;
    }
    return nil;
}

- (void)importNgramsForLevel:(NSUInteger)level {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started create ngrams level: %@", @(level));
    
    NSArray *ngrams = [self ngramsForLevel:level].allValues;
    NSUInteger count = ngrams.count;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    UInt8 bytes[UINT8_MAX];
    UInt8 position = 0;
    
    for (NSInteger index = 0; index < count; index ++) {
        if (index != 0 && index % kMPTCLogStepSize == 0) {
            NSLog(@"Ngrams %@ imported %@ of %@", @(level), @(index), @(count));
        }
        
        NSArray *ngram = ngrams[index];
        NSArray *prepareWords = [ngram subarrayWithRange:NSMakeRange(0, level - 1)];
        NSArray *lastWords = ngram.lastObject;
        lastWords = [lastWords sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            return [((NSString *)obj1[0]).lowercaseString compare:((NSString *)obj2[0]).lowercaseString];
        }];
        
        position = 0;
        *((UInt16 *)&bytes[position]) = (UInt16)lastWords.count;
        position += 2;
        [data appendBytes:bytes length:position];
        
        position = 0;
        for (NSString *prepareWord in prepareWords) {
            UInt32 unigramByteIndex = [self dataIndexForUnigram:prepareWord];
            bytes[position ++] = unigramByteIndex >> 0 & 255;
            bytes[position ++] = unigramByteIndex >> 8 & 255;
            bytes[position ++] = unigramByteIndex >> 16 & 255;
        }
        [data appendBytes:bytes length:position];
        
        for (NSArray *lastWord in lastWords) {
            position = 0;
            UInt32 unigramByteIndex = [self dataIndexForUnigram:lastWord[0]];
            bytes[position ++] = unigramByteIndex >> 0 & 255;
            bytes[position ++] = unigramByteIndex >> 8 & 255;
            bytes[position ++] = unigramByteIndex >> 16 & 255;
            
            *((UInt16 *)&bytes[position]) = (UInt16)[lastWord[1] integerValue];
            position += 2;
            [data appendBytes:bytes length:position];
        }
    };
    
    if (level == 3) {
        UInt32 nextNgramByteIndex = (UInt32)data.length + 3;
        position = 0;
        bytes[position ++] = nextNgramByteIndex >> 0 & 255;
        bytes[position ++] = nextNgramByteIndex >> 8 & 255;
        bytes[position ++] = nextNgramByteIndex >> 16 & 255;
        [self.ngramsData appendBytes:bytes length:position];
    }
    
    [self.ngramsData appendData:data];
    
    NSLog(@"Ngrams %@ imported %@ of %@", @(level), @(count), @(count));
    NSLog(@"Finished create ngrams");
}

- (UInt32)dataIndexForUnigram:(NSString *)unigram {
    return (UInt32)[self.unigrams[unigram] integerValue];
}

@end

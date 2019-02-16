//
//  MPTCDataExporter.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 04/12/2018.
//  Copyright © 2018 Maxim Popov popovme@gmail.com. All rights reserved.
//

#import "MPTCDataExporter.h"

#import "MPTCDataUtils.h"
#import "MPTCConfig.h"

@interface MPTCDataExporter ()
    
@end

@implementation MPTCDataExporter
    
- (void)exportDataForFanguage:(nonnull NSString *)language {
    [MPTCDataUtils setLanguage:language];
    
    [self writeTyposToFileWithPrefix:kMPTCSourceTypos];
    [self writeReplacementsToFileWithPrefix:kMPTCSourceReplacements];
    [self writeDefaultsToFileWithPrefix:kMPTCSourceDefaults];
    [self writeUnigramsToFileWithPrefix:kMPTCBaseUnigrams];
    [self writeNgramsToFileWithPrefix:kMPTCBaseNgrams];
}
    
- (void)writeTyposToFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started typos write: %@", prefix);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    // [character code(8)][typos count(8)][typos 1(8)][typos 2(8)]....
    NSData *data = [MPTCDataUtils readDataFromFileWithPrefix:kMPTCTypos];
    UInt8 *bytes = (UInt8 *)[data bytes];
    UInt32 index = 0;
    UInt32 lastIndex = (UInt32)data.length - 1;
    UInt8 characterCode = 0;
    UInt8 typosCount = 0;
    UInt8 i = 0;
    UInt8 typoCode = 0;
    
    while (index < lastIndex) {
        NSMutableArray *line = [[NSMutableArray alloc] init];
        
        characterCode = bytes[index ++];
        typosCount = bytes[index ++];
        
        [line addObject:[NSString stringWithFormat:@"%c", characterCode]];
        
        NSMutableString *typos = [[NSMutableString alloc] init];
        for (i = 0; i < typosCount; i ++) {
            typoCode = bytes[index ++];
            
            [typos appendString:[NSString stringWithFormat:@"%c", typoCode]];
        }
        [line addObject:typos];
        [lines addObject:line];
    }
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:prefix];
    
    NSLog(@"Finished typos write: %@", prefix);
}
    
- (void)writeReplacementsToFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started replacements write: %@", prefix);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    // [unigram length(8)][replacement length(8)][unigram(8 * length)][replacement(8 * length)]
    NSData *data = [MPTCDataUtils readDataFromFileWithPrefix:kMPTCReplacements];
    UInt8 *bytes = (UInt8 *)[data bytes];
    UInt32 index = 0;
    UInt32 lastIndex = (UInt32)data.length - 1;
    UInt8 unigramLength = 0;
    UInt8 replacementLength = 0;
    
    while (index < lastIndex) {
        NSMutableArray *line = [[NSMutableArray alloc] init];
        
        unigramLength = bytes[index ++];
        replacementLength = bytes[index ++];
        
        [line addObject:stringFromBytes(&bytes[index], unigramLength)];
        index += unigramLength;
        
        [line addObject:stringFromBytes(&bytes[index], replacementLength)];
        index += replacementLength;
        
        [lines addObject:line];
    }
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:prefix];
    
    NSLog(@"Finished replacements write: %@", prefix);
}
    
- (void)writeDefaultsToFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started defaults write: %@", prefix);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    // // [length(8)][unigram (8 * length)]
    NSData *data = [MPTCDataUtils readDataFromFileWithPrefix:kMPTCDefaults];
    UInt8 *bytes = (UInt8 *)[data bytes];
    UInt32 index = 0;
    UInt32 lastIndex = (UInt32)data.length - 1;
    UInt8 unigramLength = 0;
    
    while (index < lastIndex) {
        NSMutableArray *line = [[NSMutableArray alloc] init];
        
        unigramLength = bytes[index ++];
        
        [line addObject:stringFromBytes(&bytes[index], unigramLength)];
        index += unigramLength;
        
        [lines addObject:line];
    }
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:prefix];
    
    NSLog(@"Finished defaults write: %@", prefix);
}
    
- (void)writeUnigramsToFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSLog(@"Started unigrams write: %@", prefix);
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    // [unigram lenght(8)][?(is uppercase)(8)][unigram characters(8 * length)][uppercase characters(8 * length)][weight(16)]
    // [unigram length(8)][unigram characters(8 * length)][weight(16)]
    NSData *data = [MPTCDataUtils readDataFromFileWithPrefix:kMPTCUnigrams];
    UInt8 *bytes = (UInt8 *)[data bytes];
    UInt32 index = 1;
    UInt32 lastIndex = (UInt32)data.length - 1;
    UInt8 unigramLength = 0;
    
    while (index < lastIndex) {
        NSMutableArray *line = [[NSMutableArray alloc] init];
        
        unigramLength = bytes[index ++];
        
        if (bytes[index] == '?') {
            index += (unigramLength + 1);
        }
        
        [line addObject:stringFromBytes(&bytes[index], unigramLength)];
        index += unigramLength;
        
        [line addObject:[NSString stringWithFormat:@"%i", int16FromBytes(bytes, index)]];
        index += 2;
        
        [lines addObject:line];
    }
    
    // Sort by weight
    [lines sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        NSNumber *value1 = @([(NSString *)obj1[1] integerValue]);
        NSNumber *value2 = @([(NSString *)obj2[1] integerValue]);
        return [value2 compare:value1];
    }];
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:prefix];
    
    NSLog(@"Finished unigrams write: %@", prefix);
}

- (void)writeNgramsToFileWithPrefix:(NSString *)prefix {
    [MPTCDataUtils logSplitter];
    
    NSString *ngrams3Prefix = [NSString stringWithFormat:@"%@_3", prefix];
    NSLog(@"Started ngrams3 write: %@", ngrams3Prefix);
    
    NSMutableArray *ngram3Lines = [[NSMutableArray alloc] init];
    
    // [unigram lenght(8)][?(is uppercase)(8)][unigram characters(8 * length)][uppercase characters(8 * length)][weight(16)]
    // [unigram length(8)][unigram characters(8 * length)][weight(16)]
    NSData *unigramsData = [MPTCDataUtils readDataFromFileWithPrefix:kMPTCUnigrams];
    UInt8 *unigramsBytes = (UInt8 *)[unigramsData bytes];
    
    // [ngram2Index(24)]
    // [ngram3word3 count(16)][ngram3word1 unigram index(24)][ngram3word2 unigram index(24)][unigram index(24)][weight(16)][unigram index(24)][weight(16)]...
    // [ngram2word3 count(16)][ngram2word2 unigram index(24)][unigram index(24)][weight(16)][unigram index(24)][weight(16)]...
    NSData *ngramsData = [MPTCDataUtils readDataFromFileWithPrefix:kMPTCNgrams];
    UInt8 *ngramsBytes = (UInt8 *)[ngramsData bytes];
    UInt32 ngrams2Index = int24FromBytes(ngramsBytes, 0);
    UInt32 ngramsLastIndex = (UInt32)ngramsData.length - 1;
    
    UInt32 index = 3;
    UInt32 lastIndex = 0;
    
    // Ngrams 3
    while (index < ngrams2Index) {
        UInt16 ngramsCount = int16FromBytes(ngramsBytes, index);
        index += 2;
        
        NSString *word1 = stringFromUnigramBytes(unigramsBytes, int24FromBytes(ngramsBytes, index));
        index += 3;
        
        NSString *word2 = stringFromUnigramBytes(unigramsBytes, int24FromBytes(ngramsBytes, index));
        index += 3;
        
        lastIndex = index + 5 * ngramsCount;
        
        while (index < lastIndex) {
            NSString *word = stringFromUnigramBytes(unigramsBytes, int24FromBytes(ngramsBytes, index));
            index += 3;
            
            NSString *weight = [NSString stringWithFormat:@"%i", int16FromBytes(ngramsBytes, index)];
            index += 2;
            
            [ngram3Lines addObject:@[word1, word2, word, weight]];
        }
    }
    
    // Sort by weight
    [ngram3Lines sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        NSNumber *value1 = @([(NSString *)obj1[3] integerValue]);
        NSNumber *value2 = @([(NSString *)obj2[3] integerValue]);
        return [value2 compare:value1];
    }];
    
    [MPTCDataUtils writeArray:ngram3Lines toFileWithPrefix:ngrams3Prefix];
    
    NSLog(@"Finished ngrams3 write: %@", ngrams3Prefix);
    
    NSString *ngrams2Prefix = [NSString stringWithFormat:@"%@_2", prefix];
    NSLog(@"Started ngrams2 write: %@", ngrams2Prefix);
    
    NSMutableArray *ngram2Lines = [[NSMutableArray alloc] init];
    
    index = ngrams2Index;
    
    // Ngrams 2
    while (index < ngramsLastIndex) {
        UInt16 ngramsCount = int16FromBytes(ngramsBytes, index);
        index += 2;
        
        NSString *word1 = stringFromUnigramBytes(unigramsBytes, int24FromBytes(ngramsBytes, index));
        index += 3;
        
        lastIndex = index + 5 * ngramsCount;
        
        while (index < lastIndex) {
            NSString *word = stringFromUnigramBytes(unigramsBytes, int24FromBytes(ngramsBytes, index));
            index += 3;
            
            NSString *weight = [NSString stringWithFormat:@"%i", int16FromBytes(ngramsBytes, index)];
            index += 2;
            
            [ngram2Lines addObject:@[word1, word, weight]];
        }
    }
    
    // Sort by weight
    [ngram2Lines sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        NSNumber *value1 = @([(NSString *)obj1[2] integerValue]);
        NSNumber *value2 = @([(NSString *)obj2[2] integerValue]);
        return [value2 compare:value1];
    }];
    
    
    [MPTCDataUtils writeArray:ngram2Lines toFileWithPrefix:ngrams2Prefix];
    
    NSLog(@"Finished ngrams2 write: %@", ngrams2Prefix);
}


#pragma mark - Inline

NS_INLINE UInt32 int24FromBytes(UInt8 *bytes, UInt32 index) {
    return bytes[index] | *(UInt16 *)&bytes[index + 1] << 8;
}

NS_INLINE UInt16 int16FromBytes(UInt8 *bytes, UInt32 index) {
    return *(UInt16 *)&bytes[index];
}

NS_INLINE NSString *stringFromBytes(UInt8 *bytes, UInt32 length) {
    return [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
}

NS_INLINE NSString *stringFromUnigramBytes(UInt8 *bytes, UInt32 index) {
    UInt8 length = bytes[index ++];
    
    if (bytes[index] == '?') {
        index += (length + 1);
    }
    
    return stringFromBytes(&bytes[index], length);
}

@end

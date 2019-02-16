//
//  MPTCDataConverter.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 04/12/2018.
//  Copyright © 2018 Maxim Popov popovme@gmail.com. All rights reserved.
//

#import "MPTCDataConverter.h"

#import "MPTCDataUtils.h"
#import "MPTCConfig.h"

@implementation MPTCDataConverter
    
- (void)convertDataForFanguage:(nonnull NSString *)language {
    [MPTCDataUtils setLanguage:language];
    
    [self convertScowlFrequencyWithPrefix:kMPTCServiceScowlFrequency toToFileWithPrefix:kMPTCBaseScowlFrequency];
    [self convertScowlWithPrefix:kMPTCServiceScowl toToFileWithPrefix:kMPTCBaseScowl];
    [self convertYclistWithPrefix:kMPTCServiceYclist toToFileWithPrefix:kMPTCBaseYclist];
}
    
- (void)convertScowlFrequencyWithPrefix:(NSString *)prefix toToFileWithPrefix:(NSString *)filePrefix {
    NSCharacterSet *correctCharacters = [MPTCDataUtils correctCharacters];
    NSCharacterSet *numbersCharacter = [MPTCDataUtils numbersCharacters];
    NSCharacterSet *whitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [MPTCDataUtils readLinesWithPrefix:prefix block:^(NSString *line, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (![correctCharacters characterIsMember:[line characterAtIndex:0]]) {
            (*errors) ++;
            return;
        }
        
        // Word last index
        NSRange range = [line rangeOfCharacterFromSet:whitespaceCharacters];
        if (range.location == NSNotFound || range.location == 0) {
            (*critical) = YES;
            return;
        }
        NSString *word = [line substringToIndex:range.location];
        line = [line substringFromIndex:range.location];
        
        // Frequency first index
        range = [line rangeOfCharacterFromSet:numbersCharacter];
        if (range.location == NSNotFound || range.location == 0) {
            (*critical) = YES;
            return;
        }
        line = [line substringFromIndex:range.location];
        
        // Frequency last index
        range = [line rangeOfCharacterFromSet:whitespaceCharacters];
        if (range.location == NSNotFound || range.location == 0) {
            (*critical) = YES;
            return;
        }
        Float32 frequency = [[[line substringToIndex:range.location] stringByReplacingOccurrencesOfString:@"," withString:@""] floatValue];
        
        [lines addObject:@[word, [NSString stringWithFormat:@"%.0f", frequency * 10000]]];
    }];
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:filePrefix];
}

- (void)convertScowlWithPrefix:(NSString *)prefix toToFileWithPrefix:(NSString *)filePrefix {
    NSCharacterSet *correctCharacters = [MPTCDataUtils correctCharacters];
    NSCharacterSet *incorrectCharacters = [correctCharacters invertedSet];
    NSString *lastWordString1 = @"/";
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [MPTCDataUtils readLinesWithPrefix:prefix block:^(NSString *line, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (![correctCharacters characterIsMember:[line characterAtIndex:0]]) {
            (*errors) ++;
            return;
        }
        
        // Word last index
        NSRange range = [line rangeOfString:lastWordString1];
        if (range.location == NSNotFound || range.location == 0) {
            range = [line rangeOfCharacterFromSet:incorrectCharacters];
            if (range.location == NSNotFound) {
                range.location = line.length;
            } else {
                (*critical) = YES;
                return;
            }
        }
        
        [lines addObject:[line substringToIndex:range.location]];
    }];
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:filePrefix];
}

- (void)convertYclistWithPrefix:(NSString *)prefix toToFileWithPrefix:(NSString *)filePrefix {
    NSCharacterSet *correctCharacters = [MPTCDataUtils correctCharacters];
    NSCharacterSet *whitespaceCharacters = [NSCharacterSet whitespaceCharacterSet];
    NSString *lastWordString1 = @"\t";
    NSString *lastWordString2 = @"http";
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    [MPTCDataUtils readLinesWithPrefix:prefix block:^(NSString *line, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (![correctCharacters characterIsMember:[line characterAtIndex:0]]) {
            (*errors) ++;
            return;
        }
        
        // Word last index
        NSRange range = [line rangeOfString:lastWordString1];
        if (range.location == NSNotFound || range.location == 0) {
            range = [line rangeOfString:lastWordString2];
            if (range.location == NSNotFound || range.location == 0) {
                (*critical) = YES;
                return;
            }
        }
        NSString *word = [[line substringToIndex:range.location] stringByTrimmingCharactersInSet:whitespaceCharacters];
        
        [lines addObject:word];
    }];
    
    [MPTCDataUtils writeArray:lines toFileWithPrefix:filePrefix];
}

@end

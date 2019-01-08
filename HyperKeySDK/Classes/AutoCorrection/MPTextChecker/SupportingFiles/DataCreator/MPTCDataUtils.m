//
//  MPTCDataUtils.m
//  ACFastMemory
//
//  Created by Maxim Popov popovme@gmail.com on 20.05.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCDataUtils.h"

NSString *const kMPTCDataUtilsNgram2Prefix = @"mptc_ngrams_2";
NSString *const kMPTCDataUtilsNgram3Prefix = @"mptc_ngrams_3";

NSUInteger const kMPTCDataUtilsNgramsLevels = 3;
NSUInteger const kMPTCDataUtilsLogStepSize = 50000;

BOOL const kMPTCDataUtilsImportToDesktop = YES;
NSString *const kMPTCDataUtilsSeparatorString = @"|";

static NSString *_language = @"en_US";

@implementation MPTCDataUtils

+ (void)setLanguage:(NSString *)language {
    if (language) {
        _language = language;
    }
}

+ (NSString *)language {
    return _language;
}

+ (void)logSplitter {
    NSLog(@"=========================================");
}

+ (void)readFileWithPrefix:(NSString *)prefix usingBlock:(void (^)(NSArray *values, NSUInteger index, NSUInteger *errorsCount))block {
    [[self class] logSplitter];
    
    NSLog(@"Started \"%@\"", prefix);
    
    NSArray *lines = [[self class] readLinesFromFileWithPrefix:prefix];
    NSUInteger linesCount = lines.count;
    
    NSUInteger emptiesCount = 0;
    NSUInteger errorsCount = 0;
    NSUInteger previousErrorsCount = 0;
    
    for (NSUInteger index = 0; index < linesCount; index ++) {
        NSArray *values = [[self class] valuesFromLine:lines[index]];
        NSUInteger valuesCount = values.count;
        
        if (values.count == 0) {
            emptiesCount ++;
            continue;
        }
        NSUInteger i = 0;
        for (; i < valuesCount; i ++) {
            if (((NSString *)values[i]).length == 0) {
                break;
            }
        }
        if (i < valuesCount) {
            emptiesCount ++;
            continue;
        }
        
        previousErrorsCount = errorsCount;
        if (block) {
            block(values, index, &errorsCount);
        }
        
        if (index != 0 && index % kMPTCDataUtilsLogStepSize == 0) {
            NSLog(@"Line completed: %@ of %@", @(index), @(linesCount));
        }
        if (errorsCount != previousErrorsCount) {
            NSLog(@"ERROR: Incorrect line: %@", lines[index]);
        }
    };
    
    NSLog(@"Line completed: %@ of %@", @(linesCount), @(linesCount));
    NSLog(@"Finished \"%@\", successes: %@, errors: %@, empties: %@", prefix, @(linesCount - errorsCount - emptiesCount), @(errorsCount), @(emptiesCount));
}

+ (NSArray *)readLinesFromFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, self.language];
    NSString *filePath = [[NSBundle bundleForClass:NSClassFromString(@"HKKeyboardViewController")] pathForResource:fileName ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    fileContents = [fileContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (void)writeData:(NSData *)data toFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, self.language];
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    [data writeToFile:filePath atomically:YES];
}

+ (void)writeArray:(NSArray *)array toFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.txt", prefix, self.language];
    NSString *filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:fileName];
    
    NSMutableString *lines = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < array.count; i ++) {
        if (i != 0) {
            [lines appendString:@"\n"];
        }
        id object = array[i];
        if ([object isKindOfClass:[NSArray class]]) {
            [lines appendString:[object componentsJoinedByString:kMPTCDataUtilsSeparatorString]];
        } else {
            [lines appendString:object];
        }
    }
    [lines writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSArray *)valuesFromLine:(NSString *)line {
    NSString *trimLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [trimLine componentsSeparatedByString:kMPTCDataUtilsSeparatorString];
}

+ (NSString *)applicationDocumentsDirectory {
    if (kMPTCDataUtilsImportToDesktop) {
        return @"/Users/iMakc/Desktop";
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

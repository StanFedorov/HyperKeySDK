//
//  MPTCDataUtils.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 20.05.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCDataUtils.h"

#import "MPTCConfig.h"

static NSString *_language = @"en_US";

static NSCharacterSet *_albhabetCharacters;
static NSCharacterSet *_numbersCharacters;
static NSCharacterSet *_symbolCharacters;
static NSCharacterSet *_correctCharacters;
static NSCharacterSet *_oneCorrectCharacters;
static NSCharacterSet *_trimCharacters;
static NSUInteger _maxCharacters = 0;

@implementation MPTCDataUtils
    
+ (void)logSplitter {
    NSLog(@"=========================================");
}
    
+ (NSCharacterSet *)albhabetCharacters {
    return _albhabetCharacters;
}
    
+ (NSCharacterSet *)numbersCharacters {
    return _numbersCharacters;
}

+ (NSCharacterSet *)symbolCharacters {
    return _symbolCharacters;
}
    
+ (NSCharacterSet *)correctCharacters {
    return _correctCharacters;
}
    
+ (NSCharacterSet *)oneCorrectCharacters {
    return _oneCorrectCharacters;
}

+ (NSCharacterSet *)trimCharacters {
    return _trimCharacters;
}
    
+ (NSUInteger)maxCharacters {
    return _maxCharacters;
}
    
+ (NSString *)language {
    return _language;
}
    
+ (void)setLanguage:(NSString *)language {
    _language = language;
    
    [self readSettings];
}
    
+ (void)readValuesWithPrefix:(NSString *)prefix block:(void (^)(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical))block {
    [[self class] logSplitter];
    
    NSLog(@"Started \"%@\"", prefix);
    
    NSArray *lines = [[self class] readLinesFromFileWithPrefix:prefix];
    NSUInteger linesCount = lines.count;
    
    NSUInteger emptiesCount = 0;
    NSUInteger errorsCount = 0;
    
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
        
        BOOL critical = NO;
        if (block) {
            block(values, index, &errorsCount, &critical);
        }
        
        if (index != 0 && index % kMPTCLogStepSize == 0) {
            NSLog(@"Line completed: %@ of %@", @(index), @(linesCount));
        }
        if (critical) {
            errorsCount ++;
            
            NSLog(@"Critical error for index: %@, line: %@", @(index), lines[index]);
        }
    };
    
    NSLog(@"Line completed: %@ of %@", @(linesCount), @(linesCount));
    NSLog(@"Finished \"%@\", successes: %@, errors: %@, empties: %@", prefix, @(linesCount - errorsCount - emptiesCount), @(errorsCount), @(emptiesCount));
}
    
+ (void)readLinesWithPrefix:(NSString *)prefix block:(void (^)(NSString *line, NSUInteger index, NSUInteger *errors, BOOL *critical))block {
    [[self class] logSplitter];
    
    NSLog(@"Started \"%@\"", prefix);
    
    NSArray *lines = [[self class] readLinesFromFileWithPrefix:prefix];
    NSUInteger linesCount = lines.count;
    
    NSUInteger emptiesCount = 0;
    NSUInteger errorsCount = 0;
    
    for (NSUInteger index = 0; index < linesCount; index ++) {
        NSString *line = lines[index];
        
        if (line.length == 0) {
            emptiesCount ++;
            continue;
        }
        
        BOOL critical = NO;
        if (block) {
            block(line, index, &errorsCount, &critical);
        }
        
        if (index != 0 && index % kMPTCLogStepSize == 0) {
            NSLog(@"Line completed: %@ of %@", @(index), @(linesCount));
        }
        if (critical) {
            errorsCount ++;
            
            NSLog(@"Critical error for index: %@, line: %@", @(index), line);
        }
    };
    
    NSLog(@"Line completed: %@ of %@", @(linesCount), @(linesCount));
    NSLog(@"Finished \"%@\", successes: %@, errors: %@, empties: %@", prefix, @(linesCount - errorsCount - emptiesCount), @(errorsCount), @(emptiesCount));
}

+ (NSArray *)readLinesFromFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, self.language];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    fileContents = [fileContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}
    
+ (NSData *)readDataFromFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, self.language];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@""];
    return [NSData dataWithContentsOfFile:filePath];
}

+ (void)writeData:(NSData *)data toFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", prefix, self.language];
    NSString *filePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    [data writeToFile:filePath atomically:YES];
}

+ (void)writeArray:(NSArray *)array toFileWithPrefix:(NSString *)prefix {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.txt", prefix, self.language];
    NSString *filePath = [[self documentsDirectory] stringByAppendingPathComponent:fileName];
    
    NSMutableString *lines = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < array.count; i ++) {
        if (i != 0) {
            [lines appendString:@"\n"];
        }
        id object = array[i];
        if ([object isKindOfClass:[NSArray class]]) {
            [lines appendString:[object componentsJoinedByString:kMPTCSeparatorString]];
        } else {
            [lines appendString:object];
        }
    }
    
    NSError *error = nil;
    [lines writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error write %@: %@", prefix, [error localizedDescription]);
    }
}

+ (NSArray *)valuesFromLine:(NSString *)line {
    NSString *trimLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [trimLine componentsSeparatedByString:kMPTCSeparatorString];
}

+ (NSString *)documentsDirectory {
    if (kMPTCImportToDesktop) {
        return @"/Users/iMakc/Desktop";
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
    
#pragma mark - Private
    
+ (void)readSettings {
    [MPTCDataUtils readValuesWithPrefix:kMPTCSettings block:^(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical) {
        if (values.count != 2) {
            (*critical) = YES;
            return;
        }
        
        switch (index) {
            case 0:
            _albhabetCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
            break;
            
            case 1:
            _numbersCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
            break;
                
            case 2:
            _symbolCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
            break;
            
            case 3:
            _oneCorrectCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
            break;
                
            case 4:
            _trimCharacters = [NSCharacterSet characterSetWithCharactersInString:values[1]];
            break;
            
            case 5:
            _maxCharacters = [values[1] integerValue];
            
            default:
            break;
        }
    }];
    
    NSMutableCharacterSet *correctCharacters = [[NSMutableCharacterSet alloc] init];
    [correctCharacters formUnionWithCharacterSet:_albhabetCharacters];
    [correctCharacters formUnionWithCharacterSet:_numbersCharacters];
    [correctCharacters formUnionWithCharacterSet:_symbolCharacters];
    _correctCharacters = correctCharacters;
}

@end

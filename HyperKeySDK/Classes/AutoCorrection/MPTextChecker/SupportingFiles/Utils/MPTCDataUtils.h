//
//  MPTCDataUtils.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 20.05.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MPTCDataUtils : NSObject

+ (void)logSplitter;

+ (NSCharacterSet *)albhabetCharacters;
+ (NSCharacterSet *)numbersCharacters;
+ (NSCharacterSet *)symbolCharacters;
+ (NSCharacterSet *)correctCharacters;
+ (NSCharacterSet *)oneCorrectCharacters;
+ (NSCharacterSet *)trimCharacters;
+ (NSUInteger)maxCharacters;
    
+ (NSString *)language;
+ (void)setLanguage:(nonnull NSString *)language;

+ (void)readValuesWithPrefix:(NSString *)prefix block:(void (^)(NSArray *values, NSUInteger index, NSUInteger *errors, BOOL *critical))block;
+ (void)readLinesWithPrefix:(NSString *)prefix block:(void (^)(NSString *line, NSUInteger index, NSUInteger *errors, BOOL *critical))block;

+ (NSArray *)readLinesFromFileWithPrefix:(NSString *)prefix;
+ (NSData *)readDataFromFileWithPrefix:(NSString *)prefix;
+ (void)writeData:(NSData *)data toFileWithPrefix:(NSString *)prefix;
+ (void)writeArray:(NSArray *)array toFileWithPrefix:(NSString *)prefix;
+ (NSArray *)valuesFromLine:(NSString *)line;
+ (NSString *)documentsDirectory;

@end

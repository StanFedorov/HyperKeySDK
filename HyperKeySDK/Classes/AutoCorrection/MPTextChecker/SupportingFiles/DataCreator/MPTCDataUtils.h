//
//  MPTCDataUtils.h
//  ACFastMemory
//
//  Created by Maxim Popov popovme@gmail.com on 20.05.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kMPTCDataUtilsNgram2Prefix;
extern NSString *const kMPTCDataUtilsNgram3Prefix;

extern NSUInteger const kMPTCDataUtilsNgramsLevels;
extern NSUInteger const kMPTCDataUtilsLogStepSize;

@interface MPTCDataUtils : NSObject

+ (void)setLanguage:(NSString *)language;
+ (NSString *)language;

+ (void)logSplitter;

+ (void)readFileWithPrefix:(NSString *)prefix usingBlock:(void (^)(NSArray *values, NSUInteger index, NSUInteger *errorsCount))block;
+ (NSArray *)readLinesFromFileWithPrefix:(NSString *)prefix;
+ (void)writeData:(NSData *)data toFileWithPrefix:(NSString *)prefix;
+ (void)writeArray:(NSArray *)array toFileWithPrefix:(NSString *)prefix;
+ (NSArray *)valuesFromLine:(NSString *)line;
+ (NSString *)applicationDocumentsDirectory;

@end

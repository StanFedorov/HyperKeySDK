//
//  MPTextChecker.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 27.01.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPTCString.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPTextChecker : NSObject

@property (assign, nonatomic) NSUInteger defaultResultCount; // Default: 3
@property (assign, nonatomic) BOOL isAutoCapitalize;         // Default: NO
@property (assign, nonatomic) BOOL isFullAccess;             // Default: YES

- (void)initializeLanguage:(NSString *)language dataCreation:(BOOL)dataCreation completion:(void (^__nullable)(void))completion;
- (void)createCurrentLanguageDataWithCompletion:(void (^__nullable)(void))completion;
- (void)clearCurrentLanguageDataWithCompletion:(void (^__nullable)(void))completion;

- (nullable NSString *)lastWordForString:(NSString *)string;

- (BOOL)isAlreadyCorrectedWord:(NSString *)word inRange:(NSRange)range;
- (void)addCorretedWord:(NSString *)word inRange:(NSRange)range;

// Guesses And Predictions
- (nullable NSArray *)defaultsForString:(NSString *)string;
- (nullable MPTCString *)replacementForWord:(NSString *)word;

- (nullable NSArray *)correctionsForString:(NSString *)string original:(MPTCString * __nullable __autoreleasing * __nullable)original;
- (nullable NSArray *)correctionsForString:(NSString *)string original:(MPTCString * __nullable __autoreleasing * __nullable)original resultCount:(NSUInteger)count;

// Method not used, this is alpha version of base separations
- (nullable NSArray *)separationsForString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END

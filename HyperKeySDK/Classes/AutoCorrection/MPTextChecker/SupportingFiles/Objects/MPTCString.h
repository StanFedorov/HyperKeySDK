//
//  MPTCString.h
//  WordPrediction
//
//  Created by Maxim Popov popovme@gmail.com on 27.01.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(UInt16, MPTCStringType) {
    MPTCStringTypeReplacement = 400,
    MPTCStringTypeCorrection = 300,
    MPTCStringTypePrediction3ngram = 200,
    MPTCStringTypePrediction2ngram = 100,
    MPTCStringTypeSeparators = 4,
    MPTCStringTypeCompletion = 3,
    MPTCStringTypeGuesses = 2,
    MPTCStringTypeDefaults = 1,
    MPTCStringTypeNone = 0,
};

@interface MPTCString : NSObject

@property (strong, nonatomic) NSString *string;
@property (assign, nonatomic) UInt16 weight;
@property (assign, nonatomic) UInt16 predictionWeight;
@property (assign, nonatomic) Float32 sortWeight;
@property (assign, nonatomic) UInt8 errorsCount;
@property (assign, nonatomic) UInt8 lowErrorsCount;
@property (assign, nonatomic) UInt8 highErrorsCount;
@property (assign, nonatomic) UInt8 lengthErrorsCount;
@property (assign, nonatomic) MPTCStringType type;

@property (assign, nonatomic) UInt32 dataIndex;

+ (instancetype)stringWithString:(NSString *)string weight:(UInt16)weight type:(MPTCStringType)type;

- (instancetype)initWithString:(NSString *)string weight:(UInt16)weight type:(MPTCStringType)type;
- (void)calculateSortWeight;

@end

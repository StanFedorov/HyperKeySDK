//
//  MPTCString.m
//  WordPrediction
//
//  Created by Maxim Popov popovme@gmail.com on 27.01.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCString.h"

@interface MPTCString () <NSCopying>

@end

@implementation MPTCString

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ %@ %@: %@: %@ %@ %.2f: %@", @(self.errorsCount), @(self.highErrorsCount), @(self.lowErrorsCount), @(self.lengthErrorsCount), self.string, @(self.weight), @(self.predictionWeight), self.sortWeight, @(self.type)];
}


#pragma mark - Class

+ (instancetype)stringWithString:(NSString *)string weight:(UInt16)weight type:(MPTCStringType)type {
    return [[self alloc] initWithString:string weight:weight type:type];
}


#pragma mark - Public

- (instancetype)initWithString:(NSString *)string weight:(UInt16)weight type:(MPTCStringType)type {
    self = [super init];
    if (self) {
        self.string = string;
        self.weight = weight;
        self.type = type;
    }
    return self;
}

- (void)calculateSortWeight {
    Float32 factor = 2.1;
    switch (self.type) {
        case MPTCStringTypePrediction3ngram:
            factor = 100;
            break;
            
        case MPTCStringTypePrediction2ngram:
            factor = 11;
            break;
            
        case MPTCStringTypeSeparators:
            factor = 0.1;
            break;
            
        default:
            break;
    }
    Float32 lowErrorsFactor = 10;
    Float32 highErrorsFactor = 18;
    Float32 errorsFactor = 2.8;
    Float32 lengthFactor = 9;
    Float32 weight = (self.predictionWeight + self.weight / 100.0f);
    Float32 divider = self.errorsCount == 0 ? 1 : pow(lowErrorsFactor, self.lowErrorsCount) * pow(highErrorsFactor, self.highErrorsCount) * pow(errorsFactor, MAX(self.errorsCount - 1, 0)) * pow(lengthFactor, self.lengthErrorsCount);
    
    self.sortWeight = weight / divider * factor * 10.0f;
}


#pragma mark - Equal

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    MPTCString *equalObject = object;
    if (![self.string isEqualToString:equalObject.string]) {
        return NO;
    }
    
    return YES;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MPTCString *mptcString = [[[self class] allocWithZone:zone] init];
    if (mptcString) {
        mptcString.string = [self.string copyWithZone:zone];
        mptcString.weight = self.weight;
        mptcString.predictionWeight = self.predictionWeight;
        mptcString.errorsCount = self.errorsCount;
        mptcString.sortWeight = self.sortWeight;
        mptcString.lowErrorsCount = self.lowErrorsCount;
        mptcString.highErrorsCount = self.highErrorsCount;
        mptcString.lengthErrorsCount = self.lengthErrorsCount;
        mptcString.type = self.type;
    }
    return mptcString;
}

@end

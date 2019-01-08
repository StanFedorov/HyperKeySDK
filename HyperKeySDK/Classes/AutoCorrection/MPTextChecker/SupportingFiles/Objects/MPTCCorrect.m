//
//  MPTCCorrect.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 24.02.16.
//
//

#import "MPTCCorrect.h"

@implementation MPTCCorrect

#pragma mark - Class

+ (instancetype)correctWithString:(NSString *)string range:(NSRange)range {
    return [[[self class] alloc] initWithString:string range:range];
}


#pragma mark - Public

- (instancetype)initWithString:(NSString *)string range:(NSRange)range {
    self = [super init];
    if (self) {
        self.string = string;
        self.range = range;
    }
    return self;
}


#pragma mark - Equal

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    MPTCCorrect *equalObject = object;
    if (![self.string isEqualToString:equalObject.string]) {
        return NO;
    }
    
    if (NSIntersectionRange(self.range, equalObject.range).length == 0) {
        return NO;
    }
    
    return YES;
}

@end

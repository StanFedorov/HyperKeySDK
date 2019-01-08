//
//  ACSpaceOperation.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 25.02.16.
//
//

#import "ACSpaceOperation.h"

@implementation ACSpaceOperation

#pragma mark - Public

- (instancetype)initWithText:(NSString *)text original:(NSString *)original correction:(NSString *)correction {
    self = [super init];
    if (self) {
        self.text = text;
        self.original = original;
        self.correction = correction;
    }
    return self;
}


#pragma mark - Main

- (void)main {
    [self willCompletion];
}

#pragma mark - Private

- (void)willCompletion {
    if (self.willCompletionBlock) {
        self.willCompletionBlock(self.text, self.original, self.correction);
    }
}

@end

//
//  MInsertData.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 27.09.16.
//
//

#import "MInsertData.h"

@implementation MInsertData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = nil;
        self.urlString = nil;
        self.branchChannel = nil;
        self.branchFeature = @"sharing";
        
        self.useDescription = YES;
    }
    return self;
}

@end

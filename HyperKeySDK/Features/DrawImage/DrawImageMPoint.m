//
//  DrawImageMPoint.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 26.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageMPoint.h"

@implementation DrawImageMPoint

#pragma mark - Public

- (instancetype)initWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width {
    self = [super init];
    if (self) {
        self.x = x;
        self.y = y;
        self.width = width;
    }
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    DrawImageMPoint *point = [[[self class] allocWithZone:zone] init];
    
    point.x = self.x;
    point.y = self.y;
    point.width = self.width;
    
    return point;
}

@end

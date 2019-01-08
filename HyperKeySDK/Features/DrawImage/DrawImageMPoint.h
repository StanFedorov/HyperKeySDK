//
//  DrawImageMPoint.h
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 26.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawImageMPoint : NSObject

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;

- (instancetype)initWithX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width;

@end

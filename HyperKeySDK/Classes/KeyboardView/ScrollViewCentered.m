//
//  ScrollViewCentered.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 05.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "ScrollViewCentered.h"

@implementation ScrollViewCentered

- (void)resize
{
    UIView *subView = [self.subviews objectAtIndex:0];
    
    CGFloat offsetX = MAX((self.bounds.size.width - self.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((self.bounds.size.height - self.contentSize.height) * 0.5, 0.0);
    
    subView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX,
                                 self.contentSize.height * 0.5 + offsetY);
}

@end

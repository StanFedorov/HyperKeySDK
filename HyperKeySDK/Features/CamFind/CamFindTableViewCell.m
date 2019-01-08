//
//  CamFindTableViewCell.m
//  BetterWordKeyboard
//
//  Created by Stanislav Fedorov on 07.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "CamFindTableViewCell.h"

@implementation CamFindTableViewCell
@synthesize imageOverlay;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageOverlay.layer.borderColor = [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f].CGColor;
    self.imageOverlay.layer.borderWidth = 2.0f;
}

@end

//
//  TopAppImage.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 05.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "TopAppImage.h"
#import "UIImage+Pod.h"

@implementation TopAppImage

- (void)setKeyboardFeature:(KeyboardFeature *)feature {
    self.feature = feature;
    [self setBackgroundImage:[UIImage imageNamedPod:feature.imageNameOrUrl] forState:UIControlStateNormal];
}

- (void)updateIconToDefault {
    [self setBackgroundImage:[UIImage imageNamedPod:self.feature.imageNameOrUrl] forState:UIControlStateNormal];
}

- (void)updateIconToSelected {
    UIImage *img = [UIImage imageNamedPod:[NSString stringWithFormat:@"%@_selected",self.feature.imageNameOrUrl]];
    if(img != nil)
        [self setBackgroundImage:img forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

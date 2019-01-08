//
//  UIColor+DrawImage.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 23.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "UIColor+DrawImage.h"

#import "Macroses.h"

@implementation UIColor (DrawImage)

#pragma mark - Text

+ (UIColor *)drawImageTextGrayColor {
    return RGB(100, 92, 107);
}

+ (UIColor *)drawImageTextGrayDarkColor {
    return RGB(60, 52, 67);
}


#pragma mark - Backgrounds

+ (UIColor *)drawImageBgGrayDarkColor {
    return RGB(126, 124, 132);
}

+ (UIColor *)drawImageBgGrayLightColor {
    return RGB(238, 238, 238);
}

+ (UIColor *)drawImageBgLightColor {
    return RGB(255, 255, 255);
}


+ (UIColor *)drawImageBgIndicatorBorderColor {
    return RGBA(238, 238, 238, 0.8);
}

@end

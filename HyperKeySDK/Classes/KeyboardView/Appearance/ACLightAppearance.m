//
//  ACLightAppearance.m
//  ACKeyboard
//
//  Created by Arnaud Coomans on 10/13/14.
//
//

#import "ACLightAppearance.h"

#import "UIDevice+Hardware.h"
#import "Macroses.h"

@implementation ACLightAppearance

+ (UIColor *)lightKeyColor {
    static UIColor *_lightKeyColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPad3,"]) {
            _lightKeyColor = [UIColor colorWithWhite:254 / 255.0 alpha:1.0];
        } else {
            _lightKeyColor = [UIColor whiteColor];
        }
    });
    return _lightKeyColor;
}

+ (UIColor *)lightKeyShadowColor {
    static UIColor *_lightKeyShadowColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPad3,"]) {
            _lightKeyShadowColor = RGB(142, 145, 149);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone7,2"]) {
            _lightKeyShadowColor = RGB(139, 142, 146);
        } else {
            _lightKeyShadowColor = RGB(136, 138, 142);
        }
    });
    return _lightKeyShadowColor;
}

+ (UIColor *)darkKeyColor {
    static UIColor *_darkKeyColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPad3,"]) {
            _darkKeyColor = RGB(184, 191, 202);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone5,"]) {
            _darkKeyColor = RGB(174, 179, 190);
        } else {
            _darkKeyColor = RGB(172, 179, 190);
        }
    });
    return _darkKeyColor;
}

+ (UIColor *)darkKeyShadowColor {
    return [self lightKeyShadowColor];
}

+ (UIColor *)darkKeyDisabledTitleColor {
    static UIColor *_darkKeyDisabledTitleColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone5,"]) {
            _darkKeyDisabledTitleColor = RGB(118, 121, 129);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone6,"] || [[[UIDevice currentDevice] machine] hasPrefix:@"iPad4,"]) {
            _darkKeyDisabledTitleColor = RGB(116, 121, 129);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone7,2"]) {
            _darkKeyDisabledTitleColor = RGB(116, 121, 127);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone7,1"]) {
            _darkKeyDisabledTitleColor = RGB(118, 123, 130);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPad3,"]) {
            _darkKeyDisabledTitleColor = RGB(125, 129, 137);
        }
    });
    return _darkKeyDisabledTitleColor;
}

+ (UIColor *)blueKeyColor {
    static UIColor *_blueKeyColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPad3,"]) {
            _blueKeyColor = RGB(9, 126, 254);
        } else {
            _blueKeyColor = RGB(0, 122, 255);
        }
    });
    return _blueKeyColor;
}

+ (UIColor *)blueKeyShadowColor {
    static UIColor *_blueKeyShadowColor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone5,"]) {
            _blueKeyShadowColor = RGB(105, 106, 109);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPhone7,2"]) {
            _blueKeyShadowColor = RGB(103, 105, 108);
        } else if ([[[UIDevice currentDevice] machine] hasPrefix:@"iPad3,"]) {
            _blueKeyShadowColor = RGB(107, 109, 112);
        } else {
            _blueKeyShadowColor = RGB(104, 106, 109);
        }
    });
    return _blueKeyShadowColor;
}

+ (UIColor *)blueKeyDisabledTitleColor {
    return [self darkKeyDisabledTitleColor];
}

@end

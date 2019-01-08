//
//  KeyboardThemesHelper.m
//  Better Word
//
//  Created by Sergey Vinogradov on 17.03.16.
//
//

#import "KeyboardThemesHelper.h"
#import "Macroses.h"
#import "UIScreen+Orientation.h"

UIColor *colorBackgroundForTheme(KBTheme theme) {
    NSDictionary *const allKeys = @{
        @(KBThemeOriginal): RGB(46, 58, 76),
        @(KBThemeClassic): RGB(209, 213, 219),
        @(KBThemeTransparent): [[UIColor blackColor] colorWithAlphaComponent:0.8]
    };

    return (UIColor *)[allKeys objectForKey:@(theme)];
}

UIColor *colorMenuForTheme(KBTheme theme) {
    NSDictionary *const allKeys = @{
        @(KBThemeOriginal): RGB(43, 50, 66),
        @(KBThemeClassic): RGB(162, 169, 180),
        @(KBThemeTransparent): [UIColor blackColor]
    };
    
    return (UIColor *)[allKeys objectForKey:@(theme)];
}

UIColor *colorAdditionalMenuForTheme(KBTheme theme) {
    NSDictionary *const allKeys = @{
        @(KBThemeOriginal): RGB(43, 50, 66),
        @(KBThemeClassic): RGB(174, 179, 190),
        @(KBThemeTransparent): [[UIColor blackColor] colorWithAlphaComponent:0.8]
    };
    
    return (UIColor *)[allKeys objectForKey:@(theme)];
}

CGFloat cornerRadiusForTheme(KBTheme theme) {
    CGFloat cornerRadius = 0;
    switch (theme) {
        case KBThemeOriginal:
            if (IS_IPAD) {
                cornerRadius = ACInterfaceOrientationIsPortrait ? 5 : 7;
            } else {
                if (IS_IPHONE_5 || IS_IPHONE_5) {
                    cornerRadius = 4;
                } else {
                    cornerRadius = 7;
                }
            }
            break;
            
        case KBThemeClassic:
        case KBThemeTransparent:
            if (IS_IPAD) {
                cornerRadius = ACInterfaceOrientationIsPortrait ? 5 : 7;
            } else {
                if (IS_IPHONE_6_PLUS) {
                    cornerRadius = 4.5;
                } else if (IS_IPHONE_6) {
                    cornerRadius = ACInterfaceOrientationIsPortrait ? 5 : 4;
                } else {
                    cornerRadius = 4;
                }
            }
            break;
            
        default:
            break;
    }
    
    return cornerRadius;
}
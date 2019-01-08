//
//  UIScreen+Orientation.m
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import "UIScreen+Orientation.h"

@implementation UIScreen (Orientation)

- (UIInterfaceOrientation)interfaceOrientation {
    if ([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) {
        return UIInterfaceOrientationLandscapeLeft;
    } else if ([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height) {
        return UIInterfaceOrientationPortrait;
    } else {
        return UIInterfaceOrientationUnknown;
    }
}

- (BOOL)isPortraiteOrientation {
    return UIInterfaceOrientationIsPortrait([[UIScreen mainScreen] interfaceOrientation]);
}

- (BOOL)isLandscapeOrientation {
    return UIInterfaceOrientationIsLandscape([[UIScreen mainScreen] interfaceOrientation]);
}

@end

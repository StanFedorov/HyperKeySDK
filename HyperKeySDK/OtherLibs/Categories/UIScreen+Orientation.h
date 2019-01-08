//
//  UIScreen+Orientation.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import <UIKit/UIKit.h>

#define ACInterfaceOrientationIsPortrait [UIScreen mainScreen].isPortraiteOrientation
#define ACInterfaceOrientationIsLandscape [UIScreen mainScreen].isLandscapeOrientation

@interface UIScreen (Orientation)

- (UIInterfaceOrientation)interfaceOrientation;

- (BOOL)isPortraiteOrientation;
- (BOOL)isLandscapeOrientation;

@end

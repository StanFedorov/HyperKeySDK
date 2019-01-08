//
//  UIImage+Additions.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (UIImage *)patternImageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)proportionallyScaledImageToSize:(CGSize)newSize;
- (UIImage *)scaledImageToSize:(CGSize)newSize;
- (UIImage *)tranlucentWithAlpha:(CGFloat)alpha;

@end

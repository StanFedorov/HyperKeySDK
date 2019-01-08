//
//  UIImage+Additions.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)patternImageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)proportionallyScaledImageToSize:(CGSize)newSize {
	// fit
//	CGSize imageSize = self.size;
//	CGFloat k = imageSize.width / imageSize.height;
//	CGFloat width = newSize.height * k;
//	CGSize size = CGSizeMake(width, newSize.height);
//	return [self ck_scaledImageToSize:size];
	
	// fill
	CGSize imageSize = self.size;
	CGFloat k = imageSize.width / imageSize.height;
	CGFloat height = newSize.width / k;
	CGSize size = CGSizeMake(newSize.width, height);
	return [self scaledImageToSize:size];
}

- (UIImage *)scaledImageToSize:(CGSize)newSize {
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	CGRect rect = CGRectMake(0, 0, newSize.width, newSize.height);
	[self drawInRect:rect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)tranlucentWithAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawAtPoint:CGPointZero blendMode:kCGBlendModeNormal alpha:alpha];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

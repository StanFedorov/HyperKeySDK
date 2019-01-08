//
//  UIFont+Hyperkey.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 08.01.16.
//
//

#import <UIKit/UIKit.h>

@interface UIFont (Hyperkey)

// Helvetica
+ (UIFont *)helveticaFontOfSize:(CGFloat)size;

// HelveticaNeue
+ (UIFont *)helveticaNeueFontOfSize:(CGFloat)size;
+ (UIFont *)helveticaNeueLightFontOfSize:(CGFloat)size;
+ (UIFont *)helveticaNeueThinFontOfSize:(CGFloat)size;
+ (UIFont *)helveticaNeueMediumFontOfSize:(CGFloat)size;
+ (UIFont *)helveticaNeueBoldFontOfSize:(CGFloat)size;

// Dosis
+ (UIFont *)dosisMediumFontOfSize:(CGFloat)size;
+ (UIFont *)dosisBoldFontOfSize:(CGFloat)size;

@end

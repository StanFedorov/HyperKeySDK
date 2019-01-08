//
//  UIFont+Hyperkey.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 08.01.16.
//
//

#import "UIFont+Hyperkey.h"

@implementation UIFont (Hyperkey)

#pragma mark - Helvetica

+ (UIFont *)helveticaFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Helvetica" size:size];
}


#pragma mark - HelveticaNeue

+ (UIFont *)helveticaNeueFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)helveticaNeueLightFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

+ (UIFont *)helveticaNeueThinFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
}

+ (UIFont *)helveticaNeueMediumFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

+ (UIFont *)helveticaNeueBoldFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}


#pragma mark - Dosis

+ (UIFont *)dosisMediumFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Dosis-Medium" size:size];
}

+ (UIFont *)dosisBoldFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Dosis-Bold" size:size];
}

@end

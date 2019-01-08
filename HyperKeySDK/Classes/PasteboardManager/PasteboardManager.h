//
//  PasteboardManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 11/10/15.
//  Copyright (c) 2015 Dmitriy gonchar. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kPasteboardImageLongSidePixelsValue;

@interface PasteboardManager : NSObject

+ (void)setJPEG:(UIImage *)image;
+ (void)setPNG:(UIImage *)image;
+ (void)setGIF:(NSData *)data;
+ (void)setVideo:(NSData *)data;

+ (void)clearPasteboard;

@end

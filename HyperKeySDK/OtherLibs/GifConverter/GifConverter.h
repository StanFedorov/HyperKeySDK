//
//  GifConverter.h
//  CreateVideo
//
//  Created by Maxim Popov popovme@gmail.com on 24.06.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GifConverter : NSObject

+ (void)convertGifData:(NSData *)gifData toVideoFilePath:(NSString *)filePath competion:(void (^)(BOOL success))competion;
+ (void)convertGifFromPath:(NSString *)gifPath toVideoFilePath:(NSString *)filePath competion:(void (^)(BOOL success))competion;
+ (void)resizeGifData:(NSData *)gifData toFilePath:(NSString *)filePath aspectFillSize:(CGSize)fillSize;
+ (void)resizeGifFromPath:(NSString *)gifPath toFilePath:(NSString *)filePath aspectFillSize:(CGSize)fillSize;

@end

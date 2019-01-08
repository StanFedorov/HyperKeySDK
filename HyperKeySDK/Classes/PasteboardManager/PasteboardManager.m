//
//  PasteboardManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 11/10/15.
//  Copyright (c) 2015 Dmitriy gonchar. All rights reserved.
//

#import "PasteboardManager.h"

#import "UIImage+Resize.h"
#import "ImagesLoadingAndSavingManager.h"

#import <MobileCoreServices/MobileCoreServices.h>

CGFloat const kPasteboardImageLongSidePixelsValue = 640;

NSString *const kPasteboardManagerLastSharedMediaFile = @"last_shared.plist";
CGFloat const kPasteboardManagerLastSharedMediaCount = 10;

typedef void (^ ResponceBlockSuccess) (BOOL success);

@interface PasteboardManager ()

@end

@implementation PasteboardManager

#pragma mark - Static

+ (void)setPNG:(UIImage *)image {
    if (!image) {
        return;
    }
    
    UIImage *resultImage = [self resizedImageFormFullImage:image];
    
    NSData *imageData = UIImagePNGRepresentation(resultImage);
    if (imageData) {
        [[UIPasteboard generalPasteboard] setItems:@[]];
        [[UIPasteboard generalPasteboard] setValue:imageData forPasteboardType:(NSString *)kUTTypeJPEG];
    }
}

+ (void)setJPEG:(UIImage *)image {
    if (!image) {
        return;
    }
    
    UIImage *resultImage = [self resizedImageFormFullImage:image];
    
    NSData *imageData = UIImageJPEGRepresentation(resultImage, 1);
    if (imageData) {
        [[UIPasteboard generalPasteboard] setItems:@[]];
        [[UIPasteboard generalPasteboard] setValue:imageData forPasteboardType:(NSString *)kUTTypePNG];
    }
}

+ (void)setGIF:(NSData *)data {
    if (!data) {
        return;
    }
    
    if (data) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:data forPasteboardType:@"com.compuserve.gif"];
    }
}

+ (void)setVideo:(NSData *)data {
    if (!data) {
        return;
    }
    
    if (data) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:data forPasteboardType:@"public.mpeg-4"];
    }
}

+ (void)clearPasteboard {
    [[UIPasteboard generalPasteboard] setItems:@[]];
}


#pragma mark - Private

+ (UIImage *)resizedImageFormFullImage:(UIImage *)image {
    CGSize scaleSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
    if (scaleSize.width > kPasteboardImageLongSidePixelsValue || scaleSize.height > kPasteboardImageLongSidePixelsValue) {
        return [image resizeToHighestSideLenght:kPasteboardImageLongSidePixelsValue];
    } else {
        return image;
    }
}

@end

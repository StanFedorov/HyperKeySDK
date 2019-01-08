//
//  GifConverter.m
//  CreateVideo
//
//  Created by Maxim Popov popovme@gmail.com on 24.06.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "GifConverter.h"

#import "UIImage+Resize.h"

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation GifConverter

+ (void)convertGifData:(NSData *)gifData toVideoFilePath:(NSString *)filePath competion:(void (^)(BOOL success))competion {
    [self convertGifSource:gifData toVideoFilePath:filePath competion:competion];
}

+ (void)convertGifFromPath:(NSString *)gifPath toVideoFilePath:(NSString *)filePath competion:(void (^)(BOOL success))competion {
    [self convertGifSource:gifPath toVideoFilePath:filePath competion:competion];
}

+ (void)resizeGifData:(NSData *)gifData toFilePath:(NSString *)filePath aspectFillSize:(CGSize)fillSize {
    [self resizeGifSource:gifData toFilePath:filePath aspectFillSize:fillSize];
}

+ (void)resizeGifFromPath:(NSString *)gifPath toFilePath:(NSString *)filePath aspectFillSize:(CGSize)fillSize {
    [self resizeGifSource:gifPath toFilePath:filePath aspectFillSize:fillSize];
}


#pragma mark - Private

+ (void)resizeGifSource:(id)gifSource toFilePath:(NSString *)filePath aspectFillSize:(CGSize)fillSize {
    CGImageSourceRef source = nil;
    if ([gifSource isKindOfClass:[NSString class]]) {
        source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:gifSource], nil);
    } else {
        source = CGImageSourceCreateWithData((__bridge CFDataRef)gifSource, nil);
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    NSInteger maxFrameIndex = CGImageSourceGetCount(source) - 1;
    
    NSDictionary *gifProperties = @{(__bridge id)kCGImagePropertyGIFLoopCount: @(0),
                                    (__bridge id)kCGImagePropertyGIFHasGlobalColorMap: @(NO)};
    NSDictionary *fileProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: gifProperties};
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], kUTTypeGIF, maxFrameIndex, nil);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (size_t frameIndex = 0; frameIndex <= maxFrameIndex; frameIndex ++) {
        @autoreleasepool {
            NSDictionary *options = @{(NSString *)kCGImageSourceTypeIdentifierHint:(id)kUTTypeGIF};
            CGImageRef imgRef = CGImageSourceCreateImageAtIndex(source, frameIndex, (__bridge CFDictionaryRef)options);
            if (imgRef) {
                CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, frameIndex, nil);
                if (properties) {
                    CFDictionaryRef gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                    
                    UIImage *newImage = [[UIImage imageWithCGImage:imgRef] resizeImageToScaleDownAspectFillSize:fillSize];
                    
                    CGImageDestinationAddImage(destination, newImage.CGImage, gifProperties);
                }
            }
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Error: failed to finalize image destination");
    }
    
    CFRelease(destination);
}

+ (void)convertGifSource:(id)gifSource toVideoFilePath:(NSString *)filePath competion:(void (^)(BOOL success))competion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageSourceRef source = nil;
        if ([gifSource isKindOfClass:[NSString class]]) {
            source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:gifSource], nil);
        } else {
            source = CGImageSourceCreateWithData((__bridge CFDataRef)gifSource, nil);
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
        
        NSError *error = nil;
        AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            if (competion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    competion(NO);
                });
            }
            return;
        }
        
        CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil);
        NSNumber *width = (NSNumber *)CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
        NSNumber *height = (NSNumber *)CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
        CGSize size = CGSizeMake(width.integerValue, height.integerValue);
        size_t maxFrameIndex = CGImageSourceGetCount(source) - 1;
        int32_t timeScale = 600;
        Float64 totalFrameDelay = 0;
        
        NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                        AVVideoWidthKey: @(size.width),
                                        AVVideoHeightKey: @(size.height)};
        AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings: videoSettings];
        videoWriterInput.expectsMediaDataInRealTime = YES;
        
        if (![videoWriter canAddInput: videoWriterInput]) {
            NSLog(@"Video writer can not add video writer input");
            if (competion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    competion(NO);
                });
            }
            return;
        }
        [videoWriter addInput: videoWriterInput];
        
        NSDictionary *attributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
                                     (NSString *)kCVPixelBufferWidthKey: @(size.width),
                                     (NSString *)kCVPixelBufferHeightKey: @(size.height),
                                     (NSString *)kCVPixelBufferCGImageCompatibilityKey: @(YES),
                                     (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES)};
        
        AVAssetWriterInputPixelBufferAdaptor* adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:attributes];
        
        [videoWriter startWriting];
        [videoWriter startSessionAtSourceTime:CMTimeMakeWithSeconds(totalFrameDelay, timeScale)];
        
        for (size_t frameIndex = 0; frameIndex <= maxFrameIndex; frameIndex ++) {
            NSDictionary *options = @{(NSString *)kCGImageSourceTypeIdentifierHint:(id)kUTTypeGIF};
            CGImageRef imgRef = CGImageSourceCreateImageAtIndex(source, frameIndex, (__bridge CFDictionaryRef)options);
            if (imgRef) {
                CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(source, frameIndex, nil);
                CFDictionaryRef gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
                if (gifProperties) {
                    CVPixelBufferRef pxBuffer = [self pixelBufferFromImageRef:imgRef bufferPool:adaptor.pixelBufferPool attributes:adaptor.sourcePixelBufferAttributes];
                    if (pxBuffer) {
                        CMTime time = CMTimeMakeWithSeconds(totalFrameDelay, timeScale);
                        while (!videoWriterInput.readyForMoreMediaData) {
                            [NSThread sleepForTimeInterval:0.1];
                        }
                        if (![adaptor appendPixelBuffer:pxBuffer withPresentationTime:time]) {
                            CFRelease(properties);
                            CGImageRelease(imgRef);
                            CVBufferRelease(pxBuffer);
                            if (competion) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    competion(NO);
                                });
                            }
                            break;
                        }
                        
                        NSNumber *delayTime = CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                        totalFrameDelay += delayTime.floatValue;
                        
                        if (frameIndex == maxFrameIndex) { // For freeze last frame
                            CMTime time = CMTimeMakeWithSeconds(totalFrameDelay, timeScale);
                            while (!videoWriterInput.readyForMoreMediaData) {
                                [NSThread sleepForTimeInterval:0.1];
                            }
                            if (![adaptor appendPixelBuffer:pxBuffer withPresentationTime:time]) {
                                CFRelease(properties);
                                CGImageRelease(imgRef);
                                CVBufferRelease(pxBuffer);
                                if (competion) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        competion(NO);
                                    });
                                }
                                break;
                            }
                        }
                        
                        CVBufferRelease(pxBuffer);
                    }
                }
                
                if (properties) {
                    CFRelease(properties);
                }
                
                CGImageRelease(imgRef);
            } else {
                if (competion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        competion(NO);
                    });
                }
            }
        }
        
        [videoWriterInput markAsFinished];
        [videoWriter finishWritingWithCompletionHandler:^{
            if (competion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    competion(YES);
                });
            }
        }];
        
        CFRelease(source);
    });
}

+ (CVPixelBufferRef)pixelBufferFromImageRef:(CGImageRef)imageRef bufferPool:(CVPixelBufferPoolRef)bufferPool attributes: (NSDictionary *)attributes {
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bpc = 8;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CVPixelBufferRef pxBuffer = nil;
    CVReturn status = kCVReturnSuccess;
    if (bufferPool) {
        status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, bufferPool, &pxBuffer);
    } else {
        status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)attributes, &pxBuffer);
    }
    NSAssert(status == kCVReturnSuccess, @"Could not create a pixel buffer");
    
    CVPixelBufferLockBaseAddress(pxBuffer, 0);
    void *pxData = CVPixelBufferGetBaseAddress(pxBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxBuffer);
    
    CGContextRef context = CGBitmapContextCreate(pxData, width, height, bpc, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst);
    NSAssert(context, @"Could not create a context");
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CVPixelBufferUnlockBaseAddress(pxBuffer, 0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    return pxBuffer;
}

@end

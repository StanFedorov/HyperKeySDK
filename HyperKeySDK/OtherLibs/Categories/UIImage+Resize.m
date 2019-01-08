//
//  UIImage+Resize.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 22.10.16.
//
//

#import "UIImage+Resize.h"

@implementation UIImage (ResizeCategory)

- (UIImage *)resizedImageToSize:(CGSize)dstSize {
    return [self resizedImageToSize:dstSize scale:0];
}

- (UIImage *)resizedImageToSize:(CGSize)dstSize scale:(CGFloat)scale {
    CGImageRef imgRef = self.CGImage;
    CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    
    // Don't resize if we already meet the required destination size.
    if (CGSizeEqualToSize(srcSize, dstSize) && scale == self.scale) {
        return self;
    }
    
    CGFloat scaleRatio = dstSize.width / srcSize.width;
    UIImageOrientation orient = self.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, scale > 0 ? scale : self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (!context) {
        return nil;
    }
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }
    
    CGContextConcatCTM(context, transform);
    
    // We use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    CGContextDrawImage(context, CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *)resizedImageToFitInSize:(CGSize)boundingSize resizeUp:(BOOL)resize scale:(CGFloat)scale {
	CGImageRef imgRef = self.CGImage;
	CGSize srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));

	switch (self.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			boundingSize = CGSizeMake(boundingSize.height, boundingSize.width);
			break;
            
        default:
            break;
	}

	CGSize dstSize;
	if (!resize && (srcSize.width < boundingSize.width) && (srcSize.height < boundingSize.height) ) {
		dstSize = srcSize;
	} else {		
		CGFloat wRatio = boundingSize.width / srcSize.width;
		CGFloat hRatio = boundingSize.height / srcSize.height;
		
		if (wRatio < hRatio) {
			dstSize = CGSizeMake(boundingSize.width, floorf(srcSize.height * wRatio));
		} else {
			dstSize = CGSizeMake(floorf(srcSize.width * hRatio), boundingSize.height);
		}
	}
		
	return [self resizedImageToSize:dstSize scale:scale];
}

- (UIImage *)resizeToHighestSideLenght:(NSUInteger)lenght {
    CGImageRef imgRef = self.CGImage;
    CGSize size = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGSize newSize = [UIImage getImageSizeForHighestSideLenght:lenght withImageSize:size];
    
    return [self resizedImageToSize:newSize];
}

- (UIImage *)resizeImageToCellSize:(CGSize)cellSize {
    CGFloat actualHeight = self.size.height;
    CGFloat actualWidth = self.size.width;
    CGFloat imgRatio = actualWidth / actualHeight;
    CGFloat maxRatio = cellSize.width * 2.0 / cellSize.height * 2.0;
    
    if( imgRatio < maxRatio) {
        imgRatio = cellSize.height * 2.0 / actualHeight;
        actualWidth = imgRatio * actualWidth;
        actualHeight = cellSize.height * 2.0;
    } else {
        imgRatio = cellSize.width * 2.0 / actualWidth;
        actualHeight = imgRatio * actualHeight;
        actualWidth = cellSize.width * 2.0;
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [self drawInRect:rect];
    UIImage *imageToDraw = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageToDraw;
}

+ (CGSize)getImageSizeForHighestSideLenght:(NSUInteger)lenght withImageSize:(CGSize)size {
    if (size.width <= lenght && size.height <= lenght) {
        return size;
    }
    
    CGFloat multiply = (CGFloat)lenght / (size.width > size.height ? size.width : size.height);
    
    return CGSizeMake(size.width * multiply, size.height * multiply);
}


#pragma mark - New

#pragma mark - Public

+ (CGSize)sizeForImageSize:(CGSize)imageSize resizeSize:(CGSize)resizeSize resizeMode:(HKImageResizeMode)reszeMode {
    return [[self class] roundRect:[[self class] rectForImageSize:imageSize resizeSize:resizeSize resizeMode:reszeMode]].size;
}

- (UIImage *)resizeImageToSize:(CGSize)dstSize resizeMode:(HKImageResizeMode)reszeMode {
    CGRect drawRect = [[self class] rectForImageSize:self.size resizeSize:dstSize resizeMode:reszeMode];
    if (drawRect.origin.x == 0 && drawRect.origin.y == 0 && CGSizeEqualToSize(self.size, drawRect.size)) {
        return self;
    }
    
    return [self drawImageToRect:drawRect];
}

- (UIImage *)resizeImageToScaleDownFillSize:(CGSize)dstSize {
    return [self resizeImageToSize:dstSize resizeMode:HKImageResizeModeScaleDownFill];
}

- (UIImage *)resizeImageToScaleDownAspectFitSize:(CGSize)dstSize {
    return [self resizeImageToSize:dstSize resizeMode:HKImageResizeModeScaleDownAspectFit];
}

- (UIImage *)resizeImageToScaleDownAspectFillSize:(CGSize)dstSize {
    return [self resizeImageToSize:dstSize resizeMode:HKImageResizeModeScaleDownAspectFill];
}

- (UIImage *)resizeImageToScaleDownAspectFillCropSize:(CGSize)dstSize {
    return [self resizeImageToSize:dstSize resizeMode:HKImageResizeModeScaleDownAspectFillCrop];
}


#pragma mark - Private

+ (CGRect)roundRect:(CGRect)rect {
    return CGRectMake(roundf(rect.origin.x), roundf(rect.origin.y), roundf(rect.size.width), roundf(rect.size.height));
}

+ (CGRect)rectForImageSize:(CGSize)imageSize resizeSize:(CGSize)resizeSize resizeMode:(HKImageResizeMode)reszeMode {
    CGRect resultRect = CGRectMake(0, 0, resizeSize.width, resizeSize.height);
    
    if (CGSizeEqualToSize(imageSize, resizeSize)) {
        return resultRect;
    }
    
    CGFloat widthFactor = resizeSize.width / imageSize.width;
    CGFloat heightFactor = resizeSize.height / imageSize.height;
    
    switch (reszeMode) {
        case HKImageResizeModeScaleDownFill:
            if (widthFactor > heightFactor) {
                if (widthFactor > 1) {
                    resultRect.size.width = resizeSize.width / widthFactor;
                    resultRect.size.height = resizeSize.height / widthFactor;
                }
            } else if (widthFactor < heightFactor) {
                if (heightFactor > 1) {
                    resultRect.size.width = resizeSize.width / heightFactor;
                    resultRect.size.height = resizeSize.height / heightFactor;
                }
            }
            break;
            
        case HKImageResizeModeScaleDownAspectFit:
            if (widthFactor > heightFactor) {
                if (heightFactor < 1) {
                    resultRect.size.width = imageSize.width * heightFactor;
                } else {
                    resultRect.size = imageSize;
                }
            } else if (widthFactor < heightFactor) {
                if (widthFactor < 1) {
                    resultRect.size.height = imageSize.height * widthFactor;
                } else {
                    resultRect.size = imageSize;
                }
            }
            break;
            
        case HKImageResizeModeScaleDownAspectFill:
            if (widthFactor > heightFactor) {
                if (widthFactor < 1) {
                    resultRect.size.height = imageSize.height * widthFactor;
                } else {
                    resultRect.size = imageSize;
                }
            } else if (widthFactor < heightFactor) {
                if (heightFactor < 1) {
                    resultRect.size.width = imageSize.width * heightFactor;
                } else {
                    resultRect.size = imageSize;
                }
            }
            break;
            
        case HKImageResizeModeScaleDownAspectFillCrop:
            if (widthFactor > heightFactor) {
                if (widthFactor <= 1) {
                    resultRect.origin.y = (imageSize.height * widthFactor - resizeSize.height) / 2;
                } else {
                    resultRect.size.width = resizeSize.width / widthFactor;
                    resultRect.size.height = resizeSize.height / widthFactor;
                    resultRect.origin.y = (imageSize.height - resultRect.size.height) / 2;
                }
            } else if (widthFactor < heightFactor) {
                if (heightFactor <= 1) {
                    resultRect.origin.x = (imageSize.width * heightFactor - resizeSize.width) / 2;
                } else {
                    resultRect.size.width = resizeSize.width / heightFactor;
                    resultRect.size.height = resizeSize.height / heightFactor;
                    resultRect.origin.x = (imageSize.width - resultRect.size.width) / 2;
                }
            }
            break;
            
        default:
            break;
    }
    
    return resultRect;
}

- (UIImage *)drawImageToRect:(CGRect)dstRect {
    CGImageRef imageRef = self.CGImage;
    CGFloat scale = self.scale;
    UIImageOrientation orientation = self.imageOrientation;
    
    CGRect drawRect = dstRect;
    if (dstRect.origin.x != 0) {
        drawRect.origin.x = -dstRect.origin.x;
        drawRect.size.width += dstRect.origin.x * 2;
    }
    if (dstRect.origin.y != 0) {
        drawRect.origin.y = -dstRect.origin.y;
        drawRect.size.height += dstRect.origin.y * 2;
    }
    
    dstRect = [[self class] roundRect:dstRect];
    drawRect = [[self class] roundRect:drawRect];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, dstRect.size.width, dstRect.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, dstRect.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            
            drawRect = CGRectMake(drawRect.origin.y, drawRect.origin.x, drawRect.size.height, drawRect.size.width);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, dstRect.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            
            drawRect = CGRectMake(drawRect.origin.y, drawRect.origin.x, drawRect.size.height, drawRect.size.width);
            break;
        
        default:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, dstRect.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, dstRect.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        
        default:
            break;
    }
    

    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bytesPerRow = CGImageGetBitsPerPixel(imageRef) / 8 * dstRect.size.width;
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    
    // Fix alpha for not supported iOS SDK images
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    switch (alphaInfo) {
        case kCGImageAlphaFirst:
        case kCGImageAlphaLast:
        case kCGImageAlphaPremultipliedFirst:
        case kCGImageAlphaPremultipliedLast:
            alphaInfo = kCGImageAlphaPremultipliedFirst;
            break;
            
        default:
            alphaInfo = kCGImageAlphaNoneSkipFirst;
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(nil, dstRect.size.width, dstRect.size.height, bitsPerComponent, bytesPerRow, colorSpace, kCGBitmapByteOrderDefault | alphaInfo);
    if (!context) {
        return self;
    }
    
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, drawRect, imageRef);
    
    CGImageRef resultImageRef = CGBitmapContextCreateImage(context);
    UIImage *resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    
    CGImageRelease(resultImageRef);
    CGContextRelease(context);
    
    return resultImage;
}

@end

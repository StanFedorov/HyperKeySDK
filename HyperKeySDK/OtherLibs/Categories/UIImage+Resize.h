//
//  UIImage+Resize.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 22.10.16.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HKImageResizeMode) {
    HKImageResizeModeScaleDownFill,
    HKImageResizeModeScaleDownAspectFit,
    HKImageResizeModeScaleDownAspectFill,
    HKImageResizeModeScaleDownAspectFillCrop,
};

@interface UIImage(ResizeCategory)

- (UIImage *)resizedImageToSize:(CGSize)dstSize;
- (UIImage *)resizedImageToSize:(CGSize)dstSize scale:(CGFloat)scale;
- (UIImage *)resizedImageToFitInSize:(CGSize)boundingSize resizeUp:(BOOL)resize scale:(CGFloat)scale;
- (UIImage *)resizeToHighestSideLenght:(NSUInteger)lenght;

- (UIImage *)resizeImageToCellSize:(CGSize)cellSize;

+ (CGSize)getImageSizeForHighestSideLenght:(NSUInteger)lenght withImageSize:(CGSize)size;


// New
+ (CGSize)sizeForImageSize:(CGSize)imageSize resizeSize:(CGSize)resizeSize resizeMode:(HKImageResizeMode)reszeMode;

- (UIImage *)resizeImageToSize:(CGSize)dstSize resizeMode:(HKImageResizeMode)reszeMode;

// Without scale up
- (UIImage *)resizeImageToScaleDownFillSize:(CGSize)dstSize;
- (UIImage *)resizeImageToScaleDownAspectFitSize:(CGSize)dstSize;
- (UIImage *)resizeImageToScaleDownAspectFillSize:(CGSize)dstSize;
- (UIImage *)resizeImageToScaleDownAspectFillCropSize:(CGSize)dstSize;

@end

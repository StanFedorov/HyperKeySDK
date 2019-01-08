//
//  DrawImageColorBar.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 24.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageColorBarView.h"

#import "UIColor+DrawImage.h"

CGFloat const kDrawImageColorBarViewContentViewCornerRadius = 5;
CGFloat const kDrawImageColorBarViewContentViewBorderWidth = 0.5;
CGFloat const kDrawImageColorBarViewColorContentViewCornerRadius = 5;
CGFloat const kDrawImageColorBarViewColorContentViewBorderWidth = 0.5;
CGFloat const kDrawImageColorBarIndicatorViewCornerRadius = 15;

@interface DrawImageColorBarView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *colorContentView;
@property (weak, nonatomic) IBOutlet UIView *blackColorView;
@property (weak, nonatomic) IBOutlet UIView *whiteColorView;
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UIView *colorIndicatorView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indicatorLeftConstraint;

@property (assign, nonatomic) CGFloat value;

@end

@implementation DrawImageColorBarView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialization];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutIfNeeded];
    [self updateIndicatorPosition];
}


#pragma mark - Initialization

- (void)initialization {
    self.contentView.layer.borderColor = [UIColor drawImageBgGrayLightColor].CGColor;
    self.contentView.layer.borderWidth = kDrawImageColorBarViewContentViewBorderWidth;
    self.contentView.layer.cornerRadius = kDrawImageColorBarViewContentViewCornerRadius;
    
    self.colorContentView.layer.borderColor = [UIColor drawImageBgGrayDarkColor].CGColor;
    self.colorContentView.layer.borderWidth = kDrawImageColorBarViewColorContentViewBorderWidth;
    self.colorContentView.layer.cornerRadius = kDrawImageColorBarViewColorContentViewCornerRadius;
    
    self.indicatorView.backgroundColor = [UIColor drawImageBgIndicatorBorderColor];
    self.indicatorView.layer.cornerRadius = kDrawImageColorBarIndicatorViewCornerRadius;
    
    self.colorIndicatorView.backgroundColor = [UIColor blackColor];
    self.colorIndicatorView.layer.cornerRadius = kDrawImageColorBarIndicatorViewCornerRadius-1;
    
    self.colorImageView.image = [self hueImage];
    
    [self updateIndicatorWithPosition:0];
}

#pragma mark - Custom setters

- (void)setColor:(UIColor *)color {
    // we set saturation/alpha = 1
    CGFloat hue;
    CGFloat brightness;
    BOOL success = [color getHue:&hue saturation:nil brightness:&brightness alpha:nil];
    if (!success) {
        return;
    }
    _color = color;
    
    if (hue) {
        self.value = (hue * self.colorImageView.frame.size.width + (self.blackColorView.frame.size.width - kDrawImageColorBarViewColorContentViewBorderWidth))/[self colorFieldWidth];
    } else {
        if (brightness) { //white
            self.value = 1;
        } else { //black
            self.value = 0;
        }
    }
    
    self.colorIndicatorView.backgroundColor = self.color;
    [self updateIndicatorPosition];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}


#pragma mark - Private

- (CGFloat)colorFieldWidth {
    return self.colorContentView.frame.size.width - kDrawImageColorBarViewColorContentViewBorderWidth * 2;
}

- (CGFloat)indicatorOffset {
    return self.contentView.frame.origin.x + self.colorContentView.frame.origin.x + kDrawImageColorBarViewColorContentViewBorderWidth;
}

- (void)updateIndicatorWithPosition:(CGFloat)position {
    CGFloat indicatorOffset = [self indicatorOffset];
    
    if (position < indicatorOffset) {
        position = indicatorOffset;
    } else if (position > self.frame.size.width - indicatorOffset) {
        position = self.frame.size.width - indicatorOffset;
    }
    
    CGFloat colorPosition = position - indicatorOffset;
    self.value = colorPosition / [self colorFieldWidth];
    
    if (colorPosition <= (self.blackColorView.frame.size.width - kDrawImageColorBarViewColorContentViewBorderWidth)) {
        _color = [UIColor blackColor];
    } else if (colorPosition >= self.whiteColorView.frame.origin.x) {
        _color = [UIColor whiteColor];
    } else {
        CGFloat hue = (colorPosition - (self.blackColorView.frame.size.width - kDrawImageColorBarViewColorContentViewBorderWidth)) / self.colorImageView.frame.size.width;
        _color = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
    }
    self.colorIndicatorView.backgroundColor = self.color;
    
    [self updateIndicatorPosition];
}

- (void)updateIndicatorPosition {
    self.indicatorLeftConstraint.constant = [self indicatorOffset] + [self colorFieldWidth] * self.value - self.indicatorView.frame.size.width / 2;
}


#pragma mark - Private Images

- (UIImage *)hueImage {
    NSInteger width = 256;
    NSInteger height = 1;
    NSInteger colorSize = 4;
    
    UInt8 baseData[width * colorSize];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    CGContextRef context = CGBitmapContextCreate(baseData, width, height, 8, width * colorSize, colorSpace, bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        return nil;
    }
    
    UInt8 *data = CGBitmapContextGetData(context);
    if (!data) {
        CGContextRelease(context);
        return nil;
    }
    
    CGFloat r = 0;
    CGFloat g = 0;
    CGFloat b = 0;
    CGFloat a = 0;
    
    for (CGFloat i = 0; i < width; i++) {
        CGFloat hue = i / 255.0;
        
        UIColor *color = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
        [color getRed:&r green:&g blue:&b alpha:&a];
        
        data[0] = (UInt8)(b * 255);
        data[1] = (UInt8)(g * 255);
        data[2] = (UInt8)(r * 255);
        
        data += 4;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    CGPoint point = [[touches anyObject] locationInView:self];
    
    [self updateIndicatorWithPosition:point.x];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(drawImageColorBarViewDidSelectColor:)]) {
        [self.delegate drawImageColorBarViewDidSelectColor:self.color];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

@end

//
//  ACKey.m
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/17/14.
//
//

#import "ACKey.h"

#import "ACLightAppearance.h"
#import "ACDarkAppearance.h"
#import "Macroses.h"

CGFloat const kKeyPadPortraitTitleFontSize = 22.0;
CGFloat const kKeyPadLandscapeTitleFontSize = 26.0;

NSString *const kKeyNotificationHideButtonPopup = @"KeyNotificationHideButtonPopup";

NSUInteger const kKeyOverlayTag = -12;
NSUInteger const kKeyPopupViewTag = 1136;

CGFloat const kKeyShadowYOffset = 1.0;
CGFloat const kKeyPhoneTitleFontSize = 17.0;

CGFloat const kKeyLabelOffsetY = -0;
CGFloat const kKeyImageOffsetY = -0.5;

CGFloat const kKeyPhoneDefaultCornerRadius = 4.0;
CGFloat const kKeyPadDefaultCornerRadius = 5.0;
CGFloat const kKeyLiftYAmount = -2;

CGFloat const kKeyPopapStayAliveInterval = 0.075;
CGFloat const kKeyPopapAppearDuration = 0.025;

typedef NS_ENUM(NSUInteger, NumberPadViewImageType) {
    NumberPadViewImageLeft = 0,
    NumberPadViewImageInner,
    NumberPadViewImageRight,
    NumberPadViewImageMax
};

@interface ACKey ()

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *shadowColor;
@property (assign, nonatomic) CGFloat verticalShiftForLabel;

@property (weak, nonatomic) NSTimer *hidePopupTimer;

@end

@implementation ACKey

- (void)dealloc {
    [self removePopUpObserver];
}

+ (instancetype)keyWithStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance {
    ACKey *key = [[self alloc] initWithKeyStyle:style appearance:appearance];
    [key updateState];
    return key;
}

+ (instancetype)keyWithStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance image:(UIImage *)image {
    ACKey *key = [self keyWithStyle:style appearance:(ACKeyAppearance)appearance];
    key.image = image;
    return key;
}

+ (instancetype)keyWithStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance title:(NSString *)title {
    ACKey *key = [self keyWithStyle:style appearance:(ACKeyAppearance)appearance];
    key.title = title;
    return key;
}

- (instancetype)initWithKeyStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.style = style;
        self.appearance = appearance;
        if (IS_IPAD) {
            self.cornerRadius = kKeyPadDefaultCornerRadius;
        } else {
            self.cornerRadius = kKeyPhoneDefaultCornerRadius;
        }
        self.needHighlighting = NO;
    }
    return self;
}

- (instancetype)init {
    return [self initWithKeyStyle:ACKeyStyleDark appearance:ACKeyAppearanceLight];
}

#pragma mark - Properties

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        
        if (IS_IPAD) {
            _label.font = [UIFont systemFontOfSize:kKeyPadLandscapeTitleFontSize];
        } else {
            _label.font = [UIFont systemFontOfSize:kKeyPhoneTitleFontSize];
        }
        _label.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        [self addSubview:_label];
    }
    return _label;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (void)setTitle:(NSString *)title {
    self.label.text = title;
    [self updateState];
}

- (NSString *)title {
    return self.label.text;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self updateState];
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setKeyStyle:(ACKeyStyle)style {
    if (_style == style) {
        return;
    }
    
    _style = style;
    [self updateState];
}

- (void)setAppearance:(ACKeyAppearance)appearance {
    if (_appearance == appearance) {
        return;
    }
    
    _appearance = appearance;
    [self updateState];
}

- (void)setTitleFont:(UIFont *)titleFont {
    self.label.font = titleFont;
}

- (UIFont *)titleFont {
    return self.label.font;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius == _cornerRadius) {
        return;
    }
    
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)addPopupToButton:(ACKey *)button {
    [self hidePopup];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kKeyNotificationHideButtonPopup object:nil];
    
    [self addPopUpObserver];
    
    if (button.title.length && button.title.length == 1) {
        UIImageView *keyPop = nil;
        
        if (self.appearance == ACKeyAppearanceClearWhite) {
            keyPop = [[UIImageView alloc] initWithFrame:CGRectMake(-3, -4.5, self.frame.size.width + 6, self.frame.size.height + 9)];
            keyPop.backgroundColor = RGBA(19, 160, 237, 0.3);
        } else {
            UIImage *image = [self createiOS7KeytopImageWithKind:NumberPadViewImageInner];
            
            keyPop = [[UIImageView alloc] initWithImage:image];
            keyPop.frame = CGRectMake((self.frame.size.width - image.size.width) / 2, IS_IPAD ? -60 : -71, keyPop.frame.size.width, keyPop.frame.size.height);
            
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, keyPop.frame.size.width, 60)];
            [text setFont:[UIFont systemFontOfSize:35]];
            [text setTextAlignment:NSTextAlignmentCenter];
            [text setBackgroundColor:[UIColor clearColor]];
            [text setAdjustsFontSizeToFitWidth:YES];
            [text setText:button.title];
            [text setTextColor:self.label.textColor];
            
            keyPop.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
            keyPop.layer.shadowOffset = CGSizeMake(0, 2.0);
            keyPop.layer.shadowOpacity = 0.30;
            keyPop.layer.shadowRadius = 3.0;
            keyPop.clipsToBounds = NO;
            
            [keyPop addSubview:text];
        }
        
        [keyPop setTag:kKeyPopupViewTag];
        [keyPop setAlpha:0.8];
        [button addSubview:keyPop];
        [UIView animateWithDuration:kKeyPopapAppearDuration animations:^{
            [keyPop setAlpha:1.0];
        }];
    }
}

- (void)addPopUpObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hidePopup) name:kKeyNotificationHideButtonPopup object:nil];
}

- (void)removePopUpObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kKeyNotificationHideButtonPopup object:nil];
}

- (UIImage *)createiOS7KeytopImageWithKind:(int)kind {
    CGFloat scale = SCREEN_SCALE;
    CGFloat upperWidth = 55.0 * scale;
    CGFloat lowerWidth = self.frame.size.width * scale;
    
    CGFloat panUpperRadius = 10.0 * scale;
    CGFloat panLowerRadius = 5.0 * scale;
    CGFloat panUpperWidth = upperWidth - panUpperRadius * 2;
    CGFloat panUpperHeight = 56.0 * scale;
    CGFloat panLowerWidth = lowerWidth - panLowerRadius * 2;
    CGFloat panLowerHeight = 47.0 * scale;
    CGFloat panULWidth = (upperWidth - lowerWidth) / 2;
    CGFloat panMiddleHeight = 2.0 * scale;
    CGFloat panCurveSize = 10.0 * scale;
    
    CGFloat paddingX = 15 * scale;
    CGFloat paddingY = 10 * scale;
    CGFloat width = upperWidth + paddingX * 2;
    CGFloat height = panUpperHeight + panMiddleHeight + panLowerHeight + paddingY * 2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint p = CGPointMake(paddingX, paddingY);
    CGPoint p1 = CGPointZero;
    CGPoint p2 = CGPointZero;
    
    p.x += panUpperRadius;
    CGPathMoveToPoint(path, nil, p.x, p.y);
    
    p.x += panUpperWidth;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    p.y += panUpperRadius;
    CGPathAddArc(path, nil, p.x, p.y, panUpperRadius, 3.0 * M_PI_2, 4.0 * M_PI_2, NO);
    
    p.x += panUpperRadius;
    p.y += panUpperHeight - panUpperRadius - panCurveSize;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y + panCurveSize);
    switch (kind) {
        case NumberPadViewImageLeft:
            p.x -= panULWidth * 2;
            break;
            
        case NumberPadViewImageInner:
            p.x -= panULWidth;
            break;
            
        case NumberPadViewImageRight:
            break;
    }
    
    p.y += panMiddleHeight + panCurveSize * 2;
    p2 = CGPointMake(p.x, p.y - panCurveSize);
    CGPathAddCurveToPoint(path, nil, p1.x, p1.y, p2.x, p2.y, p.x, p.y);
    
    p.y += panLowerHeight - panCurveSize - panLowerRadius;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    p.x -= panLowerRadius;
    CGPathAddArc(path, nil, p.x, p.y, panLowerRadius, 4.0 * M_PI_2, M_PI_2, NO);
    
    p.x -= panLowerWidth;
    p.y += panLowerRadius;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    p.y -= panLowerRadius;
    CGPathAddArc(path, nil, p.x, p.y, panLowerRadius, M_PI_2, 2.0 * M_PI_2, NO);
    
    p.x -= panLowerRadius;
    p.y -= panLowerHeight - panLowerRadius - panCurveSize;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    p1 = CGPointMake(p.x, p.y - panCurveSize);
    
    switch (kind) {
        case NumberPadViewImageLeft:
            break;
            
        case NumberPadViewImageInner:
            p.x -= panULWidth;
            break;
            
        case NumberPadViewImageRight:
            p.x -= panULWidth * 2;
            break;
    }
    
    p.y -= panMiddleHeight + panCurveSize * 2;
    p2 = CGPointMake(p.x, p.y + panCurveSize);
    CGPathAddCurveToPoint(path, nil, p1.x, p1.y, p2.x, p2.y, p.x, p.y);
    
    p.y -= panUpperHeight - panUpperRadius - panCurveSize;
    CGPathAddLineToPoint(path, nil, p.x, p.y);
    
    p.x += panUpperRadius;
    CGPathAddArc(path, nil, p.x, p.y, panUpperRadius, 2.0 * M_PI_2, 3.0 * M_PI_2, NO);

    CGContextRef context;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    context = UIGraphicsGetCurrentContext();
    
    switch (kind) {
        case NumberPadViewImageLeft:
            CGContextTranslateCTM(context, 6.0, height);
            break;
            
        case NumberPadViewImageInner:
            CGContextTranslateCTM(context, 0.0, height);
            break;
            
        case NumberPadViewImageRight:
            CGContextTranslateCTM(context, -6.0, height);
            break;
    }
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGRect frame = CGPathGetBoundingBox(path);
    CGColorRef backColor;
    switch (self.appearance) {
        case ACKeyAppearanceDark:
            backColor = [ACDarkAppearance lightKeyColor].CGColor;
            break;

        default:
        case ACKeyAppearanceLight:
            backColor = [ACLightAppearance lightKeyColor].CGColor;
            break;
    }
    CGContextSetFillColorWithColor(context, backColor);
    CGContextFillRect(context, frame);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationDown];
    CGImageRelease(imageRef);
    
    UIGraphicsEndImageContext();
    
    CFRelease(path);
    
    return image;
}


#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (!IS_IPAD) {
        [self addPopupToButton:self];
    }
    [self updateState];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    [self updateState];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self startHideTimerPopup];
    [self updateState];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    [self startHideTimerPopup];
    [self updateState];
}

- (void)startHideTimerPopup {
    [self stopHideTimerPopup];
    
    if (!IS_IPAD) {
        self.hidePopupTimer = [NSTimer scheduledTimerWithTimeInterval:kKeyPopapStayAliveInterval target:self selector:@selector(hidePopup) userInfo:nil repeats:NO];
    }
}

- (void)hidePopup {
    [self stopHideTimerPopup];
    [self removePopUpObserver];
    [[self viewWithTag:kKeyPopupViewTag] removeFromSuperview];
}

- (void)stopHideTimerPopup {
    [self.hidePopupTimer invalidate];
    self.hidePopupTimer = nil;
}

#pragma mark - state

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateState];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateState];
}

- (void)updateState {
    switch (self.appearance) {
        case ACKeyAppearanceDark: {
            switch (self.style) {
                case ACKeyStyleLight: {
                    self.label.textColor = [UIColor whiteColor];
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = RGB(43, 50, 66);
                            self.shadowColor = [ACDarkAppearance darkKeyShadowColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACDarkAppearance lightKeyColor];
                            self.shadowColor = [ACDarkAppearance lightKeyShadowColor];
                            break;
                    }
                    break;
                }
                case ACKeyStyleDark: {
                    self.label.textColor = [UIColor whiteColor];
                    if (self.tag == kKeyOverlayTag) {
                        self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    } else {
                        self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    }
                    self.imageView.tintColor = [ACDarkAppearance whiteColor];
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = RGB(43, 50, 66);
                            self.shadowColor = [ACDarkAppearance lightKeyShadowColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACDarkAppearance darkKeyColor];
                            self.shadowColor = [ACDarkAppearance darkKeyShadowColor];
                            break;
                    }
                    break;
                }
                case ACKeyStyleBlue: {
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = RGB(43, 50, 66);
                            self.shadowColor = [ACDarkAppearance lightKeyShadowColor];
                            self.label.textColor = [ACDarkAppearance blackColor];
                            break;
                            
                        case UIControlStateDisabled:
                            self.color = [ACDarkAppearance darkKeyColor];
                            self.shadowColor = [ACDarkAppearance darkKeyShadowColor];
                            self.label.textColor = [ACDarkAppearance blueKeyDisabledTitleColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACDarkAppearance blueKeyColor];
                            self.shadowColor = [ACDarkAppearance blueKeyShadowColor];
                            self.label.textColor = [UIColor whiteColor];
                            break;
                    }
                    break;
                }
            }
            break;
        }
            
        case ACKeyAppearanceClearWhite: {
            if (self.tag == kKeyOverlayTag) {
                self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            
            self.label.textColor = [UIColor whiteColor];
            self.imageView.tintColor = [ACDarkAppearance whiteColor];
            
            self.color = [UIColor clearColor];
            self.shadowColor = [UIColor clearColor];
        }   break;
            
        case ACKeyAppearanceLight:
        default: {
            switch (self.style) {
                case ACKeyStyleLight: {
                    self.label.textColor = [UIColor blackColor];
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = [ACLightAppearance darkKeyColor];
                            self.shadowColor = [ACLightAppearance darkKeyShadowColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACLightAppearance lightKeyColor];
                            self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                            break;
                    }
                    break;
                }
                case ACKeyStyleDark: {
                    self.label.textColor = [UIColor blackColor];
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = [ACLightAppearance lightKeyColor];
                            self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                            self.imageView.tintColor = [ACLightAppearance blackColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACLightAppearance darkKeyColor];
                            self.shadowColor = [ACLightAppearance darkKeyShadowColor];
                            self.imageView.tintColor = [ACLightAppearance whiteColor];
                            break;
                    }
                    break;
                }
                case ACKeyStyleBlue: {
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = [ACLightAppearance lightKeyColor];
                            self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                            self.label.textColor = [ACLightAppearance blackColor];
                            break;
                            
                        case UIControlStateDisabled:
                            self.color = [ACLightAppearance darkKeyColor];
                            self.shadowColor = [ACLightAppearance darkKeyShadowColor];
                            self.label.textColor = [ACLightAppearance blueKeyDisabledTitleColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACLightAppearance blueKeyColor];
                            self.shadowColor = [ACLightAppearance blueKeyShadowColor];
                            self.label.textColor = [ACLightAppearance whiteColor];
                            break;
                    }
                    break;
                }
            }
            break;
        }
    }
    
    [self setNeedsDisplay];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [self drawKeyRect:rect color:self.color withShadow:self.shadowColor];
}

- (void)drawKeyRect:(CGRect)rect color:(UIColor *)color {
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
    [color setFill];
    [roundedRectanglePath fill];
}

- (void)drawShadowedKeyRect:(CGRect)rect color:(UIColor *)color withShadow:(UIColor *)shadowColor {
    CGRect shadowRect = CGRectOffset(CGRectInset(rect, 0, kKeyShadowYOffset), 0, kKeyShadowYOffset);
    
    // counter-clockwise
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    
    // bottom left 1
    [shadowPath moveToPoint:CGPointMake(0.0, shadowRect.size.height - self.cornerRadius)];
    
    // bottom left 2
    [shadowPath addCurveToPoint:CGPointMake(self.cornerRadius, shadowRect.size.height)
                  controlPoint1:CGPointMake(0.0, shadowRect.size.height - self.cornerRadius / 2)
                  controlPoint2:CGPointMake(self.cornerRadius / 2, shadowRect.size.height)];
    
    // bottom right 1
    [shadowPath addLineToPoint:CGPointMake(shadowRect.size.width - self.cornerRadius, shadowRect.size.height)];
    
    // bottom right 2
    [shadowPath addCurveToPoint:CGPointMake(shadowRect.size.width, shadowRect.size.height - self.cornerRadius)
                  controlPoint1:CGPointMake(shadowRect.size.width - self.cornerRadius / 2, shadowRect.size.height)
                  controlPoint2:CGPointMake(shadowRect.size.width, shadowRect.size.height - self.cornerRadius / 2)];
    
    // top right 1
    [shadowPath addLineToPoint:CGPointMake(shadowRect.size.width, shadowRect.size.height - self.cornerRadius - kKeyShadowYOffset)];
    
    // top right 2
    [shadowPath addCurveToPoint:CGPointMake(shadowRect.size.width - self.cornerRadius, shadowRect.size.height - kKeyShadowYOffset)
                  controlPoint1:CGPointMake(shadowRect.size.width, shadowRect.size.height - kKeyShadowYOffset - self.cornerRadius / 2)
                  controlPoint2:CGPointMake(shadowRect.size.width - self.cornerRadius / 2, shadowRect.size.height - kKeyShadowYOffset)];
    
    // top left 1
    [shadowPath addLineToPoint:CGPointMake(self.cornerRadius, shadowRect.size.height - kKeyShadowYOffset)];
    
    // top left 2
    [shadowPath addCurveToPoint:CGPointMake(0.0, shadowRect.size.height - self.cornerRadius - kKeyShadowYOffset)
                  controlPoint1:CGPointMake(self.cornerRadius / 2, shadowRect.size.height - kKeyShadowYOffset)
                  controlPoint2:CGPointMake(0.0, shadowRect.size.height - self.cornerRadius / 2 - kKeyShadowYOffset)];
    
    // bottom left 1
    [shadowPath addLineToPoint:CGPointMake(0.0, shadowRect.size.height - self.cornerRadius)];
    
    [shadowPath closePath];
    [shadowPath applyTransform:CGAffineTransformMakeTranslation(0, kKeyShadowYOffset * 2)];
    [shadowColor setFill];
    [shadowPath fill];
    
    CGRect keyRect = CGRectOffset(CGRectInset(rect, 0, kKeyShadowYOffset / 2), 0, -kKeyShadowYOffset / 2);
    [self drawKeyRect:keyRect color:color];
}

- (void)drawMarkerOnPoint:(CGPoint)point withColor:(UIColor *)color {
    CGFloat side = 2;
    UIBezierPath* markerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x-side, point.y-side, 2 * side, 2 * side)];
    
    [color setStroke];
    [markerPath stroke];
}

- (void)drawStrokeRectRect:(CGRect)rect color:(UIColor *)color andLineWidth:(CGFloat)lineWidth {
    UIBezierPath *keyPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cornerRadius];
    keyPath.lineWidth = lineWidth;
    [color setStroke];
    [keyPath stroke];
}

- (void)drawKeyRect:(CGRect)rect color:(UIColor *)color withShadow:(UIColor *)shadowColor {
    [self drawShadowedKeyRect:rect color:color withShadow:shadowColor];
}


#pragma mark - Layout

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize {
    return UILayoutFittingExpandedSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectOffset(self.bounds, 1, self.verticalShiftForLabel);
    self.imageView.frame = CGRectOffset(self.bounds, 0, kKeyImageOffsetY);
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(MAX(self.intrinsicContentSize.width, size.width), MAX(self.intrinsicContentSize.height, size.height));
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(20.0, 20.0);
}

- (void)shiftToTop:(BOOL)toTop {
    self.verticalShiftForLabel = toTop ? kKeyLiftYAmount:kKeyLabelOffsetY;
    self.label.frame = CGRectOffset(self.bounds, 1, self.verticalShiftForLabel);
}

@end

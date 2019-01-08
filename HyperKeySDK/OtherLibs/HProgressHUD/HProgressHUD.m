//
//  HProgress.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 09.01.16.
//
//

#import "HProgressHUD.h"
#import "UIImage+Pod.h"
CGFloat const kHProgressHUDAnimationDuration = 1.0;
NSString *const kHProgressHUDAnimationKey = @"HProgressHUDAnimationKey";

@interface MBProgressHUD ()

- (void)done;
- (NSDate *)showStarted;

@end

@interface HProgressHUD ()

@property (strong, nonatomic) CABasicAnimation *animation;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation HProgressHUD

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self updateHUDToHyperkey];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self updateHUDToHyperkey];
    }
    return self;
}


#pragma mark - Override

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    return [[self class] showHUDSizeType:HProgressHUDSizeTypeSmall addedTo:view animated:animated];
}

- (void)showAnimated:(BOOL)animated {
    [super showAnimated:animated];
    
    if (![self.customView.layer animationForKey:kHProgressHUDAnimationKey]) {
        [self.customView.layer addAnimation:self.animation forKey:kHProgressHUDAnimationKey];
    }
}

- (void)done {
    [self.customView.layer removeAllAnimations];
    
    [super done];
}

- (void)updateConstraints {
    // Save Width, Height, Aspect Ratio constraint
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstItem == self) {
            // Width
            if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondItem == nil && constraint.secondAttribute == NSLayoutAttributeNotAnAttribute) {
                [constraints addObject:constraint];
            }
            // Height
            else if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.secondItem == nil && constraint.secondAttribute == NSLayoutAttributeNotAnAttribute) {
                [constraints addObject:constraint];
            }
            // Aspect Ratio
            else if (constraint.secondItem == self && ((constraint.firstAttribute == NSLayoutAttributeHeight && constraint.secondAttribute == NSLayoutAttributeWidth) || (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondAttribute == NSLayoutAttributeHeight))) {
                [constraints addObject:constraint];
            }
        }
    }
    
    [super updateConstraints];
    
    // Restore Width, Height, Aspect Ratio constraint
    for (NSLayoutConstraint *constraint in constraints) {
        if (![self.constraints containsObject:constraint]) {
            [self addConstraint:constraint];
        }
    }
}


#pragma mark - Class

+ (instancetype)showHUDSizeType:(HProgressHUDSizeType)sizeType addedTo:(UIView *)view animated:(BOOL)animated {
    HProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.sizeType = sizeType;
    [hud updateHUDToHyperkey];
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}


#pragma mark - Property

- (void)setSizeType:(HProgressHUDSizeType)sizeType {
    if (_sizeType != sizeType) {
        _sizeType = sizeType;
        
        [self updateIndicatorView];
    }
}

- (BOOL)isAnimating {
    return ([super showStarted] != nil);
}


#pragma mark - Private

- (void)updateHUDToHyperkey {
    self.mode = MBProgressHUDModeCustomView;
    self.margin = 0;
    self.bezelView.layer.cornerRadius = 0;
    self.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    self.bezelView.color = [UIColor clearColor];
    
    self.customView = [[UIImageView alloc] initWithImage:[self imageForCurrentSizeType]];
    self.customView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGSize size = [self sizeForCurrentSizeType];
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.customView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.width];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.customView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:size.height];
    [self.customView addConstraint:self.widthConstraint];
    [self.customView addConstraint:self.heightConstraint];
    [self layoutIfNeeded];
    
    if (!self.animation) {
        self.animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        self.animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        self.animation.duration = kHProgressHUDAnimationDuration;
        self.animation.cumulative = YES;
        self.animation.repeatCount = CGFLOAT_MAX;
    }
}

- (void)updateIndicatorView {
    if ([self.customView isKindOfClass:[UIImageView class]]) {
        ((UIImageView *)self.customView).image = [self imageForCurrentSizeType];
    }
    
    CGSize size = [self sizeForCurrentSizeType];
    self.widthConstraint.constant = size.width;
    self.heightConstraint.constant = size.height;
    [self layoutIfNeeded];
}

- (CGSize)sizeForCurrentSizeType {
    CGFloat size = 0;
    
    switch (self.sizeType) {
        case HProgressHUDSizeTypeSmall:
        case HProgressHUDSizeTypeSmallWhite:
            size = 30;
            break;
            
        case HProgressHUDSizeTypeBig:
        case HProgressHUDSizeTypeBigWhite:
            size = 50;
            break;
            
        case HProgressHUDSizeTypeSystemSmall:
            size = 20;
            break;
    }
    
    return CGSizeMake(size, size);
}

- (UIImage *)imageForCurrentSizeType {
    NSString *imageName = nil;
    
    switch (self.sizeType) {
        case HProgressHUDSizeTypeSmall:
        case HProgressHUDSizeTypeBig:
        case HProgressHUDSizeTypeSystemSmall:
            imageName = @"icon_progress";
            break;
            
        case HProgressHUDSizeTypeSmallWhite:
        case HProgressHUDSizeTypeBigWhite:
            imageName = @"icon_progress_w";
            break;
    }
    return [UIImage imageNamedPod:imageName];
}

@end

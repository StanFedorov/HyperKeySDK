//
//  ACLockActivatedKey.m
//  Better Word
//
//  Created by Sergey Vinogradov on 24.03.16.
//
//

#import "ACLockActivatedKey.h"

#import "ACLightAppearance.h"
#import "ACDarkAppearance.h"
#import "Macroses.h"

@interface ACLockActivatedKey ()

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *shadowColor;

- (void)updateState;

@end

@implementation ACLockActivatedKey

- (instancetype)initWithKeyStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance {
    self = [super initWithKeyStyle:style appearance:appearance];
    if (self) {
        self.locked = NO;
        self.selected = NO;
    }
    return self;
}

- (void)setActiveImage:(UIImage *)imageActive andInactiveImage:(UIImage *)imageNonactive {
    self.imageActive = imageActive;
    self.imageInactive = imageNonactive;
    
    [self updateState];
}

- (void)setImage:(UIImage *)image{
    [super setImage:image];
    
    self.imageView.tintColor = [UIColor blackColor];
}

- (void)updateState {
    switch (self.appearance) {
        case ACKeyAppearanceDark: {
            if (self.isLocked) {
                self.color = [ACDarkAppearance ultraLightKeyColor];
                self.shadowColor = [ACDarkAppearance ultraLightKeyShadowColor];
                self.imageView.image = self.lockImage;
                self.tintColor = [UIColor blackColor];
            } else {
                switch (self.state) {
                    case UIControlStateHighlighted:
                    case UIControlStateSelected: {
                        self.color = [ACDarkAppearance ultraLightKeyColor];
                        self.shadowColor = [ACDarkAppearance ultraLightKeyShadowColor];
                        self.imageView.image = [self.imageActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }   break;
                        
                    case UIControlStateNormal:
                    default: {
                        self.color = [ACDarkAppearance darkKeyColor];
                        self.shadowColor = [ACDarkAppearance darkKeyShadowColor];
                        self.imageView.image = [self.imageInactive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }   break;
                }
            }
        }   break;
            
        case ACKeyAppearanceClearWhite: {
            if (self.isLocked) {
                self.imageView.image = [self.lockImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            } else {
                switch (self.state) {
                    case UIControlStateHighlighted:
                    case UIControlStateSelected: {
                        self.imageView.image = [self.imageActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }   break;
                        
                    case UIControlStateNormal:
                    default: {
                        self.imageView.image = [self.imageInactive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }   break;
                }
            }

            self.color = [UIColor clearColor];
            self.shadowColor = [UIColor clearColor];
        }   break;
            
        case ACKeyAppearanceLight:
        default: {
            if (self.isLocked) {
                self.color = [ACLightAppearance lightKeyColor];
                self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                self.imageView.image = self.lockImage;
                self.tintColor = [UIColor blackColor];
            } else {
                switch (self.state) {
                    case UIControlStateHighlighted:
                    case UIControlStateSelected: {
                        self.color = [ACLightAppearance lightKeyColor];
                        self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                        self.imageView.image = [self.imageActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }   break;
                        
                    case UIControlStateNormal:
                    default: {
                        self.color = [ACLightAppearance darkKeyColor];
                        self.shadowColor = [ACLightAppearance darkKeyShadowColor];
                        self.imageView.image = [self.imageInactive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    }   break;
                }
            }
        }   break;
    }
    
    [super setNeedsDisplay];
}

@end

//
//  ACActivatedKey.m
//  Better Word
//
//  Created by Sergey Vinogradov on 24.03.16.
//
//

#import "ACActivatedKey.h"

#import "ACLightAppearance.h"
#import "ACDarkAppearance.h"
#import "Macroses.h"

@interface ACActivatedKey ()

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *shadowColor;

- (void)updateState;

@end

@implementation ACActivatedKey

@synthesize style = _style;

- (void)setActiveImage:(UIImage *)imageActive andInactiveImage:(UIImage *)imageNonactive {
    self.imageActive = imageActive;
    self.imageInactive = imageNonactive;
    [self updateState];
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    self.imageView.tintColor = [UIColor blackColor];
}

- (instancetype)init {
    self = [super initWithKeyStyle:ACKeyStyleDark appearance:ACKeyAppearanceLight];
    if (self) {
        self.selected = NO;
    }
    return self;
}

- (instancetype)initWithKeyStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance {
    return [self init];
}

- (void)updateState {
    switch (self.appearance) {
        case ACKeyAppearanceDark: {
            switch (self.style) {
                case ACKeyStyleLight: {
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
                            break;
                            
                        case UIControlStateDisabled:
                            self.color = [ACDarkAppearance darkKeyColor];
                            self.shadowColor = [ACDarkAppearance darkKeyShadowColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACDarkAppearance blueKeyColor];
                            self.shadowColor = [ACDarkAppearance blueKeyShadowColor];
                            break;
                    }
                    break;
                }
            }
            break;
        }
            
        case ACKeyAppearanceClearWhite: {
            self.color = [UIColor clearColor];
            self.shadowColor = [UIColor clearColor];
        }   break;
            
        case ACKeyAppearanceLight:
        default: {
            switch (self.style) {
                case ACKeyStyleLight: {
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
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = [ACLightAppearance lightKeyColor];
                            self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACLightAppearance darkKeyColor];
                            self.shadowColor = [ACLightAppearance darkKeyShadowColor];
                            break;
                    }
                    break;
                }
                case ACKeyStyleBlue: {
                    switch (self.state) {
                        case UIControlStateHighlighted:
                            self.color = [ACLightAppearance lightKeyColor];
                            self.shadowColor = [ACLightAppearance lightKeyShadowColor];
                            break;
                            
                        case UIControlStateDisabled:
                            self.color = [ACLightAppearance darkKeyColor];
                            self.shadowColor = [ACLightAppearance darkKeyShadowColor];
                            break;
                            
                        case UIControlStateNormal:
                        default:
                            self.color = [ACLightAppearance blueKeyColor];
                            self.shadowColor = [ACLightAppearance blueKeyShadowColor];
                            break;
                    }
                    break;
                }
            }
            break;
        }
    }
    
    switch (self.state) {
        case UIControlStateSelected:
        case UIControlStateHighlighted:
            self.imageView.image = [self.imageActive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            break;
            
        case UIControlStateNormal:
        default:
            self.imageView.image = [self.imageInactive imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            break;
    }
    
    [self setNeedsDisplay];

}

@end

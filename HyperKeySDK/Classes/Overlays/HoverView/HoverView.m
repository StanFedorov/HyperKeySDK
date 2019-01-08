//
//  HoverView.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 03.11.15.
//
//

#import "HoverView.h"
#import <FLAnimatedImage/FLAnimatedImage.h>

#import "Config.h"
#import "Masonry.h"
#import "UIImage+Pod.h"


@interface HoverView ()

@property (strong, nonatomic) FLAnimatedImageView *rainbowView;
@property (assign, nonatomic) HoverViewType type;

@end

@implementation HoverView

- (IBAction)goToContainer:(id)sender {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    if (![userDefaults boolForKey:kUserDefaultsContainerTutotialShowedBefore]) {
        [userDefaults setBool:YES forKey:kUserDefaultsContainerTutotialShowedBefore];
        [userDefaults synchronize];
    }
    
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        NSLog(@"responder = %@", responder);
        if([responder respondsToSelector:@selector(openURL:)] == YES) {
            NSString *urlString = @"hyperkeyapp://";
            
            if (self.goToContainerButton.tag == HoverViewTypeNoLocationAccess) {
                urlString = [urlString stringByAppendingString:@"location"];
            } else {
                switch (self.seletedSocialType) {
                    case HoverViewSocialTypeFacebook:
                        urlString = [urlString stringByAppendingString:@"facebook"];
                        break;
                        
                    case HoverViewSocialTypeInstagram:
                        urlString = [urlString stringByAppendingString:@"instagram"];
                        break;
                        
                    case HoverViewSocialTypeDropBox:
                        urlString = [urlString stringByAppendingString:@"dropbox"];
                        break;
                        
                    case HoverViewSocialTypeGoogleDrive:
                        urlString = [urlString stringByAppendingString:@"googledrive"];
                        break;
                        
                    case HoverViewSocialTypeTwitch:
                        urlString = [urlString stringByAppendingString:@"twitch"];
                        break;
                        
                    default:
                        break;
                }
            }
            
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:urlString]];
        }
    }
}

- (void)resetRainbowStripe {
    [self.rainbowView stopAnimating];
    [self.rainbowView removeFromSuperview];
    
    CGRect frame = self.frame;
    self.rainbowView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rainbowStripe" ofType:@"gif"]]];
    self.rainbowView.animatedImage = image;
    
    [self insertSubview:self.rainbowView belowSubview:self.topLabel];
    [self.rainbowView startAnimating];
    self.rainbowView.userInteractionEnabled = YES;
}

- (void)layoutSubviews {
    CGRect frame = self.frame;
    
    [self.rainbowView setFrame:frame];
}

- (void)setupViewByType:(HoverViewType)viewType {
    self.type = viewType;
    
    [self resetRainbowStripe];
    
    switch (viewType) {
        case HoverViewTypeNoAuthorized: {
            self.iconImageView.image = nil;
            self.iconImageView.hidden = YES;
            
            self.topLabel.hidden = NO;
            self.topLabel.text = @"Authorization Required";
            
            self.descriptionLabel.hidden = YES;
            
            self.topLabel.hidden = YES;
            self.needAuthorizeLabel.hidden = NO;
            self.goToContainerButton.hidden = NO;
            self.goToContainerButton.layer.cornerRadius = 5.0;
            self.goToContainerButton.layer.masksToBounds = YES;
            
            NSString *socialTypeString = nil;
            switch (self.seletedSocialType) {
                case HoverViewSocialTypeFacebook:
                    socialTypeString = @"Facebook";
                    break;
                    
                case HoverViewSocialTypeInstagram:
                    socialTypeString = @"Instagram";
                    break;
                    
                case HoverViewSocialTypeDropBox:
                    socialTypeString = @"Dropbox";
                    break;
                    
                case HoverViewSocialTypeGoogleDrive:
                    socialTypeString = @"Google Drive";
                    break;
                    
                case HoverViewSocialTypeTwitch:
                    socialTypeString = @"Twitch";
                    break;
                    
                default:
                    break;
            }
            self.needAuthorizeLabel.text = [NSString stringWithFormat:@"%@ requires your authorization\nto connect with Hyperkey", socialTypeString];
        }   break;
            
        case HoverViewTypeNoInternet:
            self.iconImageView.image = [UIImage imageNamedPod:@"no_connection.png"];
            
            self.topLabel.hidden = NO;
            self.topLabel.text = @"No Internet Connection";
            
            self.descriptionLabel.text = @"Please Check Your\nInternet Connection";
            self.descriptionLabel.textColor = [UIColor whiteColor];
            
            self.topLabel.hidden = NO;
            self.needAuthorizeLabel.hidden = YES;
            self.goToContainerButton.hidden = YES;
            break;
            
        case HoverViewTypeNoResults:
            self.iconImageView.image = [UIImage imageNamedPod:@"cancel.png"];
            
            self.topLabel.hidden = YES;
            self.topTextConstraint.constant = -35.0;
            
            self.descriptionLabel.text = @"No Search Results";
            self.descriptionLabel.textColor = [UIColor whiteColor];
            
            self.needAuthorizeLabel.hidden = YES;
            self.goToContainerButton.hidden = YES;
            break;
            
        case HoverViewTypeNoAccess:
            self.iconImageView.image = [UIImage imageNamedPod:@"unlock_filled.png"];
            
            self.topLabel.hidden = NO;
            self.topLabel.text = @"Hyperkey requires Full Access";
            
            self.descriptionLabel.text = @"Please go to\nSettings > General > Keyboard\n> Keyboards > Hyperkey";
            self.descriptionLabel.textColor = [UIColor whiteColor];
            
            self.topLabel.hidden = NO;
            self.needAuthorizeLabel.hidden = YES;
            self.goToContainerButton.hidden = YES;
            break;
            
        case HoverViewTypeNoLocationAccess:
            [self setupHoverViewForNoLocationAccess];
            break;
            
        default:
            break;
    }
}

- (void)stopAnimation {
    [self.rainbowView stopAnimating];
    [self.rainbowView removeFromSuperview];
    self.rainbowView = nil;
}

- (void)setupHoverViewForNoLocationAccess {
    UIImageView *backgr = [[UIImageView alloc] initWithFrame:self.bounds];
    backgr.contentMode = UIViewContentModeScaleAspectFill;
    [backgr setImage:[UIImage imageNamedPod:@"allow_location_background"]];
    [self addSubview:backgr];
    [self sendSubviewToBack:backgr];
    
    [backgr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.topLabel.hidden = YES;
    self.descriptionLabel.hidden = YES;
    self.iconImageView.hidden = YES;
    
    self.needAuthorizeLabel.text = @"You need to allow geolocation";
    
    [self.goToContainerButton setTitle:@"Allow Geolocation" forState:UIControlStateNormal];
    self.goToContainerButton.layer.cornerRadius = 6;
    self.goToContainerButton.layer.masksToBounds = YES;
    self.goToContainerButton.clipsToBounds = YES;
    self.goToContainerButton.tag = HoverViewTypeNoLocationAccess;
}

- (void)hideNoLocationAccessView:(UIButton *)sender {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y += frame.size.height;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.type == HoverViewTypeNoAccess) {
        BOOL shouldOpenSettings = YES;
        
        for (UITouch *touch in touches) {
            if ([touch.view isEqual:self.rainbowView]) {
                shouldOpenSettings = NO;
                break;
            }
        }
        
        if (shouldOpenSettings) {
            UIResponder *responder = self;
            while ((responder = [responder nextResponder]) != nil) {
                NSLog(@"responder = %@", responder);
                if([responder respondsToSelector:@selector(openURL:)]) {
                    [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }

            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(userTapEmptySpace)]) {
        [self.delegate userTapEmptySpace];
    }
}

@end

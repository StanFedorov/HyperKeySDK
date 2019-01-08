//
//  HoverView.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 03.11.15.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HoverViewType) {
    HoverViewTypeNoAuthorized,
    HoverViewTypeNoInternet,
    HoverViewTypeNoResults,
    HoverViewTypeNoAccess,
    HoverViewTypeNoLocationAccess
};

typedef NS_ENUM(NSInteger, HoverViewSocialType) {
    HoverViewSocialTypeFacebook,
    HoverViewSocialTypeInstagram,
    HoverViewSocialTypeDropBox,
    HoverViewSocialTypeGoogleDrive,
    HoverViewSocialTypeTwitch
};

@protocol HoverViewShowHideDelegate <NSObject>

@optional
- (void)userTapEmptySpace;

@end

@interface HoverView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *needAuthorizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToContainerButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTextConstraint;

@property (assign, nonatomic) HoverViewSocialType seletedSocialType;
@property (weak, nonatomic) id<HoverViewShowHideDelegate> delegate;

- (void)setupViewByType:(HoverViewType)viewType;
- (void)stopAnimation;

@end

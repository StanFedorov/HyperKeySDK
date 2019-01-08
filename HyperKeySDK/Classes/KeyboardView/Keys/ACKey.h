//
//  ACKey.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/17/14.
//
//

#import <UIKit/UIKit.h>

extern CGFloat const kKeyPadPortraitTitleFontSize;
extern CGFloat const kKeyPadLandscapeTitleFontSize;

typedef NS_ENUM(NSInteger, ACKeyAppearance) {
    ACKeyAppearanceLight,
    ACKeyAppearanceDark,
    ACKeyAppearanceClearWhite
};

typedef NS_ENUM(NSInteger, ACKeyStyle) {
    ACKeyStyleLight,
    ACKeyStyleDark,
    ACKeyStyleBlue,
};

@interface ACKey : UIControl

@property (assign, nonatomic, setter = setKeyStyle:) ACKeyStyle style;
@property (assign, nonatomic) ACKeyAppearance appearance;

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) UIFont *titleFont;

@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) BOOL needHighlighting;

+ (instancetype)keyWithStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance;
+ (instancetype)keyWithStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance image:(UIImage *)image;
+ (instancetype)keyWithStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance title:(NSString *)title;

- (instancetype)initWithKeyStyle:(ACKeyStyle)style appearance:(ACKeyAppearance)appearance;
- (void)shiftToTop:(BOOL)toTop;

@end

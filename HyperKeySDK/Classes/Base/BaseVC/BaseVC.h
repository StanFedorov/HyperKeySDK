//
//  testVC.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 06.10.15.
//
//

#import <UIKit/UIKit.h>

#import "HoverView.h"
#import "ReachabilityManager.h"
#import "ActionView.h"
#import "Config.h"
#import "MInsertData.h"
#import "KeyboardViewControllerProtocolList.h"
#import "ThemeChangesResponderProtocol.h"

@class FourthTutorialView;

@protocol UITextFieldIndirectDelegate <NSObject>

@optional
// Because we return NO for textFieldShouldBeginEditing:
- (void)textDidChangedForTextField:(UITextField *)textField;
- (UITextField *)forceFindSearchTextField;

@end

extern NSString *const kSearchFieldDidTaped;
extern NSString *const kSearchFieldDidEndEditing;

extern CGFloat const kSeeThroughSearchBarContentTopOffset;

@interface BaseVC : UIViewController <UITextFieldDelegate, UITextFieldIndirectDelegate, HoverViewShowHideDelegate>

@property (weak, nonatomic) IBOutlet UIButton *iconButton;
@property (weak, nonatomic) id<KeyboardContainerDelegate> delegate;

@property (strong, nonatomic) UITextField *searchTextField;
@property (weak, nonatomic) FourthTutorialView *fourthTutorialView;
@property (strong, nonatomic) HoverView *hoverView;
@property (assign, nonatomic) FeatureType featureType;

@property (assign, nonatomic) BOOL shouldReloadInfo;
@property (assign, nonatomic) BOOL requireFullScreen;
@property (assign, nonatomic, readonly) BOOL actionAnimated;

- (void)setFeatureTitle:(NSString *)title dataSource:(NSString *)dataSource;
- (void)lookForSearchField;

// Remove insertBranchLinkFromMInsertData and MInsertData after 01.03.2017 if Branch not used
- (void)insertBranchLinkFromMInsertData:(MInsertData *)insertData completion:(void (^)(NSString *link))completion;
- (void)insertLinkWithURLString:(NSString *)urlString title:(NSString *)title featureType:(FeatureType)featureType completion:(void (^)(NSString *link))completion;
- (void)insertLinkWithURLString:(NSString *)urlString title:(NSString *)title featureType:(FeatureType)featureType;

- (void)showNoResultHoverViewAboveSubview:(UIView *)subview;
- (void)hideNoResultHoverView;
- (void)setupHoverViewByType:(HoverViewType)hoverType;
- (void)hideHoverView;
- (void)hideOverlayView;
- (void)showFourthTutorialWithObjectName:(NSString *)objectName;

- (void)addActionAnimationToView:(UIView *)view type:(ActionViewType)type;
- (void)addActionAnimationToView:(UIView *)view type:(ActionViewType)type options:(ActionViewOptions)options;
- (void)addActionAnimationToView:(UIView *)view contentView:(UIView *)contentView type:(ActionViewType)type options:(ActionViewOptions)option;
- (void)updateActionAnimationProgress:(CGFloat)progress;
- (void)removeActionAnimation;

@end

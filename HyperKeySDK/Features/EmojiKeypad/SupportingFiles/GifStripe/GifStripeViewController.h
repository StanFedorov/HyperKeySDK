//
//  GifStripeViewController.h
//  Better Word
//
//  Created by Sergey Vinogradov on 11.07.17.
//  Copyright © 2017 Hyperkey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "BaseVC.h"

@protocol GifStripeSelectionResponder <NSObject>

- (void)gifImageDidSelected;

@optional
// double inheritance from BaseVC implementation
- (void)addActionAnimationToView:(UIView *)view type:(ActionViewType)type;
- (void)addActionAnimationToView:(UIView *)view type:(ActionViewType)type options:(ActionViewOptions)options;
- (void)addActionAnimationToView:(UIView *)view contentView:(UIView *)contentView type:(ActionViewType)type options:(ActionViewOptions)option;
- (void)updateActionAnimationProgress:(CGFloat)progress;
- (void)removeActionAnimation;

@end

@interface GifStripeViewController : UIViewController <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet id <GifStripeSelectionResponder> delegate;

/**
 *	Direct set string for finding gifs. Can be used only if observe 
 *  of kKeyboardNotificationActionUpdateText isn't enought
 */
- (void)updateContentForString:(NSString *)string;

@end

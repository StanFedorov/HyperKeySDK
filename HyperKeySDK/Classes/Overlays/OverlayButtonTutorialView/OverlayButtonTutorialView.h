//
//  LogoButtonTutorialView.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 12.01.16.
//
//

#import <UIKit/UIKit.h>

#import "ACKey.h"

@protocol OverlayButtonTutorialViewDelegate <NSObject>

@optional
- (void)overlayButtonTutorialViewDidActionOverlay;
- (void)overlayButtonTutorialViewDidActionSwipe;

@end

@interface OverlayButtonTutorialView : UIView

@property (weak, nonatomic) id<OverlayButtonTutorialViewDelegate> delegate;
@property (strong, nonatomic) ACKey *overlayButton;

@end

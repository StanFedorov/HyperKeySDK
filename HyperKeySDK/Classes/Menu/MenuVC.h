//
//  MenuVC.h
//  
//
//  Created by Oleg Mytsouda on 05.10.15.
//
//

#import <UIKit/UIKit.h>
#import "KeyboardFeaturesManager.h"
#import "KeyboardViewControllerProtocolList.h"
#import "ThemeChangesResponderProtocol.h"

extern NSString *const kNotificationMenuGetAnyAction;
extern NSString *const kNotificationKeyboardBlock;

@protocol MenuItemPushDelegate <NSObject>

- (void)switchToFeature:(KeyboardFeature *)item;

@end

@interface MenuVC : UIViewController <ThemeChangesResponderProtocol>

@property (weak, nonatomic) id<MenuItemPushDelegate, KeyboardContainerDelegate, DirectInsertAndDeleteDelegate> delegate;
@property (assign, nonatomic) BOOL isKeyboardBlockedByTutorial;

- (void)setCoveredByHover:(BOOL)needToBeCovered;

@end

//
//  ACKeyboardViewController.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/16/14.
//  Copyright (c) 2014 Arnaud Coomans. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardFeature.h"

@interface HKKeyboardViewController : UIInputViewController
- (void)switchToFeature:(KeyboardFeature *)item;
- (void)switchToFeatureFromApps:(KeyboardFeature*)item;
- (void)fixKb;
@end

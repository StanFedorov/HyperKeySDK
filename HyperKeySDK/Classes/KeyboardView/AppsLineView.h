//
//  AppsLineView.h
//  BetterWord
//
//  Created by Stanislav Fedorov on 05.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeChangesResponderProtocol.h"
#import "HKKeyboardViewController.h"

@interface AppsLineView : UIView <ThemeChangesResponderProtocol>
- (void) initApps;
@property (strong,nonatomic) HKKeyboardViewController *keyboardViewController;
@property (weak, nonatomic) IBOutlet UITextField *search;
@end

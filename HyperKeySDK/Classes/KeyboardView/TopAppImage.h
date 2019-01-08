//
//  TopAppImage.h
//  BetterWord
//
//  Created by Stanislav Fedorov on 05.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardFeature.h"

@interface TopAppImage : UIButton
@property (strong,nonatomic) KeyboardFeature* feature;
- (void)setKeyboardFeature:(KeyboardFeature *)feature;

@end

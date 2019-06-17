//
//  SearchViewController.h
//  BetterWord
//
//  Created by Stanislav Fedorov on 11/05/2019.
//  Copyright © 2019 Hyperkey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "HKKeyboardViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchViewController : BaseVC
@property (nonatomic,strong) NSString *searchQuery;
@property (strong,nonatomic) HKKeyboardViewController *keyboardViewController;
@end

NS_ASSUME_NONNULL_END

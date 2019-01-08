//
//  CamFindTableViewCell.h
//  BetterWordKeyboard
//
//  Created by Stanislav Fedorov on 07.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CamFindTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UIView *imageOverlay;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *itemDesc;
@property (weak, nonatomic) IBOutlet UILabel *itemUrl;
@end

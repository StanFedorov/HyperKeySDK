//
//  YelpCell.h
//  Better Word
//
//  Created by Oleg Mytsouda on 18.10.15.
//  Copyright © 2015 Oleg Mytsouda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YelpCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *miLabel;
@property (weak, nonatomic) IBOutlet UIImageView *rateImageView;
@property (weak, nonatomic) IBOutlet UILabel *adresLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UIView *hoverView;

@end

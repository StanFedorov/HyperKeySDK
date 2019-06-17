//
//  YelpCell.h
//  Better Word
//
//  Created by Oleg Mytsouda on 18.10.15.
//  Copyright © 2015 Oleg Mytsouda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YelpCellSmall : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

//
//  YoutubeCell.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import <UIKit/UIKit.h>
#import "HProgressHUD.h"
#import "YoutubeModel.h"

@interface YoutubeCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *imageContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *trackLengthLabel;
@property (weak, nonatomic) IBOutlet HProgressHUD *indicatorView;

+ (CGSize)cellSizeWithSectionInsets:(UIEdgeInsets)inset andCellSpacing:(NSInteger)space;

@end

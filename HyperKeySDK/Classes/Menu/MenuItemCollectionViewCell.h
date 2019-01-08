//
//  MenuItemCollectionViewCell.h
//  Better Word
//
//  Created by Sergey Vinogradov on 19.02.16.
//
//

#import <UIKit/UIKit.h>

@interface MenuItemCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) BOOL isNoneFeature;

- (void)startQuivering;
- (void)stopQuivering;

@end

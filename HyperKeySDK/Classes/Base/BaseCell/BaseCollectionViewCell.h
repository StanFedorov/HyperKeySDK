//
//  BaseCollectionViewCell.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 07.11.16.
//
//

#import <UIKit/UIKit.h>

@protocol BaseCollectionViewCellDelegate;

@interface BaseCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id<BaseCollectionViewCellDelegate> delegate;

- (void)showReportButton;
- (void)hideReportButton;

@end

@protocol BaseCollectionViewCellDelegate <NSObject>

@optional
- (void)baseCollectionViewCellDidReport:(BaseCollectionViewCell *)cell;

@end

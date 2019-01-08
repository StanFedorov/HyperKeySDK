//
//  PhotoAlbumsCell.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import <UIKit/UIKit.h>
#import "HProgressHUD.h"

@protocol PhotoAlbumsCellDelegate;

@interface PhotoAlbumsCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet HProgressHUD *indicatorView;
@property (copy, nonatomic) NSString *representedAssetIdentifier;
@property (weak, nonatomic) id<PhotoAlbumsCellDelegate> delegate;

- (void)setImage:(UIImage *)image animated:(BOOL)animated;

@end

@protocol PhotoAlbumsCellDelegate <NSObject>

@optional
- (void)photoAlbumsCellDidEdit:(PhotoAlbumsCell *)photoAlbumsCell;

@end

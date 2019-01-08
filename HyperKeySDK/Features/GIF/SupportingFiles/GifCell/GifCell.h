//
//  GifCell.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "HProgressHUD.h"
#import "BaseCollectionViewCell.h"

@interface GifCell : BaseCollectionViewCell

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *gifImageView;
@property (weak, nonatomic) IBOutlet HProgressHUD *progressView;

- (void)updateBackgroundRandomColor:(BOOL)isRandom;

@end

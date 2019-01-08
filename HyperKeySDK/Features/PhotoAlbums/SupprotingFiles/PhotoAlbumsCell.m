//
//  PhotoAlbumsCell.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "PhotoAlbumsCell.h"

@interface PhotoAlbumsCell ()

@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation PhotoAlbumsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

#pragma mark - Setup cell

- (void)setup {
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.drawsAsynchronously = YES;
    
    self.imageView.layer.shouldRasterize = YES;
    self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.imageView.layer.drawsAsynchronously = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.editButton.hidden = YES;
    self.imageView.image = nil;
    self.representedAssetIdentifier = nil;
    
    [self.indicatorView showAnimated:NO];
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
    if (image) {
        self.imageView.image = image;
        
        if (animated) {
            self.imageView.transform = CGAffineTransformMakeScale(0, 0);
            
            [UIView animateWithDuration:0.15 animations:^{
                self.imageView.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }
        
        self.editButton.hidden = NO;
    } else {
        self.editButton.hidden = YES;
    }
}


#pragma mark - Actions

- (IBAction)actionEdit {
    if ([self.delegate respondsToSelector:@selector(photoAlbumsCellDidEdit:)]) {
        [self.delegate photoAlbumsCellDidEdit:self];
    }
}

@end

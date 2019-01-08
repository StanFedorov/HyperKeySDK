//
//  GifCategoryCollectionViewCell.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "GifCategoryCell.h"

@interface GifCategoryCell ()

@property (weak, nonatomic) IBOutlet UIView *selectedView;

@end

@implementation GifCategoryCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.selectedView.layer.cornerRadius = self.frame.size.height / 2;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.selectedView.hidden = YES;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.selectedView.hidden = !selected;
    self.titleLabel.textColor = (selected) ? [UIColor blackColor] : [UIColor darkGrayColor];
}

@end

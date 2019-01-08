//
//  YoutubeCell.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "YoutubeCell.h"

#import "Macroses.h"

CGFloat const kYoutubeCellCellIFooterSize = 38;
CGFloat const kYoutubeCellCellImagesShrinkConst = 50;

@implementation YoutubeCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.trackNameLabel.text = nil;
    self.trackLengthLabel.text = nil;
    self.imageView.image = nil;
}


#pragma mark - Class

+ (CGSize)cellSizeWithSectionInsets:(UIEdgeInsets)inset andCellSpacing:(NSInteger)space {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    CGFloat width = MIN(screenSize.width, screenSize.height);
    
    if (IS_IPHONE) {
        width = (width - inset.left - inset.right - space) / 2;
    } else {
        width = (width - inset.left - inset.right - 2 * space) / 3;
    }
#if DEBUG == 1 || BETA == 1
    NSLog(@"\n\nyoutube cell size = %@\n\n", NSStringFromCGSize(CGSizeMake(width, width + kYoutubeCellCellIFooterSize - kYoutubeCellCellImagesShrinkConst)));
#endif

    return CGSizeMake(width, width + kYoutubeCellCellIFooterSize - kYoutubeCellCellImagesShrinkConst);
}

@end

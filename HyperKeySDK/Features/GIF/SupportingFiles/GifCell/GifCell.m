//
//  GifCell.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "GifCell.h"
#import "Macroses.h"

@implementation GifCell

+ (UIColor *)randomColor {
    int index = arc4random() % 5;
    
    switch (index) {
        default:
        case 1:
            return RGB(49, 145, 255);
            
        case 2:
            return RGB(254, 243, 90);
            
        case 3:
            return RGB(15, 230, 204);
            
        case 4:
            return RGB(231, 70, 182);
            
        case 5:
            return RGB(96, 87, 255);
    }
}

- (void)updateBackgroundRandomColor:(BOOL)isRandom {
    self.gifImageView.backgroundColor = isRandom ? [[self class] randomColor] : [UIColor clearColor];
}

@end

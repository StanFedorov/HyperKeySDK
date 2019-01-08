//
//  GifRounLabel.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "GifRounLabel.h"

@implementation GifRounLabel

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.text.length > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 1.0);
        CGContextSetLineWidth(context, 1.0);
        
        CGRect textRect = [self.text boundingRectWithSize:rect.size options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: self.font} context:nil];
        
        CGFloat leftX = (rect.size.width - textRect.size.width) / 2.0f;
        CGFloat rightX = (rect.size.width + textRect.size.width) / 2.0f;
        CGFloat topY = (rect.size.height + textRect.size.height) / 2.0f + 1.0f;
        CGFloat bottomY = (rect.size.height - textRect.size.height) / 2.0f - 1.0f;
        
        CGContextMoveToPoint(context, leftX, topY);
        CGContextAddLineToPoint(context, rightX, topY);
        CGContextStrokePath(context);

        CGContextMoveToPoint(context, leftX, bottomY);
        CGContextAddLineToPoint(context, rightX, bottomY);
        CGContextStrokePath(context);
    }
}

@end

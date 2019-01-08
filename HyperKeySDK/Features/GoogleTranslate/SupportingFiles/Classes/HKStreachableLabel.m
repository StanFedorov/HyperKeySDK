//
//  HKStreachableLabel.m
//  Better Word
//
//  Created by Sergey Vinogradov on 11.01.16.
//
//

#import "HKStreachableLabel.h"

#import "HKStreachableLabel.h"

@implementation HKStreachableLabel

- (void)setText:(NSString *)text {
    self.preferredSize = [self sizeForText:text];
    
    if (self.delegate) {
        [self.delegate presetWidth:self.preferredSize.width];
    }
    
    [super setText:text];
}

- (CGSize)sizeForText:(NSString *)text {
    CGRect aFrame = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    return aFrame.size;
}

@end

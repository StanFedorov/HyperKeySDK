//
//  EmojiKeypadCollectionViewCell.m
//  Better Word
//
//  Created by Sergey Vinogradov on 30.03.16.
//
//

#import "EmojiKeypadCollectionViewCell.h"

@interface EmojiKeypadCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation EmojiKeypadCollectionViewCell

- (void)setString:(NSString *)text {
    self.label.text = text;
}

@end

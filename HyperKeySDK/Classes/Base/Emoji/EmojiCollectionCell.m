//
//  EmojiCollectionCell.m
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import "EmojiCollectionCell.h"

@implementation EmojiCollectionCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.text.text = @"";
}

@end

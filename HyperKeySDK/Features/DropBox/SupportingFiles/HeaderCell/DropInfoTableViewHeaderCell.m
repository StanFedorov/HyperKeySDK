//
//  DropInfoTableViewHeaderCell.m
//  Better Word
//
//  Created by Sergey Vinogradov on 16.03.16.
//
//

#import "DropInfoTableViewHeaderCell.h"

@interface DropInfoTableViewHeaderCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DropInfoTableViewHeaderCell

- (void)setTitle:(NSString*)title {
    _titleLabel.text = title;
}

@end

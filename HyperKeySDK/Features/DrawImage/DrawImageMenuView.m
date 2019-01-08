//
//  DrawImageMenuView.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 23.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageMenuView.h"

#import "Macroses.h"
#import "DrawImageColorBarView.h"
#import "Masonry.h"
#import "UIColor+DrawImage.h"

CGFloat const kDrawImageMenuViewDefaultLeftRightMarign = 10;
CGFloat const kDeawImageMenuSaveButtonFontSize = 17;

@interface DrawImageMenuView () <DrawImageColorBarViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *colorBarContentView;

@property (weak, nonatomic) DrawImageColorBarView *colorBarView;

@end

@implementation DrawImageMenuView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialization];
}


#pragma mark - Initialization

- (void)initialization {
    CGFloat leftRightDefaultMarign = AUTO_SCALE(kDrawImageMenuViewDefaultLeftRightMarign);
    CGFloat leftMarign = MAX(leftRightDefaultMarign - self.undoButton.contentEdgeInsets.left, 1);
    CGFloat rigntMarign = MAX(leftRightDefaultMarign - self.saveButton.contentEdgeInsets.right, 1);
    self.layoutMargins = UIEdgeInsetsMake(0, leftMarign, 0, rigntMarign);
    
    self.colorBarView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DrawImageColorBarView class]) owner:self options:nil] firstObject];
    self.colorBarView.delegate = self;
    [self.colorBarContentView addSubview:self.colorBarView];
    [self.colorBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.saveButton.titleLabel.font = [UIFont systemFontOfSize:kDeawImageMenuSaveButtonFontSize];
    [self.saveButton setTitleColor:[UIColor drawImageTextGrayColor] forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor drawImageTextGrayDarkColor] forState:UIControlStateHighlighted];
}


#pragma mark - Actions

- (IBAction)actionUndo {
    if ([self.delegate respondsToSelector:@selector(drawImageMenuDidUndoAction)]) {
        [self.delegate drawImageMenuDidUndoAction];
    }
}

- (IBAction)actionPlay {
    if ([self.delegate respondsToSelector:@selector(drawImageMenuDidPlayAction)]) {
        [self.delegate drawImageMenuDidPlayAction];
    }
}

- (IBAction)actionSaveGif {
    if ([self.delegate respondsToSelector:@selector(drawImageMenuDidSaveGifAction)]) {
        [self.delegate drawImageMenuDidSaveGifAction];
    }
}


#pragma mark - DrawImageColorBarViewDelegate

- (void)drawImageColorBarViewDidSelectColor:(UIColor *)color {
    if ([self.delegate respondsToSelector:@selector(drawImageMenuDidSelectColor:)]) {
        [self.delegate drawImageMenuDidSelectColor:color];
    }
}

@end

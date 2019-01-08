//
//  DrawImageViewController.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 23.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageViewController.h"

#import "DrawImageView.h"
#import "Masonry.h"

@interface DrawImageViewController () <DrawImageViewDelegate>

@property (strong, nonatomic) DrawImageView *drawImageView;

@end

@implementation DrawImageViewController

#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.drawImageView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DrawImageView class]) owner:self options:nil] firstObject];
    self.drawImageView.delegate = self;
    self.drawImageView.featureType = self.featureType;
    [self.view addSubview:self.drawImageView];
    [self.drawImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}


#pragma mark - Override Custom

- (void)hideOverlayView {
    [super hideOverlayView];
    
    [self.drawImageView hideShareOverlayView];
}


#pragma mark - Actions

- (IBAction)actionDrawImage:(id)sender {
    [self.delegate functionButton:sender];
}


#pragma mark - DrawImageViewDelegate

- (void)drawImageViewDidUploadImageToURLString:(NSString *)urlString {
    if (urlString) {
        [self insertLinkWithURLString:urlString title:nil featureType:self.featureType completion:nil];
    }
}

- (void)drawImageViewDidShareImage {
    [self showFourthTutorialWithObjectName:@"Image"];
}

@end

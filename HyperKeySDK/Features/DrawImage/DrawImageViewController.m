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
#import <Photos/Photos.h>

@interface DrawImageViewController () <DrawImageViewDelegate>

@property (strong, nonatomic) DrawImageView *drawImageView;
@property (weak, nonatomic) IBOutlet UIView *noAcccessView;

@end

@implementation DrawImageViewController

#pragma mark - Override

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.drawImageView = [[[NSBundle bundleForClass:NSClassFromString(@"DrawImageView")]  loadNibNamed:NSStringFromClass([DrawImageView class]) owner:self options:nil] firstObject];
    self.drawImageView.delegate = self;
    self.drawImageView.featureType = self.featureType;
    [self.view addSubview:self.drawImageView];
    [self.drawImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkAccess];
}

- (void)checkAccess {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        self.noAcccessView.hidden = YES;
    }else {
        self.noAcccessView.hidden = NO;
        [self.view bringSubviewToFront:self.noAcccessView];
    }
}

- (IBAction)grantAccess:(id)sender {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied) {
        [self openURL:UIApplicationOpenSettingsURLString];
    }else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self checkAccess];
            });
        }];
    }
}

- (void)openURL:(NSString*)url{
    UIResponder* responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        NSLog(@"responder = %@", responder);
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:)
                            withObject:[NSURL URLWithString:url]];
        }
    }
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

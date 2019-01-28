//
//  AmazonPageViewController.m
//  Better Word
//
//  Created by Stanislav Fedorov on 12.08.2018.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "AmazonPageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AmazonPageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *itemTitle;
@property (weak, nonatomic) IBOutlet UILabel *itemSeller;
@property (weak, nonatomic) IBOutlet UILabel *itemDesc;
@property (weak, nonatomic) IBOutlet UILabel *itemPrice;
@end

@implementation AmazonPageViewController
@synthesize item;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.itemTitle.text = item[@"title"];
    self.itemSeller.text = item[@"seller"];
    self.itemPrice.text = item[@"price"];
    self.itemDesc.text = item[@"features"];
    [self.imageIcon sd_setImageWithURL:[NSURL URLWithString:item[@"image"]] placeholderImage:nil options: SDWebImageRetryFailed | SDWebImageContinueInBackground ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleBuy:(id)sender {
    [self openURL:item[@"link"]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

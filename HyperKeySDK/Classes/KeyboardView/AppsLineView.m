//
//  AppsLineView.m
//  BetterWord
//
//  Created by Stanislav Fedorov on 05.03.18.
//  Copyright © 2018 Hyperkey. All rights reserved.
//

#import "AppsLineView.h"
#import "TopAppImage.h"
#import "ScrollViewCentered.h"
#import "Macroses.h"
#import "KeyboardFeaturesManager.h"

@interface AppsLineView ()
@property (weak, nonatomic) IBOutlet UIScrollView *apps;
@property (strong, nonatomic) NSMutableArray *appsList;
@property (nonatomic) bool appsInitiated;
@end

@implementation AppsLineView
@synthesize keyboardViewController;

- (void) initApps {
    
    if(self.appsList.count == 0) {
        [self.apps.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.appsList = [NSMutableArray new];
        
        /*   TopAppImage *camFind = [[TopAppImage alloc] init];
        [camFind setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeCamFind]];
        [self.appsList addObject:camFind];
        
        TopAppImage *emoji = [[TopAppImage alloc] init];
        [emoji setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeEmojiKeypad]];
        [self.appsList addObject:emoji];
        
        TopAppImage *gif  = [[TopAppImage alloc] init];
        [gif setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeGif]];
        [self.appsList addObject:gif];
        
        TopAppImage *yelp  = [[TopAppImage alloc] init];
        [yelp setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeYelp]];
        [self.appsList addObject:yelp];
        
        TopAppImage *location = [[TopAppImage alloc] init];
        [location setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeShareLocation]];
        [self.appsList addObject:location];
        
        TopAppImage *youtube  = [[TopAppImage alloc] init];
        [youtube setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeYoutube]];
        [self.appsList addObject:youtube];
        
        TopAppImage *photos  = [[TopAppImage alloc] init];
        [photos setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypePhotoLibrary]];
        [self.appsList addObject:photos];
        
        TopAppImage *google  = [[TopAppImage alloc] init];
        [google setKeyboardFeature:[KeyboardFeature featureWithType:FeatureTypeGoogleTranslate]];
        [self.appsList addObject:google];*/
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[KeyboardFeaturesManager sharedManager].enabledItemsList];
      //  array = [[self sortAccordingToOrderFeaturesList:array] mutableCopy];

        for (KeyboardFeature *f in array) {
            TopAppImage *feature  = [[TopAppImage alloc] init];
            [feature setKeyboardFeature:f];
            [self.appsList addObject:feature];
        }
        
        
        /*  if(self.apps.contentSize.width > self.apps.frame.size.width) {
         CGFloat newContentOffsetX = (self.apps.contentSize.width-(itemPadding*2)-itemPadding-self.apps.frame.size.width) / 2;
         [self.apps setContentInset:UIEdgeInsetsMake(0, newContentOffsetX, 0, 8)];
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
         [self.apps setContentOffset:CGPointMake(0, 0) animated:YES];
         });
         }else {
         [self.apps setContentInset:UIEdgeInsetsMake(0, 8, 0, 8)];
         }*/
        float itemSize = 34;
        float itemPadding = 8;
        float topPadding = 4;
        if(IS_IPAD)
            topPadding=10;
        self.apps.contentSize = CGSizeMake(((itemSize+itemPadding) * (self.appsList.count)) - itemPadding, self.apps.frame.size.height);
        for(int i = 0; i < self.appsList.count; i++) {
            TopAppImage *item = [self.appsList objectAtIndex:i];
            if(i == 0)
                [item setFrame:CGRectMake(0, topPadding, itemSize, itemSize)];
            else
                [item setFrame:CGRectMake((itemPadding+itemSize)*i, topPadding, itemSize, itemSize)];
            [item addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.apps addSubview:item];
        }
        if(self.apps.frame.size.width > self.apps.contentSize.width) {
            CGFloat newContentOffsetX;
            newContentOffsetX = (self.apps.frame.size.width-self.apps.contentSize.width) / 2;
            [self.apps setContentInset:UIEdgeInsetsMake(0, newContentOffsetX, 0, 0)];
        }else {
            [self.apps setContentInset:UIEdgeInsetsMake(0, 8, 0, 8)];
        }
    }
}

-(void)itemClicked:(id)sender{
    TopAppImage *item = (TopAppImage*)sender;
    [self.keyboardViewController switchToFeatureFromApps:item.feature];
}



@end

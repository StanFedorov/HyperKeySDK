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
#import "UITextField+PaddingText.h"

NSString *const kLineSearchFieldEnabledKeyPath = @"enabled";
NSString *const kLineSearchFieldDidEndEditing = @"kSearchDidEndEditing";
NSString *const kLineSearchFieldDidTaped = @"kSearchFieldDidTaped";

@interface AppsLineView ()
@property (weak, nonatomic) IBOutlet UIScrollView *apps;
@property (strong, nonatomic) NSMutableArray *appsList;
@property (nonatomic) bool appsInitiated;
@end

@implementation AppsLineView
@synthesize keyboardViewController;

- (void) initApps {
    
    self.search.layer.cornerRadius = 10;
    [self.search setLeftPadding:28];
    [self.search setRightPadding:10];
    self.search.delegate = self;
    [self addTextFieldObserver];
    
    if(self.appsList.count == 0) {
        self.appsList = [NSMutableArray new];

        NSMutableArray *array = [NSMutableArray arrayWithArray:[KeyboardFeaturesManager sharedManager].enabledItemsList];
        for (KeyboardFeature *f in array) {
            TopAppImage *feature  = [[TopAppImage alloc] init];
            [feature setKeyboardFeature:f];
            [self.appsList addObject:feature];
        }
        
        float itemSize = 34;
        float itemPadding = 8;
        float topPadding = 4;
        float startPadding = 10;

        if(IS_IPAD)
            topPadding=10;
        self.apps.contentSize = CGSizeMake(startPadding + ((itemSize+itemPadding) * (self.appsList.count)) - itemPadding, self.apps.frame.size.height);
        for(int i = 0; i < self.appsList.count; i++) {
            TopAppImage *item = [self.appsList objectAtIndex:i];
            if(i == 0)
                [item setFrame:CGRectMake(startPadding, topPadding, itemSize, itemSize)];
            else
                [item setFrame:CGRectMake(startPadding + (itemPadding+itemSize)*i, topPadding, itemSize, itemSize)];
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

- (void)clearActiveIcons {
    for(TopAppImage *topItem in self.appsList){
        [topItem updateIconToDefault];
    }
}

- (void)setFeatureSelected:(KeyboardFeature*)feature {
    for(TopAppImage *topItem in self.appsList){
        if(topItem.feature == feature) {
            [topItem updateIconToSelected];
        }
    }
}

- (void)addTextFieldObserver {
    [self.search addObserver:self forKeyPath:kLineSearchFieldEnabledKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeTextFieldObsever {
    [self.search removeObserver:self forKeyPath:kLineSearchFieldEnabledKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kLineSearchFieldEnabledKeyPath] && object == self.search) {
        if (!self.search.enabled) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLineSearchFieldDidEndEditing object:nil userInfo:nil];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLineSearchFieldDidTaped object:nil userInfo:nil];
    return NO;
}


-(void)itemClicked:(id)sender{
    TopAppImage *item = (TopAppImage*)sender;
    [self.keyboardViewController switchToFeatureFromApps:item.feature];
}



@end

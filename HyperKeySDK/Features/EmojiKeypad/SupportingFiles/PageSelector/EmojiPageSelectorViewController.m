//
//  EmojiPageSelectorViewController.m
//  Better Word
//
//  Created by Sergey Vinogradov on 31.03.16.
//
//

#import "EmojiPageSelectorViewController.h"
#import "UIImage+Pod.h"

@interface EmojiPageSelectorViewController ()

@end

@implementation EmojiPageSelectorViewController

#pragma mark - Private

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSUInteger section = 0;
    for (UITouch *touch in [event allTouches]) {
        if (touch.view != self.view && [touch.view isKindOfClass:[UIImageView class]]) {
            if ([touch.view isEqual:self.sectionImageView1]) {
                section = 0;
            } else if ([touch.view isEqual:self.sectionImageView2]) {
                section = 1;
            } else if ([touch.view isEqual:self.sectionImageView3]) {
                section = 2;
            } else if ([touch.view isEqual:self.sectionImageView4]) {
                section = 3;
            } else if ([touch.view isEqual:self.sectionImageView5]) {
                section = 4;
            } else if ([touch.view isEqual:self.sectionImageView6]) {
                section = 5;
            } else if ([touch.view isEqual:self.sectionImageView7]) {
                section = 6;
            } else if ([touch.view isEqual:self.sectionImageView8]) {
                section = 7;
            } else {
                section = 8;
            }
            
            [(id<EmojiPageSelectorDelegate>)(self.delegate) setActiveSection:section];
            [self setHighlightForView:(UIImageView *)touch.view];
            break;
        }
    }
}

- (void)setHighlightForView:(UIImageView *)view {
    for (UIImageView *view in self.sectionImageViews) {
        view.highlighted = NO;
    }
    
    view.highlighted = YES;
}


#pragma mark - Public

- (void)setActiveSectionNumber:(NSUInteger)section {
    UIImageView *sectionView = nil;
    switch (section) {
        case 0:
            sectionView = self.sectionImageView1;
            break;
            
        case 1:
            sectionView = self.sectionImageView2;
            break;
            
        case 2:
            sectionView = self.sectionImageView3;
            break;
            
        case 3:
            sectionView = self.sectionImageView4;
            break;
            
        case 4:
            sectionView = self.sectionImageView5;
            break;
            
        case 5:
            sectionView = self.sectionImageView6;
            break;
            
        case 6:
            sectionView = self.sectionImageView7;
            break;
            
        case 7:
            sectionView = self.sectionImageView8;
            break;
            
        case 8:
            sectionView = self.sectionImageView9;
            break;
            
        default:
            break;
    }
    
    if (sectionView) {
        [self setHighlightForView:sectionView];
    }
}


#pragma mark - ThemeChangesResponderProtocol

- (void)setTheme:(KBTheme)theme {
    BOOL needDark = NO;
    
    self.sectionImageView1.image = [UIImage imageNamedPod:(needDark) ? @"section01_white" : @"section01"];
    self.sectionImageView2.image = [UIImage imageNamedPod:(needDark) ? @"section02_white" : @"section02"];
    self.sectionImageView3.image = [UIImage imageNamedPod:(needDark) ? @"section03_white" : @"section03"];
    self.sectionImageView4.image = [UIImage imageNamedPod:(needDark) ? @"section04_white" : @"section04"];
    self.sectionImageView5.image = [UIImage imageNamedPod:(needDark) ? @"section05_white" : @"section05"];
    self.sectionImageView6.image = [UIImage imageNamedPod:(needDark) ? @"section06_white" : @"section06"];
    self.sectionImageView7.image = [UIImage imageNamedPod:(needDark) ? @"section07_white" : @"section07"];
    self.sectionImageView8.image = [UIImage imageNamedPod:(needDark) ? @"section08_white" : @"section08"];
    self.sectionImageView9.image = [UIImage imageNamedPod:(needDark) ? @"section09_white" : @"section09"];
}

@end

//
//  KeyboardLayoutManager.m
//  Better Word
//
//  Created by Sergey Vinogradov on 13.08.16.
//
//

#import "KeyboardLayoutManager.h"
#import "Config.h"
#import "Macroses.h"
#import "KeyboardViewControllerProtocolList.h"

@interface KeyboardLayoutManager ()

@property (assign, nonatomic, readwrite) CGRect keyboardFrame;
@property (assign, nonatomic) CGSize currentSize;
@property (assign, nonatomic) BOOL gifStripeAllowed;

@end

@implementation KeyboardLayoutManager

#pragma mark - Singleton

+ (instancetype)sharedManager {
    static KeyboardLayoutManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[KeyboardLayoutManager alloc] init];
    });
    
    return _sharedManager;
}


#pragma mark - Custom setter/getter

- (void)setKeyboardHide:(BOOL)keyboardHide {
    if (self.isKeyboardHidden != keyboardHide) {
        _keyboardHide = keyboardHide;
        
        [self resetKeyboardFrame];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardWasHidden:)]) {
            [self.delegate keyboardWasHidden:self.isKeyboardHidden];
        }
    }
}

- (void)setGifStripeShow:(BOOL)gifStripeShow {
    _gifStripeShow = (self.gifStripeAllowed ? gifStripeShow : NO);
    
    [self resetKeyboardFrame];
}

- (BOOL)gifStripeAllowed {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    return [userDefaults boolForKey:kUserDefaultsSettingAllowGifStripe];
}


#pragma mark - Public

// For KeyboardViewController.view
- (CGFloat)mainViewHeight {
    CGFloat height = 0;
    
    if (IS_IPAD) {
        height = self.isPortraitOrientation ? 320 : 394;
    } else {
        if (IS_IPHONE_6 || IS_IPHONE_X) {
            // 225 + 35
            height = self.isPortraitOrientation ? 260 : 206;
        } else if (IS_IPHONE_6_PLUS || IS_IPHONE_X_MAX) {
            // 236 + 35
            height = self.isPortraitOrientation ? 271 : 214;
        } else {
            // 225 + 35
            height = self.isPortraitOrientation ? 260 : 206;
        }
    }
    
    NSLog(@"HEIGHT %@", @(height - (self.isMainViewTruncate ? [self menuHeight] : 0) + (self.gifStripeShow ? kGifStripeGeight : 0)));
    
    return height - (self.isMainViewTruncate ? [self menuHeight] : 0) + (self.gifStripeShow ? kGifStripeGeight : 0);
}

- (CGFloat)menuHeight {
    return IS_IPAD ? 54 : 44;
}

- (void)resetFrameWithSize:(CGSize)size {
    self.currentSize = size;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.portraitOrientation = (screenSize.width > screenSize.height) ? NO : YES;
    [self resetKeyboardFrame];
}

#pragma mark - Private

// For KeyboardView
- (void)resetKeyboardFrame {
    CGFloat height = 0;
    CGFloat offset = 0;
    
    if (IS_IPAD) {
        height = self.isPortraitOrientation ? 267 : 345;
        offset = 0;
    } else {
        if (IS_IPHONE_6 || IS_IPHONE_X) {
            // 225
            height = self.isPortraitOrientation ? 225 : 172;
            offset = 54;
        } else if (IS_IPHONE_6_PLUS || IS_IPHONE_X_MAX) {
            // 236
            height = self.isPortraitOrientation ? 236 : 172;
            offset = 134;
        } else {
            // 225
            height = self.isPortraitOrientation ? 225 : 172;
            offset = 54;
        }
        
    }
    
    CGRect frame = CGRectZero;
    if (self.selectedFeature.type == FeatureTypeAmazon) {
        CGFloat amazonHeight = [[UIScreen mainScreen] bounds].size.height * 0.6f;
        CGFloat sizeDiff = amazonHeight - [self mainViewHeight];
        frame.origin.y = self.isKeyboardHidden ? amazonHeight + offset : (self.isMainViewTruncate ? 0 : [self menuHeight] + sizeDiff) + (self.gifStripeShow ? kGifStripeGeight : 0);
    } else {
        frame.origin.y = self.isKeyboardHidden ? [self mainViewHeight] + offset : (self.isMainViewTruncate ? 0 : [self menuHeight]) + (self.gifStripeShow ? kGifStripeGeight : 0);
    }
    
    frame.size.width = self.currentSize.width;
    frame.size.height = height;
    self.keyboardFrame = frame;
}

@end

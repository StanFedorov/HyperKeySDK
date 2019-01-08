//
//  DrawImageConfig.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 25.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageConfig.h"

#pragma mark - Draw

NSTimeInterval const kDrawImageUndoImagesCount = 10;
NSInteger const kDrawImagePixelsStep = 2;
CGFloat const kDrawImageLineMinWidth = 3;
CGFloat const kDrawImageLineMaxWidth = 15;


#pragma mark - Menu

CGFloat const kDrawImageShowHideMenuAnimationDuration = 0.3;
CGFloat const kDrawImageShowMenuAnimationDelay = 0.5;


#pragma mark - Notification

CGFloat const kDrawImageShowOverlayAnimationDuration = 0.3;
CGFloat const kDrawImageShowOverlayAnimationDelay = 1.5;
CGFloat const kDrawImagePasteOveralyAnimationDuration = 0.3;
CGFloat const kDrawImagePasteOverlayOffsetY = 10;
//
//  DrawImageColorBarView.h
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 24.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawImageColorBarViewDelegate;

@interface DrawImageColorBarView : UIView

@property (weak, nonatomic) id<DrawImageColorBarViewDelegate> delegate;

@property (strong, nonatomic) UIColor *color;

@end

@protocol DrawImageColorBarViewDelegate <NSObject>

@optional
- (void)drawImageColorBarViewDidSelectColor:(UIColor *)color;

@end

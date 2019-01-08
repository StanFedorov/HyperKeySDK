//
//  DrawImageView.h
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 23.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawImageCanvasViewDelegate;

@interface DrawImageCanvasView : UIImageView

@property (weak, nonatomic) id<DrawImageCanvasViewDelegate> delegate;
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) CGSize aspectFillSize;
@property (assign, nonatomic) BOOL isEnabled;

- (void)clear;

@end

@protocol DrawImageCanvasViewDelegate <NSObject>

@optional
- (void)drawImageCanvasViewDidTapField;
- (void)drawImageCanvasViewDidStartDraw;
- (void)drawImageCanvasViewDidFinishDraw;

@end

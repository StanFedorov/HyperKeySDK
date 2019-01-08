//
//  DrawImageMenuView.h
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 23.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawImageMenuViewDelegate;

@interface DrawImageMenuView : UIView

@property (weak, nonatomic) id<DrawImageMenuViewDelegate> delegate;

@end

@protocol DrawImageMenuViewDelegate <NSObject>

@optional
- (void)drawImageMenuDidSaveGifAction;
- (void)drawImageMenuDidUndoAction;
- (void)drawImageMenuDidPlayAction;
- (void)drawImageMenuDidSelectColor:(UIColor *)color;

@end

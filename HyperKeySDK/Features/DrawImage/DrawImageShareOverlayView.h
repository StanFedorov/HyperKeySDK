//
//  DrawImageNotificationView.h
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 26.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawImageShareOverlayViewDelegate;

@interface DrawImageShareOverlayView : UIView

@property (weak, nonatomic) id<DrawImageShareOverlayViewDelegate> delegate;

- (void)startAnimatingWithCompetion:(void (^)(void))competion;
- (void)stopAnimatingWithCompetion:(void (^)(void))competion;

@end

@protocol DrawImageShareOverlayViewDelegate <NSObject>

@optional
- (void)drawImageShareOverlayViewDidTap;
- (void)drawImageShareOverlayViewDidLinkAction;
- (void)drawImageShareOverlayViewDidWhatsAppAction;
- (void)drawImageShareOverlayViewDidImageAction;

@end

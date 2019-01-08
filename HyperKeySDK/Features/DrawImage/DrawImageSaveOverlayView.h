//
//  DrawImageSaveOverlayView.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 30.06.16.
//
//

#import <UIKit/UIKit.h>

@protocol DrawImageSaveOverlayViewDelegate;

@interface DrawImageSaveOverlayView : UIView

@property (weak, nonatomic) id<DrawImageSaveOverlayViewDelegate> delegate;

- (void)startAnimatingWithCompetion:(void (^)(void))competion;
- (void)stopAnimatingWithCompetion:(void (^)(void))competion;

@end

@protocol DrawImageSaveOverlayViewDelegate <NSObject>

@optional
- (void)drawImageSaveOverlayViewDidTap;

@end

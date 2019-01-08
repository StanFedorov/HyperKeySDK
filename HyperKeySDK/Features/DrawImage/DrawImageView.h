//
//  DrawImageView.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 03.08.16.
//
//

#import <UIKit/UIKit.h>
#import "Config.h"

@protocol DrawImageViewDelegate;

@interface DrawImageView : UIView

@property (weak, nonatomic) id<DrawImageViewDelegate> delegate;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (assign, nonatomic) FeatureType featureType;

- (void)hideShareOverlayView;

@end

@protocol DrawImageViewDelegate <NSObject>

@optional
- (void)drawImageViewDidUploadImageToURLString:(NSString *)urlString;
- (void)drawImageViewDidShareGif;
- (void)drawImageViewDidShareImage;
- (void)drawImageViewDidShareWhatsApp;
- (void)drawImageViewDidCancel;

@end

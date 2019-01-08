//
//  ActionView.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 21.06.16.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ActionViewType) {
    ActionViewTypeCopy,
    ActionViewTypePaste,
};

typedef NS_ENUM(NSUInteger, ActionViewOptions) {
    ActionViewOptionsEmpty           = 0,
    ActionViewOptionsWithoutRemoving = 1 << 0,
    ActionViewOptionsProgress        = 1 << 1,
};

@interface ActionView : UIView

@property (assign, nonatomic) ActionViewType type;
@property (assign, nonatomic) ActionViewOptions options;
@property (strong, nonatomic) NSString *customTitle;
@property (assign, nonatomic, readonly) BOOL isAnimating;

- (void)prepareShowAnimation;
- (void)startShowAnimationWithCompletion:(void (^)(BOOL finished))completion;
- (void)startShowAnimationWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion;
- (void)updateShowAnimationProgress:(CGFloat)progress;

- (void)startHideAnimationsCompletion:(void (^)(BOOL finished))completion;;
- (void)startHideAnimationsWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay completion:(void (^)(BOOL finished))completion;

@end

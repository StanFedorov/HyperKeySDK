//
//  TutorialView.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import <UIKit/UIKit.h>

@protocol TutorialViewDelegate <NSObject>

- (void)showDefaultFeature;

@end

@interface TutorialView : UIView

@property (weak, nonatomic) id<TutorialViewDelegate> delegate;

@end

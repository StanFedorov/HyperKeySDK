//
//  HKStreachableLabel.h
//  Better Word
//
//  Created by Sergey Vinogradov on 11.01.16.
//
//

#import <UIKit/UIKit.h>

@protocol StrechableLabelDelegate <NSObject>

@required
- (void)presetWidth:(CGFloat)prefWidth;

@end

@interface HKStreachableLabel : UILabel

@property (strong, nonatomic) IBOutlet id <StrechableLabelDelegate> delegate;
@property (assign, nonatomic) CGSize preferredSize;

@end
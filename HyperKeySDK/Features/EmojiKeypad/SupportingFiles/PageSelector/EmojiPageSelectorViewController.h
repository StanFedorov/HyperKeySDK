//
//  EmojiPageSelectorViewController.h
//  Better Word
//
//  Created by Sergey Vinogradov on 31.03.16.
//
//

#import <UIKit/UIKit.h>
#import "ThemeChangesResponderProtocol.h"

@protocol EmojiPageSelectorDelegate <NSObject>

- (void)setActiveSection:(NSUInteger)section;

@end

@interface EmojiPageSelectorViewController : UIViewController <ThemeChangesResponderProtocol>

@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView1;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView2;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView3;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView4;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView5;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView6;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView7;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView8;
@property (strong, nonatomic) IBOutlet UIImageView *sectionImageView9;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *sectionImageViews;

@property (weak, nonatomic) IBOutlet id<EmojiPageSelectorDelegate> delegate;

- (void)setActiveSectionNumber:(NSUInteger)section;

@end

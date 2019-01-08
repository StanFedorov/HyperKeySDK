//
//  EmojiPanel.h
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import "BaseVC.h"
#import "ThemeChangesResponderProtocol.h"
#import "KeyboardViewControllerProtocolList.h"

@interface EmojiPanel : BaseVC <UICollectionViewDelegate, UICollectionViewDataSource, ThemeChangesResponderProtocol>

@property (assign, nonatomic) id<KeyboardContainerDelegate, DirectInsertAndDeleteDelegate> delegate;

- (void)loadEmoji;

@end

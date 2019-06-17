//
//  EmojiKeypadViewController.h
//  Better Word
//
//  Created by Sergey Vinogradov on 29.03.16.
//
//

#import "BaseVC.h"
#import "GifVC.h"

@interface EmojiKeypadViewController : BaseVC <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ThemeChangesResponderProtocol>

@property (weak, nonatomic) id<KeyboardContainerDelegate, DirectInsertAndDeleteDelegate> delegate;
- (void)performSearch:(NSString*)search;
@end

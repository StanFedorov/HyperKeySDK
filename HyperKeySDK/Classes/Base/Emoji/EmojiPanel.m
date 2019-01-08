//
//  EmojiPanel.m
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import "EmojiPanel.h"
#import "EmojiAPI.h"
#import "EmojiCollectionCell.h"
#import "KeyboardThemesHelper.h"

@interface EmojiPanel ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *emojis;

@end

@implementation EmojiPanel

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *cellName = NSStringFromClass([EmojiCollectionCell class]);
    [self.collectionView registerNib:[UINib nibWithNibName:cellName bundle:nil] forCellWithReuseIdentifier:cellName];
}

- (void)loadEmoji {
    self.emojis = [[EmojiAPI sharedAPI] getAllEmojis];
    
    if (self.emojis) {
        [self.collectionView reloadData];
    }
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.emojis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmojiCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([EmojiCollectionCell class]) forIndexPath:indexPath];
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(EmojiCollectionCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.text.text = self.emojis[indexPath.row];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(insertTextStringToCurrentPosition:)]) {        
        [self.delegate insertTextStringToCurrentPosition:self.emojis[indexPath.row]];
    }
}


#pragma mark - ThemeChangesResponderProtocol

- (void)setTheme:(KBTheme)theme {
    self.view.backgroundColor = colorAdditionalMenuForTheme(theme);
}

@end

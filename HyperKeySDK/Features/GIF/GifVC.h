//
//  GifVC.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "ExtendedBaseVC.h"

@interface GifVC : ExtendedBaseVC
- (void)loadItemsWithSearch:(NSString *)searchString;
- (void)setLastSearch:(NSString *)search;
@end

//
//  YelpVC.h
//  
//
//  Created by Oleg Mytsouda on 18.10.15.
//
//

#import "BaseVC.h"

@interface YelpVC : BaseVC

@property (weak, nonatomic) id<KeyboardContainerDelegate, UITextFieldIndirectDelegate> delegate;
- (void)performSearch:(NSString *)searchText;
- (void)setLastSearch:(NSString *)search;
@end

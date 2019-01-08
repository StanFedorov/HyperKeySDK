//
//  YoutubeVC.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "BaseVC.h"

@interface YoutubeVC : BaseVC

@property (weak, nonatomic) id<KeyboardContainerDelegate, UITextFieldIndirectDelegate> delegate;

@end

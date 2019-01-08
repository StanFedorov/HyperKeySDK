//
//  ACKeyMat.h
//  Better Word
//
//  Created by Sergey Vinogradov on 03.03.16.
//
//

#import <UIKit/UIKit.h>

@class ACKey;

@interface ACKeyMat : UIControl

@property (strong, nonatomic) ACKey *key;

+ (instancetype)matForKey:(ACKey *)key;

@end

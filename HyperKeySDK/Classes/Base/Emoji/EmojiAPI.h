//
//  EmojiAPI.h
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import <Foundation/Foundation.h>

@interface EmojiAPI : NSObject

@property (assign, nonatomic) BOOL getEmojisFromFile;

+ (nonnull instancetype)sharedAPI;

- (nullable NSArray *)getAllEmojis;

@end

//
//  MPTCCorrect.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 24.02.16.
//
//

#import <Foundation/Foundation.h>

@interface MPTCCorrect : NSObject

@property (strong, nonatomic) NSString *string;
@property (assign, nonatomic) NSRange range;

+ (instancetype)correctWithString:(NSString *)string range:(NSRange)range;

- (instancetype)initWithString:(NSString *)string range:(NSRange)range;

@end

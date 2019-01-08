//
//  ACSpaceOperation.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 25.02.16.
//
//

#import <Foundation/Foundation.h>

@interface ACSpaceOperation : NSOperation

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *original;
@property (strong, nonatomic) NSString *correction;

@property (copy, nonatomic) void (^willCompletionBlock)(NSString *text, NSString *original, NSString *correction);

- (instancetype)initWithText:(NSString *)text original:(NSString *)original correction:(NSString *)correction;

@end

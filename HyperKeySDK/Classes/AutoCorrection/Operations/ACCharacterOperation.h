//
//  ACCharacterOperation.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 15.02.16.
//
//

#import "MPTextChecker.h"

@interface ACCharacterOperation : NSOperation

@property (strong, nonatomic, readonly) NSString *text;

@property (copy, nonatomic) void (^willCompletionBlock)(NSString *text, NSString *original, MPTCString *correction, NSArray *other);

- (instancetype)initWithTextChecker:(MPTextChecker *)textChecker text:(NSString *)text;
- (void)updateTextByReplaceString:(NSString *)replaceString toString:(NSString *)toString;

@end

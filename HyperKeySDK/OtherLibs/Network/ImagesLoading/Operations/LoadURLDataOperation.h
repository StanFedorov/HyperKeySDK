//
//  LoadDataOperation.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 31.08.16.
//
//

#import <Foundation/Foundation.h>

@interface LoadURLDataOperation : NSOperation

@property (strong, nonatomic, readonly) NSString *urlString;
@property (strong, nonatomic, readonly) NSIndexPath *indexPath;

@property (copy, nonatomic) void (^willCompletionBlock)(NSData *data);

- (instancetype)initWithURLSting:(NSString *)urlString indexPath:(NSIndexPath *)indexPath;

@end

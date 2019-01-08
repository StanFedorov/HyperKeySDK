//
//  LoadFileDataOperation.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 31.08.16.
//
//

#import <Foundation/Foundation.h>

@interface LoadFileDataOperation : NSOperation

@property (strong, nonatomic, readonly) NSString *filePath;
@property (strong, nonatomic, readonly) NSIndexPath *indexPath;

@property (copy, nonatomic) void (^willCompletionBlock)(NSData *data);

- (instancetype)initWithFilePath:(NSString *)filePath indexPath:(NSIndexPath *)indexPath;

@end

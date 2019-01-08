//
//  YoutubeAPI.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import <Foundation/Foundation.h>
#import "YoutubeModel.h"

typedef void(^YoutubeResultBlock)(id _Nullable result,  NSError * _Nullable error);

@interface YoutubeAPI : NSObject

- (void)searchVideo:(nonnull NSString *)searchString completion:(nonnull YoutubeResultBlock)completion;
- (void)searchVideo:(nonnull NSString *)searchString sortByField:(nonnull NSString *)sortFieldName maxResults:(NSInteger)maxResults completion:(nonnull YoutubeResultBlock)completion;
- (void)durationForVideo:(nonnull NSString *)videoId completion:(nonnull YoutubeResultBlock)completion;

- (nullable NSString *)videoUrlById:(nullable NSString *)videoId;

@end

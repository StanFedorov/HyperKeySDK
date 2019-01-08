//
//  JSONSessionManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import "AFHTTPSessionManager.h"
#import "JSONSessionResult.h"

typedef void (^ ResponceBlockWithError) (id object, NSError *error);
typedef void (^ ErrorBlock) (NSError *responseError);

@protocol SessionManagerDelegate;

@interface JSONSessionManager : AFHTTPSessionManager

@property (weak, nonatomic) id<SessionManagerDelegate> delegate;

- (NSURLSessionDataTask *)sendDataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters headers:(NSDictionary *)headers success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end

@protocol SessionManagerDelegate <NSObject>

@optional
- (void)didFinishRequestWithResult:(JSONSessionResult *)result;

@end

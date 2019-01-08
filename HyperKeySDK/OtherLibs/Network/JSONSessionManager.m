//
//  JSONSessionManager.m
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import "JSONSessionManager.h"

NSString *const kAFHTTPSessionManagerErrorResponseObjectKey = @"ErrorResponseObjectKey";

@interface AFHTTPSessionManager()

@end

@implementation JSONSessionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSSet *accepedTypes = [self.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        accepedTypes = [accepedTypes setByAddingObject:@"text/plain"];
        self.responseSerializer.acceptableContentTypes =  accepedTypes;
    }
    return self;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    return [self dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters headers:nil success:success failure:failure];
}

- (NSURLSessionDataTask *)sendDataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters headers:(NSDictionary *)headers success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters headers:headers success:success failure:failure];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters headers:(NSDictionary *)headers success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];

    [request setAllHTTPHeaderFields:headers];

    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
        }
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(didFinishRequestWithResult:)]) {
            JSONSessionResult *result = [[JSONSessionResult alloc] init];
            result.request = [request copy];
            result.responseObject = responseObject;
            result.error = error;
            result.date = [NSDate date];
            [self.delegate didFinishRequestWithResult:result];
        }
        if (error) {
            if (failure) {
                NSError *extendedError = error;
                if (responseObject != nil) {
                    if (error.userInfo) { // Already has a dictionary, so we need to add to it.
                        NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                        userInfo[kAFHTTPSessionManagerErrorResponseObjectKey] = responseObject;
                        extendedError = [NSError errorWithDomain:error.domain code:error.code userInfo:[userInfo copy]];
                    } else { // No dictionary, make a new one.
                        extendedError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{kAFHTTPSessionManagerErrorResponseObjectKey: responseObject}];
                    }
                }

                if (failure) {
                    failure(dataTask, extendedError);
                }
            }
        } else {
            if (success) {
                success(dataTask, responseObject);
            }
        }
    }];
    return dataTask;
}

@end

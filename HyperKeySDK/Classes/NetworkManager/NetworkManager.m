//
//  NetworkManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 11/10/15.
//  Copyright (c) 2015 Dmitriy gonchar. All rights reserved.
//

#import "NetworkManager.h"


NSString *const kNetworkManagerImojiAuthUrl = @"https://api.imoji.io/v2/oauth/token";
NSString *const kNetworkManagerImojiBaseUrl = @"https://api.imoji.io";
NSString *const kNetworkManagerImojiClientId = @"c428de52-4935-4515-b001-50bf7fe942b3";
NSString *const kNetworkManagerImojiApiToken = @"U2FsdGVkX1+ML1jPaMhr8z3buDF5yPf0jBU9C38ddHH/x+aNbmsYWCuNpdUrXg0o";

NSString *const kNetworkManagerImojiAccessTokenKey = @"ImojiAccessToken";
NSString *const kNetworkManagerImojiRefreshTokenKey = @"ImojiRefreshToken";
NSString *const kNetworkManagerImojiAccessTokenExpireDateKey = @"ImojiAccessTokenExpireDate";

@interface NetworkManager () <SessionManagerDelegate>

@property (strong, nonatomic) JSONSessionManager *sessionManager;

@end

@implementation NetworkManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [[JSONSessionManager alloc] init];
        self.sessionManager.delegate = self;
    }
    return self;
}


#pragma mark - Public


- (void)getShortURLByLongURLString:(NSString *)longURLString withCompletion:(ResponceBlockWithError)completion {
    NSString *escapedString = [self stringByAddingPercentEncodingForRFC3986:longURLString];
    NSString *finalURLString = [NSString stringWithFormat:@"https://api-ssl.bitly.com/v3/shorten?access_token=33833f1c4ee43e61096b79d88d62861f5bf2537d&longUrl=%@", escapedString];
    
    [self getJSONDataForPath:finalURLString withHeaders:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *data = responseObject[@"data"];
        if ([responseObject[@"status_code"] integerValue] == 200) {
            if (completion) {
                completion(data[@"url"], nil);
            }
        } else {
            if (completion) {
                completion(longURLString, nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}


- (nullable NSString *)stringByAddingPercentEncodingForRFC3986:(NSString*)original {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [original
            stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}


#pragma mark - Private

- (NSURLSessionDataTask *)getJSONDataForPath:(NSString *)path withHeaders:(NSDictionary *)headers success:(void (^)(NSURLSessionDataTask * task, id responseObject))success failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure {
    NSString *urlString = path;
    
    return  [self.sessionManager sendDataTaskWithHTTPMethod:@"GET" URLString:urlString parameters:nil headers:headers success:^(NSURLSessionDataTask * task, id responseObject) {
        if (success){
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        if (failure){
            failure(task, error);
        }
    }];
}

@end

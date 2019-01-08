//
//  GifAPIClient.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "GifAPIClient.h"

#import "JSONSessionManager.h"

NSString *const kGifAPIClientBaseURL = @"https://api.tenor.co/v1";
NSString *const kGifAPIClientKey = @"BM6TCGJT6HOH";
NSInteger const kGifAPIClientMaxLimit = 50;

@interface GifAPIClient ()

@property (strong, nonatomic) JSONSessionManager *sessionManager;

@end

@implementation GifAPIClient

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [[JSONSessionManager alloc] init];
    }
    return self;
}


#pragma mark - Public

- (void)getGifsWithSearch:(NSString *)search offset:(NSString *)offset limit:(NSInteger)limit completion:(void (^)(NSError *error, NSArray *gifs, NSString *offset))completion {
    NSString *searchString = [search.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    searchString = [searchString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *urlString = kGifAPIClientBaseURL;
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (searchString.length > 0) {
        urlString = [urlString stringByAppendingPathComponent:@"search"];
        
        parameters[@"tag"] = searchString;
    } else {
        urlString = [urlString stringByAppendingPathComponent:@"trending"];
    }
    if (offset) {
        parameters[@"pos"] = offset;
    }
    parameters[@"limit"] = limit <= 0 || limit > kGifAPIClientMaxLimit ? @(kGifAPIClientMaxLimit) : @(limit);
    parameters[@"key"] = kGifAPIClientKey;
    
    [self.sessionManager sendDataTaskWithHTTPMethod:@"GET" URLString:urlString parameters:parameters headers:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSInteger statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
        if (statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"No data for getGifsWithSearch"};
                    NSError *error = [NSError errorWithDomain:@"Gif Error" code:statusCode userInfo:userInfo];
                    completion(error, nil, nil);
                }
            });
            return;
        }
        
        NSArray *gifs = @[];
        
        NSArray *gifssData = responseObject[@"results"];
        if (gifssData && [gifssData isKindOfClass:[NSArray class]]) {
            gifs = [MGif arrayWithAttrubutesArray:gifssData];
        }
        
        NSString *offset = responseObject[@"next"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(nil, gifs, offset);
            }
        });
    } failure:^(NSURLSessionDataTask * task, NSError * error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(error, nil, nil);
            }
        });
    }];
}

@end

//
//  YoutubeAPI.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "YoutubeAPI.h"

#import "Macroses.h"

@import UIKit;

NSString *const kYoutubeAPIDomainError = @"youtube error";

NSString *const kYoutubeAPIURL =
    @"https://www.googleapis.com/youtube/v3/search?"
     "part=snippet&"
     "type=video&"
     "key=AIzaSyDZjZPrcCEP9d91i60-zemME4dnD5pDZ2Y";  // Browser key. work)

NSString *const kYoutubeAPIDurationURL =
    @"https://www.googleapis.com/youtube/v3/videos?"
     "part=contentDetails&"
     "key=AIzaSyDZjZPrcCEP9d91i60-zemME4dnD5pDZ2Y&" // Browser key. work)
     "id=";

@interface YoutubeAPI ()

@property (strong, nonatomic) NSString *nextPageToken;
@property (strong, nonatomic) NSString *prevSearch;
@property (assign, nonatomic) ThumbinalsResolutions resolution;

@end

@implementation YoutubeAPI

- (instancetype)init {
    self = [super init];
    if (self) {
        [self checkResolution];
        
        self.prevSearch = kYoutubeAPIURL;
    }
    return self;
}

- (void)searchVideo:(NSString *)searchString completion:(YoutubeResultBlock)completion {
    [self searchVideo:searchString sortByField:@"relevance" maxResults:50 completion:completion];
}

- (void)searchVideo:(NSString *)searchString sortByField:(NSString *)sortFieldName maxResults:(NSInteger)maxResults completion:(YoutubeResultBlock)completion {
    if (!searchString) {
        completion(nil, nil);
        return;
    }
    
    NSURL *url = [self makeUrlForSearchString:searchString withSortByField:sortFieldName maxResults:maxResults];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            completion(nil, [NSError errorWithDomain:kYoutubeAPIDomainError code:2000 userInfo:@{NSLocalizedDescriptionKey : @"no data from youtube"}]);
            return;
        }
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if (jsonError) {
            completion(nil, jsonError);
            return;
        }
        
        [self parseResult:result withCompletion:completion];
    }] resume];
}

- (NSString *)videoUrlById:(NSString *)videoId {
    if (!videoId || videoId.length <= 0) {
        return nil;
    }
    
    return [@"http://www.youtube.com/watch?v=" stringByAppendingString:videoId];
}

- (void)durationForVideo:(NSString *)videoId completion:(YoutubeResultBlock)completion {
    if (!videoId) {
        completion(nil, nil);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[kYoutubeAPIDurationURL stringByAppendingString:videoId]];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data) {
            completion(nil, [NSError errorWithDomain:kYoutubeAPIDomainError code:2000 userInfo:@{NSLocalizedDescriptionKey : @"no data from youtube"}]);
            return ;
        }
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
        
        if (jsonError || result[@"error"]) {
            completion(nil, jsonError);
            return;
        }
        
        completion([self parseISO8601TimeString:result[@"items"][0][@"contentDetails"][@"duration"]], nil);
        
    }] resume];
}


#pragma mark - Private

- (void)checkResolution {
    if (IS_IPADPRO || IS_IPHONE_6_PLUS) {
        self.resolution = kTripleResolution;
    } else {
        self.resolution = kDoubleResolution;
    }
}

- (NSURL *)makeUrlForSearchString:(NSString *)searchString withSortByField:(NSString *)sortFieldName maxResults:(NSInteger)maxResults {
    NSMutableString *urlString = [NSMutableString stringWithString:kYoutubeAPIURL];
    
    if (![searchString isEqualToString:self.prevSearch]) {
        self.prevSearch = searchString;
        self.nextPageToken = nil;
    }
    
    [urlString appendString:[@"&order=" stringByAppendingString:sortFieldName]];
    [urlString appendString:[@"&maxResults=" stringByAppendingFormat:@"%ld", (long)maxResults]];
    
    if (searchString.length > 0) {
        [urlString appendString:[@"&q=" stringByAppendingString:searchString]];
    }
    
    if (self.nextPageToken) {
        [urlString appendString:[@"&pageToken=" stringByAppendingString:self.nextPageToken]];
    }
    
    return [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

- (void)parseResult:(NSDictionary *)result withCompletion:(YoutubeResultBlock)completion {
    if (result[@"error"]) {
        NSInteger code = [result[@"error"][@"code"] integerValue];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: result[@"error"][@"message"]};
        NSError *error = [NSError errorWithDomain:kYoutubeAPIDomainError code:code userInfo:userInfo];
        
        completion(nil, error);
        return;
    }
    
    self.nextPageToken = result[@"nextPageToken"];
    
    NSMutableArray *videos = [NSMutableArray new];
    for (NSDictionary *dict in result[@"items"]) {
        YoutubeModel *vid = [[YoutubeModel alloc] initWithDataDictionary:dict andResolution:self.resolution];
        if (vid) {
            [videos addObject:vid];
        }
    }
    completion(videos, nil);
}

- (NSString *)parseISO8601TimeString:(NSString *)str {
    if (!str || str.length <= 0) {
        return nil;
    }
    
    NSMutableString *result = [NSMutableString stringWithString:@""];
    
    // P#DT#H#M#S
    int days = 0, hours = 0, minutes = 0, seconds = 0;
    
    const char *ptr = str.UTF8String;
    while (*ptr) {
        if (*ptr == 'P' || *ptr == 'T') {
            ptr++;
            continue;
        }
        int value, charsRead;
        char type;
        if (sscanf(ptr, "%d%c%n", &value, &type, &charsRead) != 2) {
            // Handle parse error
        }
        if (type == 'D') {
            days = value;
        } else if(type == 'H') {
            hours = value;
        } else if(type == 'M') {
            minutes = value;
        } else if(type == 'S') {
            seconds = value;
        } else {
            // Handle invalid type
        }
        
        ptr += charsRead;
    }
    
    if (days) {
        [result appendFormat:@"%d:", days];
    }
    
    if (hours) {
        if (days && (float)hours / 10.0 < 1.0) {
            [result appendString:@"0"];
        }
        
        [result appendFormat:@"%d:", hours];
    } else if (days) {
        [result appendString:@"00:"];
    }
    
    if (minutes) {
        if ((days || hours) && (float)minutes / 10.0 < 1.0) {
            [result appendString:@"0"];
        }
        
        [result appendFormat:@"%d:", minutes];
    } else {
        if (days || hours) {
            [result appendString:@"00:"];
        } else {
            [result appendString:@"0:"];
        }
    }
    
    if (seconds) {
        if ((float)seconds / 10.0 < 1.0) {
            [result appendString:@"0"];
        }
        
        [result appendFormat:@"%d", seconds];
    } else {
        [result appendString:@"00"];
    }
    
    return result;
}

@end

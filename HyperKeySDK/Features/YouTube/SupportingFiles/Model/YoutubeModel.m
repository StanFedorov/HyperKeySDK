//
//  YoutubeModel.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import "YoutubeModel.h"

@implementation YoutubeModel

- (instancetype)initWithDataDictionary:(NSDictionary *)data andResolution:(ThumbinalsResolutions)resolution {
    self = [super init];
    if (self) {
        [self makePropertiesWithDictionary:data andResolution:resolution];
    }
    
    return self;
}

- (void)makePropertiesWithDictionary:(NSDictionary *)dict andResolution:(ThumbinalsResolutions)resolution {
    if (!dict) {
        return;
    }
    
    self.videoId = dict[@"id"][@"videoId"];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:SS.000Z";
    self.createdDate = [dateFormatter dateFromString:dict[@"snippet"][@"publishedAt"]];
    
    self.title = dict[@"snippet"][@"title"];
    
    switch (resolution) {
        case kDefaultResolution:
            self.imageUrl = dict[@"snippet"][@"thumbnails"][@"default"][@"url"];
            break;
            
        case kDoubleResolution:
            self.imageUrl = dict[@"snippet"][@"thumbnails"][@"medium"][@"url"];
            break;
            
        case kTripleResolution:
        default:
            self.imageUrl = dict[@"snippet"][@"thumbnails"][@"high"][@"url"];
            break;
    }
}

@end

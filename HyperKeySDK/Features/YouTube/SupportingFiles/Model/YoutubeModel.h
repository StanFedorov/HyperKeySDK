//
//  YoutubeModel.h
//  Better Word
//
//  Created by Dmitriy Gonchar on 21.12.15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ThumbinalsResolutions) {
    kDefaultResolution,
    kDoubleResolution,
    kTripleResolution,
};

@interface YoutubeModel : NSObject

@property (strong, nonatomic, nullable) NSString *videoId;
@property (strong, nonatomic, nullable) NSString *title;
@property (strong, nonatomic, nullable) NSString *imageUrl;
@property (strong, nonatomic, nullable) NSString *duration;
@property (strong, nonatomic, nullable) NSDate *createdDate;

- (nullable instancetype)initWithDataDictionary:(nonnull NSDictionary *)data andResolution:(ThumbinalsResolutions)resolution;

@end

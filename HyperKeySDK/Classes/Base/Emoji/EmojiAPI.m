//
//  EmojiAPI.m
//  Better Word
//
//  Created by Oleg Mytsouda on 16.10.15.
//
//

#import "EmojiAPI.h"

#import "ReachabilityManager.h"

NSString *const kEmojiAPIURL = @"http://www.emojitracker.com/api/rankings";
NSString *const kEmojiAPIFileName = @"EmojisRankings.json";
NSUInteger const kEmojiAPIMaxCount = 30;

@implementation EmojiAPI

+ (instancetype)sharedAPI {
    static EmojiAPI *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[EmojiAPI alloc] init];
        [REA_MANAGER startTrakingNetworkStatus];
        [shared downloadNewEmojis];
    });

    return shared;
}

- (void)downloadNewEmojis {
    if (REA_MANAGER.reachabilityStatus == 0) {
        return;
    }
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:kEmojiAPIURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data || error) {
            return;
        }
        
        [data writeToFile:[[NSBundle mainBundle] pathForResource:@"rankings" ofType:@"json"] atomically:YES];
        
        NSArray *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (result && result.count > 0) {
            [self updateEmojisWithData:data];
        }
    }] resume];
}

- (void)updateEmojisWithData:(NSData *)data {
    NSString *path = [self getEmojisFilePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        [data writeToFile:path atomically:YES];
    } else {
        [fm createFileAtPath:path contents:data attributes:nil];
    }
}

- (NSString *)getEmojisFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:kEmojiAPIFileName];
    return path;
}

- (NSArray *)parseEmojisRankingArray:(NSArray *)array {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:kEmojiAPIMaxCount];
    
    int i = 0;
    for (NSDictionary *dict in array) {
        if (i > kEmojiAPIMaxCount) {
            break;
        }
        
        [result addObject:dict[@"char"]];
        i ++;
    }
    
    return result;
}

- (NSArray *)parseFromFile {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [self getEmojisFilePath];
    NSData *jsonData = nil;
    if ([fm fileExistsAtPath:path]) {
        jsonData = [NSData dataWithContentsOfFile:path];
    } else {
        jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"rankings" ofType:@"json"]];
    }
    
    NSArray *result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    return [self parseEmojisRankingArray:result];
}

- (nullable NSArray *)getAllEmojis {
    return [self parseFromFile];
}

@end

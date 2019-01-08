//
//  MGif.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import "MGif.h"

@implementation MGif

#pragma mark - Class

+ (NSArray *)arrayWithAttrubutesArray:(NSArray *)array {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (array && [array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *attributes in array) {
            id model = [[[self class] alloc] initWithAttributes:attributes];
            if (model) {
                [result addObject:model];
            }
        }
    }
    return result;
}


#pragma mark - Public

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        if (attributes && [attributes isKindOfClass:[NSDictionary class]]) {
            self.identifier = attributes[@"id"];
            
            NSArray *mediaArray = attributes[@"media"];
            if ([mediaArray isKindOfClass:[NSArray class]] && mediaArray.count > 0) {
                NSDictionary *media = mediaArray.firstObject;
                if (media) {
                    NSDictionary *previewAttributes = media[@"nanogif"];
                    if (previewAttributes) {
                        self.previewURLString = previewAttributes[@"url"];
                        
                        NSNumber *fileSize = previewAttributes[@"size"];
                        if ([fileSize isKindOfClass:[NSNumber class]]) {
                            self.previewFileSize = [fileSize doubleValue];
                        }
                    }
                    
                    NSDictionary *fullAttributes = media[@"gif"];
                    if (fullAttributes) {
                        self.fullURLString = fullAttributes[@"url"];
                        
                        NSNumber *fileSize = fullAttributes[@"size"];
                        if ([fileSize isKindOfClass:[NSNumber class]]) {
                            self.fullFileSize = [fileSize doubleValue];
                        }
                        
                        NSArray *dims = fullAttributes[@"dims"];
                        if (dims && dims.count > 1) {
                            self.fullImageSize = CGSizeMake([dims[0] integerValue], [dims[1] integerValue]);
                        } else {
                            self.fullImageSize = CGSizeMake(200, 200);
                        }
                    }
                }
            }
            
            id tags = attributes[@"tags"];
            if (tags && [tags isKindOfClass:[NSArray class]]) {
                self.tags = tags;
            }
        }
    }
    return self;
}

@end

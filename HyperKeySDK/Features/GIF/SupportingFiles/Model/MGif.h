//
//  MGif.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import <UIKit/UIKit.h>

@interface MGif : NSObject

@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) NSString *previewURLString;
@property (strong, nonatomic) NSString *fullURLString;

@property (assign, nonatomic) long previewFileSize;
@property (assign, nonatomic) long fullFileSize;

@property (assign, nonatomic) CGSize fullImageSize;

@property (strong, nonatomic) NSArray *tags;

+ (NSArray *)arrayWithAttrubutesArray:(NSArray *)array;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end

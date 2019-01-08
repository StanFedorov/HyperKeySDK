//
//  GifAPIClient.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 05.10.16.
//
//

#import <Foundation/Foundation.h>
#import "MGif.h"

@interface GifAPIClient : NSObject

- (void)getGifsWithSearch:(NSString *)search offset:(NSString *)offset limit:(NSInteger)limit completion:(void (^)(NSError *error, NSArray *gifs, NSString *offset))completion;

@end

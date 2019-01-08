//
//  JSONSessionResult.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 25.08.16.
//
//

#import <Foundation/Foundation.h>

@interface JSONSessionResult : NSObject

@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) id responseObject;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic, readonly) NSString *requestBodyText;

@end

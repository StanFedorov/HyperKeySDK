//
//  JSONSessionResult.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 25.08.16.
//
//

#import "JSONSessionResult.h"

@implementation JSONSessionResult

#pragma mark - Property

- (NSString *)requestBodyText {
    return [[NSString alloc] initWithData:self.request.HTTPBody encoding:NSUTF8StringEncoding];
}

@end

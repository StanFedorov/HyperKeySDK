//
//  NSString+Additions.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Additions)

+ (double)blockExecutionTime:(void(^)())block;
+ (void)logBlockExecutionTimeWithName:(NSString *)name block:(void(^)())block;

@end

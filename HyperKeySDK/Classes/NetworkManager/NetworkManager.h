//
//  NetworkManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 11/10/15.
//  Copyright (c) 2015 Dmitriy gonchar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSessionManager.h"

@interface NetworkManager : NSObject

- (void)checkAuthTokenAndGetImojiBySearchWords:(NSArray *)words offset:(NSInteger)offset limit:(NSInteger)limit withCompletion:(ResponceBlockWithError)completion;
- (void)getShortURLByLongURLString:(NSString *)longURLString withCompletion:(ResponceBlockWithError)completion;

@end

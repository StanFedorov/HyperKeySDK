//
//  DropBoxImageLoader.h
//  DropBox
//
//  Created by Dmitriy gonchar on 10/19/15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^ResponceBlockWithError)(id object, NSError * error);

@interface DropBoxImageLoader : NSObject

- (void)loadDropThumbnailByPath:(NSString *)path withCompletion:(void (^)(id object, NSError * error))completion;

@end

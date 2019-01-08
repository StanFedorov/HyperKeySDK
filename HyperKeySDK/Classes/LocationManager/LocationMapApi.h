//
//  LocationMapApi.h
//
//
//  Created by Dmitriy Gonchar on 21.10.13.
//  Copyright (c) 2013 Dmitriy Gonchar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationMapApi : NSObject

+ (nullable NSString *)getUserLocationMapUrlWithLatitude:(double)latitude andLongitude:(double)longitude;
+ (nullable UIImage *)getUserLocationMapStaticImageWithLatitude:(double)latitude andLongitude:(double)longitude andImageSize:(CGSize)size;

@end

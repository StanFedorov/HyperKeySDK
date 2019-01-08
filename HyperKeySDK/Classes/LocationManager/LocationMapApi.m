//
//  LocationMapApi.m
//
//
//  Created by Dmitriy Gonchar on 21.10.13.
//  Copyright (c) 2013 Dmitriy Gonchar. All rights reserved.
//

#import "LocationMapApi.h"

#import "ReachabilityManager.h"

NSString *const kLocationMapApiMapCreatorMainUrl = @"http://54.201.89.72";
NSString *const kLocationMapAuthentification = @"udid=test";

NSString *const  googleStaticMapApiUrl = @"https://maps.googleapis.com/maps/api/staticmap?"
    "key=AIzaSyDZjZPrcCEP9d91i60-zemME4dnD5pDZ2Y&" // API key
    "zoom=15&" // Zoom level - street and big buildings
    "format=jpg&" // Minimum size format
    "scale=2&"; // For retina display, size=100x100, scale=2 -> image size = 200x200
    // "markers=color:green|40.714728,-73.998672" //user location marker
    // "size=400x400&"// result image size
    // "center=40.714728,-73.998672"// map center

@implementation LocationMapApi

// Создать новую карту
// curl -X POST -d udid=test http://54.201.89.72/map
// Придёт ответ такого вида
// {
//    "location":"/map/tra69c1"
// }
//
// Получить все метки карты
// curl http://54.201.89.72/map/tra69c1?format=json
// Придёт ответ такого вида (для центра г. Москвы)
// {
//    "map":"tra69c1",
//    "points":[{
//                 "coordinates":[55.7522,37.6156],
//                 "timestamp":"2016-04-24T12:50:53.000Z"
//              }]
// }
//
// Посмотреть карту в формате графического изоображения в html
// firefox http://54.201.89.72/map/ca7889
//
// Поставить метку на карту от пользователя с udid test, который находится в точке с координатами [55.7522,37.6156]
// curl -X POST -d udid=test -d coordinates=[55.7522,37.6156] http://54.201.89.72/map/ca7889
// Придёт ответ с кодом 201. // Not working
// New request: curl -X POST -d udid=test -d latitude=55.7522 -d longitude=37.6156 http://54.201.89.72/map/e77e83


+ (NSString *)getUserLocationMapUrlWithLatitude:(double)latitude andLongitude:(double)longitude {
    if (REA_MANAGER.reachabilityStatus == 0) {
        return nil;
    }
    
    NSURL *newMapUrl = [NSURL URLWithString:[kLocationMapApiMapCreatorMainUrl stringByAppendingString:@"/map"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:newMapUrl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[kLocationMapAuthentification dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSError *error;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (response == nil || error != nil || responseData == nil || ([(NSHTTPURLResponse *)response statusCode] != 201 && [(NSHTTPURLResponse *)response statusCode] != 200)) {
        return nil;
    }
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
    NSString *newMapId = dict[@"location"];
    
    NSURL *mapPointUrl = [NSURL URLWithString:[kLocationMapApiMapCreatorMainUrl stringByAppendingString:newMapId]];
    NSString *mapPointParams = [NSString stringWithFormat:@"%@&latitude=%.4f&longitude=%.4f", kLocationMapAuthentification, latitude, longitude];
    [request setURL:mapPointUrl];
    [request setHTTPBody:[mapPointParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (response == nil || [(NSHTTPURLResponse*)response statusCode] != 201 || error != nil) {
        return nil;
    }
    
    return mapPointUrl.absoluteString;
}

+ (UIImage *)getUserLocationMapStaticImageWithLatitude:(double)latitude andLongitude:(double)longitude andImageSize:(CGSize)size {
    if (REA_MANAGER.reachabilityStatus == 0) {
        return nil;
    }
    
    // "size=400x400&" // Result image size
    // "center=40.714728,-73.998672"// Map center
    // "markers=" // Custom marker
    NSString *urlString = [googleStaticMapApiUrl stringByAppendingFormat:@"size=%dx%d&center=%.6f,%.6f&markers=color:green|%.6f,%.6f", (int)size.width, (int)size.height, latitude, longitude, latitude, longitude];

    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    
    if (!result) {
        return nil;
    }
    
    return [UIImage imageWithData:result];
}

@end

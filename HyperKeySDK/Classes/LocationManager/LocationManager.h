//
//  LocationManager.h
//
//
//  Created by Dmitriy Gonchar on 21.10.13.
//  Copyright (c) 2013 Dmitriy Gonchar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define LOCATION_MANAGER [LocationManager sharedManager]

extern NSString *const kLocationManagerDidGetFirstLocation;
extern NSString *const kLocationManagerAllowGetLocation;
extern NSString *const kLocationManagerErrorUpdateLocation;
extern NSString *const kLocationManagerDidDecodeLocation;
extern NSString *const kLocationManagerDidNotDecodeLocation;
extern NSString *const kLocationManagerChangeStatusToDenied;

typedef enum : NSUInteger {
    kCLLocationUpdateStatusAllowed,
    kCLLocationUpdateStatusDenied,
    kCLLocationUpdateStatusNotRespond
} LocationUpdateStatus;

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *backwardLocation;

@property (assign, nonatomic) BOOL shouldSendLocationNotification;

+ (instancetype)sharedManager;

- (void)startUpdateLocation;
- (void)stopUpdateLocation;
- (void)startUpdateSignificantLocation;
- (void)stopUpdateSignificantLocation;

- (void)getAddressWithLocation:(CLLocation *)location;
- (LocationUpdateStatus)getLocationUpdateStatus;

@end

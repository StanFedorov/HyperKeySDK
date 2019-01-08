//
//  LocationManager.m
//
//
//  Created by Dmitriy Gonchar on 21.10.13.
//  Copyright (c) 2013 Dmitriy Gonchar. All rights reserved.
//

#import "LocationManager.h"

#import "ReachabilityManager.h"
#import "LocationMapApi.h"
#import "NetworkManager.h"

NSString *const kLocationManagerDidGetFirstLocation = @"LocationManagerDidGetFirstLocation";
NSString *const kLocationManagerAllowGetLocation = @"LocationManagerAllowGetLocation";
NSString *const kLocationManagerErrorUpdateLocation = @"LocationManagerErrorUpdateLocation";
NSString *const kLocationManagerDidDecodeLocation = @"LocationManagerDidDecodeLocation";
NSString *const kLocationManagerDidNotDecodeLocation = @"LocationManagerDidNotDecodeLocation";
NSString *const kLocationManagerChangeStatusToDenied = @"LocationManagerChangeStatusToDenied";

NSString *const kLMGoogleGeocodeKey = @"AIzaSyDZjZPrcCEP9d91i60-zemME4dnD5pDZ2Y";

@interface LocationManager ()

@property (assign, nonatomic) BOOL isStartGetLocation;

@end

@implementation LocationManager

+ (instancetype)sharedManager {
    static LocationManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
	self = [super init];
    if (self) {
        [self setup];
    }
	return self;
}


#pragma mark - Public

- (void)setup {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    self.shouldSendLocationNotification = YES;
    self.isStartGetLocation = NO;
    
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)startUpdateLocation {
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation {
    self.shouldSendLocationNotification = YES;
    [self.locationManager stopUpdatingLocation];
}

- (void)startUpdateSignificantLocation {
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopUpdateSignificantLocation {
    [self.locationManager stopMonitoringSignificantLocationChanges];
}


#pragma mark - Private

- (void)changeTrakingMode:(NSTimer *)timer {
    [timer invalidate];
    timer = nil;
    
    [self stopUpdateLocation];
    [self startUpdateSignificantLocation];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.backwardLocation = self.currentLocation;
    self.currentLocation = locations.firstObject;
        
    if (self.shouldSendLocationNotification) {
        self.isStartGetLocation = NO;
    }
    
    if (!self.isStartGetLocation) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidGetFirstLocation object:self.currentLocation];
        
        self.shouldSendLocationNotification = NO;
        self.isStartGetLocation = YES;
    }
    
    if (self.currentLocation.horizontalAccuracy <= 100.0f) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == 0) {
        return; // iOS simulator - forget to set location
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerErrorUpdateLocation object:error];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerChangeStatusToDenied object:nil];
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerAllowGetLocation object:nil];
            [self.locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}


#pragma mark - Geocode coordinate

- (void)getAddressWithLocation:(CLLocation *)location {
    if (!location) {
        return;
    }
    
    if ([REA_MANAGER reachabilityStatus]) {
        [self decodeLocationWithGoogle:location];
    } else {
        [self decodeLocationWithApple:location];
    }
}

- (void)decodeLocationWithGoogle:(CLLocation *)location {
    NSString *locationMapUrl = [LocationMapApi getUserLocationMapUrlWithLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%.6f,%.6f&key=%@&language=%@", location.coordinate.latitude, location.coordinate.longitude, kLMGoogleGeocodeKey, [[NSLocale preferredLanguages] objectAtIndex:0]]];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data || error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidNotDecodeLocation object:error];
            return ;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (!json || !json[@"results"] || ((NSString *)json[@"error_message"]).length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidNotDecodeLocation object:nil];
            return;
        }
        
        [self postLocationDecodeNotificationWithString:[@"📍I'm here: " stringByAppendingString: json[@"results"][0][@"formatted_address"]] andMapUrlString:locationMapUrl];
        
    }] resume];
}

- (void)decodeLocationWithApple:(CLLocation *)location {
    NSString *locationMapUrl = [LocationMapApi getUserLocationMapUrlWithLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude];
    
    [[CLGeocoder new] reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidNotDecodeLocation object:error];
            return;
        }
        
        if (!placemarks || placemarks.count <= 0) {
            NSString *addressCoordinate = [NSString stringWithFormat:@"📍I'm here: %f, %f", location.coordinate.latitude, location.coordinate.longitude];
            
            [self postLocationDecodeNotificationWithString:addressCoordinate andMapUrlString:locationMapUrl];
            return;
        }
        
        NSString *addressStr = @"";
        CLPlacemark *place = placemarks.firstObject;
        
        if (place.addressDictionary[@"FormattedAddressLines"]) {
            addressStr = [place.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
        } else {
            NSString *street = place.addressDictionary[@"Street"];
            NSString *city = place.addressDictionary[@"City"];
            NSString *country = place.addressDictionary[@"Country"];
            NSString *zip = place.addressDictionary[@"ZIP"];
            addressStr = [NSString stringWithFormat:@"%@, %@, %@, %@", street, city, country, zip];
        }
        
        if (addressStr.length > 0) {
            [self postLocationDecodeNotificationWithString:[@"📍I'm here: " stringByAppendingString: addressStr] andMapUrlString:locationMapUrl];
        }
    }];
}

- (void)postLocationDecodeNotificationWithString:(NSString *)mainString andMapUrlString:(NSString *)mapString {
    if (mapString == nil || mapString.length <= 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidDecodeLocation object:mainString];
    } else {
        NetworkManager *shortUrlsManager = [[NetworkManager alloc] init];
        
        [shortUrlsManager getShortURLByLongURLString:mapString withCompletion:^(id object, NSError *error) {
            if (object) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidDecodeLocation object:[NSString stringWithFormat:@"%@. Track my position for next 30 minutes: %@", mainString, object]];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidDecodeLocation object:mainString];
            }
        }];
    }
}

- (LocationUpdateStatus)getLocationUpdateStatus {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return kCLLocationUpdateStatusAllowed;
            
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            return kCLLocationUpdateStatusDenied;
            
        default:
            return kCLLocationUpdateStatusNotRespond;
    }
}

@end

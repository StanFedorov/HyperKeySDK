//
//  LocationVC.m
//
//
//  Created by Dmitriy Gonchar on 21.10.13.
//  Copyright (c) 2013 Dmitriy Gonchar. All rights reserved.
//

#import "LocationVC.h"

#import "LocationMapApi.h"
#import "LocationManager.h"
#import "HProgressHUD.h"

@interface LocationVC ()

@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UIView *pasteTipView;
@property (weak, nonatomic) IBOutlet UIView *noLocationView;
@property (weak, nonatomic) IBOutlet UIButton *activeLocationButton;

@property (weak, nonatomic) HProgressHUD *loadingHud;
@property (assign, nonatomic) BOOL waitCurrentLocationOperation;
@property (strong, nonatomic) NSString *addressString;

@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadingHud = [HProgressHUD showHUDSizeType:HProgressHUDSizeTypeBig addedTo:self.mapImageView animated:YES];
    [self.loadingHud showAnimated:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(insertMapToTextField:)];
    [self.mapImageView addGestureRecognizer:tap];
    
    self.activeLocationButton.layer.cornerRadius = 5.0;
    self.activeLocationButton.layer.masksToBounds = YES;
    self.noLocationView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addObserveLocationNotification];
    [self locationUpdate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self removeObserveLocationNotification];
}


#pragma mark - Actions

- (IBAction)insertMapToTextField:(id)sender {
    if (self.addressString) {
        [self.delegate keyboardContainerDidInsertKeyboardText:self.addressString];
    }
    
    [self functionButton:nil];
}

- (IBAction)functionButton:(id)sender {
    [self.delegate functionButton:sender];
}

- (IBAction)activateLocation:(UIButton *)sender {
    LocationUpdateStatus status = [LOCATION_MANAGER getLocationUpdateStatus];
    switch (status) {
        case kCLLocationUpdateStatusDenied: {
            UIResponder *responder = self;
            while ((responder = [responder nextResponder]) != nil) {
                NSLog(@"responder = %@", responder);
                if ([responder respondsToSelector:@selector(openURL:)] == YES) {
                    [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
        }   break;
            
        case kCLLocationUpdateStatusAllowed:
            [LOCATION_MANAGER startUpdateLocation];
            self.noLocationView.hidden = YES;
            break;
            
        case kCLLocationUpdateStatusNotRespond:
            [LOCATION_MANAGER startUpdateLocation];
            break;
            
        default:
            break;
    }
}


#pragma mark - Location Actions

- (void)locationUpdate {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            self.noLocationView.hidden = NO;
            break;
            
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [LOCATION_MANAGER startUpdateLocation];
            self.noLocationView.hidden = YES;
            [self updateCurrentLocation];
            break;
            
        default:
            break;
    }
}

- (void)updateCurrentLocation {
    LocationUpdateStatus status = [LOCATION_MANAGER getLocationUpdateStatus];
    switch (status) {
        case kCLLocationUpdateStatusDenied: {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showLocationUpdateDeniedError];
            });
        }   break;
            
        case kCLLocationUpdateStatusAllowed:
            LOCATION_MANAGER.shouldSendLocationNotification = YES;
            [LOCATION_MANAGER startUpdateLocation];
            break;
            
        case kCLLocationUpdateStatusNotRespond:
            self.waitCurrentLocationOperation = NO;
            break;
            
        default:
            break;
    }
}

- (void)addObserveLocationNotification {
    self.waitCurrentLocationOperation = NO;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(locationDidUpdate:) name:kLocationManagerDidGetFirstLocation object:nil];
    [nc addObserver:self selector:@selector(locationUpdateError:) name:kLocationManagerErrorUpdateLocation object:nil];
    [nc addObserver:self selector:@selector(locationDidDecode:) name:kLocationManagerDidDecodeLocation object:nil];
    [nc addObserver:self selector:@selector(locationNotDecode:) name:kLocationManagerDidNotDecodeLocation object:nil];
    [nc addObserver:self selector:@selector(prepareToGetLocation) name:kLocationManagerAllowGetLocation object:nil];
    [nc addObserver:self selector:@selector(showLocationUpdateDeniedError) name:kLocationManagerChangeStatusToDenied object:nil];
}

- (void)removeObserveLocationNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setWaitCurrentLocationOperationToNoAfterDelay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.waitCurrentLocationOperation = NO;
    });
}

- (void)prepareToGetLocation {
    self.waitCurrentLocationOperation = YES;
}

- (void)showLocationUpdateDeniedError {
    self.noLocationView.hidden = NO;
}

- (void)locationDidUpdate:(NSNotification *)note {
    self.noLocationView.hidden = YES;
    [LOCATION_MANAGER stopUpdateLocation];
    
    if (note.object && [note.object isKindOfClass:[CLLocation class]]) {
        [LOCATION_MANAGER getAddressWithLocation:note.object];
    }
}

- (void)locationUpdateError:(NSNotification *)note {
    [self stopUpdateLocationInManager];
}

- (void)locationDidDecode:(NSNotification *)note {
    self.noLocationView.hidden = YES;
    [self stopUpdateLocationInManager];

    self.addressString = note.object;
    
    [self getMapImageWithLocation:LOCATION_MANAGER.currentLocation];
}

- (void)locationNotDecode:(NSNotification *)note {
    [self stopUpdateLocationInManager];
}

- (void)stopUpdateLocationInManager {
    [LOCATION_MANAGER stopUpdateLocation];
    [self setWaitCurrentLocationOperationToNoAfterDelay];
}


#pragma mark - Map Actions

- (void)getMapImageWithLocation:(CLLocation *)location {
    UIImage *image = [LocationMapApi getUserLocationMapStaticImageWithLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude andImageSize:self.mapImageView.frame.size];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (image) {
            [self.loadingHud hideAnimated:YES];
            
            self.mapImageView.image = image;
            self.pasteTipView.hidden = NO;
        }
    });
    
}

@end

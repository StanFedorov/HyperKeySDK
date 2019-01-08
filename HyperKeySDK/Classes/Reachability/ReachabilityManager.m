//
//  ReachabilityManager.m
//
//  Created by Dmitriy gonchar on 4/6/15.
//

#import "ReachabilityManager.h"

NSString *const kReachabilityManagerChangedNotification = @"ReachabilityManagerChangedNotification";

@interface ReachabilityManager ()

@property (assign, nonatomic) NetworkStatus prevStatus;
@property (assign, nonatomic) BOOL shouldUpdateInfo;

@end

@implementation ReachabilityManager

+ (ReachabilityManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static ReachabilityManager *_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ReachabilityManager alloc] init];
    });
    
    return _sharedInstance;
}

- (void)startTrakingNetworkStatus {
    if (!self.internetReachability) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.internetReachability = [Reachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
    }
}

- (void)stopTrakingNetworkStatus {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    self.internetReachability = nil;
}

- (BOOL)isNeedUpdateInfo {
    return self.shouldUpdateInfo;
}

- (NSInteger)reachabilityStatus {
    return self.internetReachability.currentReachabilityStatus;
}


#pragma mark - Private

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    if (self.prevStatus == NotReachable && curReach.currentReachabilityStatus != NotReachable) {
        self.shouldUpdateInfo = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityManagerChangedNotification object:curReach];
    } else {
        self.shouldUpdateInfo = NO;
    }
    
    self.prevStatus = curReach.currentReachabilityStatus;
}

@end

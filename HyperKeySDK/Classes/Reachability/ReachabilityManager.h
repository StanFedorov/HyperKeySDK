//
//  ReachabilityManager.h
//
//  Created by Dmitriy gonchar on 4/6/15.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

#define REA_MANAGER [ReachabilityManager sharedInstance]

extern NSString *const kReachabilityManagerChangedNotification;

@interface ReachabilityManager : NSObject

@property (strong, nonatomic) Reachability *internetReachability;

+ (ReachabilityManager *)sharedInstance;

- (void)startTrakingNetworkStatus;
- (void)stopTrakingNetworkStatus;

- (BOOL)isNeedUpdateInfo;

- (NSInteger)reachabilityStatus;

@end

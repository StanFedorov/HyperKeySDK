//
//  KeyboardFeaturesAuthenticationManager.m
//  Better Word
//
//  Created by Sergey Vinogradov on 08.04.16.
//
//

#import "KeyboardFeaturesAuthenticationManager.h"

#import "Config.h"

@implementation KeyboardFeaturesAuthenticationManager 

#pragma mark - Initialization

+ (instancetype)sharedManager {
    static KeyboardFeaturesAuthenticationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KeyboardFeaturesAuthenticationManager alloc] init];
    });
    
    return manager;
}


#pragma mark - Authorization

- (BOOL)isRequireAuthorizationForFeatureType:(FeatureType)itemType {
    switch (itemType) {
        case FeatureTypeDropbox:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isItemAuthorizedWithFeatureType:(FeatureType)itemType {
    BOOL isAuthorized = NO;

    if ([self isRequireAuthorizationForFeatureType:itemType] || itemType == FeatureTypeTwitch) {
        id object = [self authorizationObjectForFeatureType:itemType];
        isAuthorized = (object != nil);
    }

    return isAuthorized;
}

- (void)setAuthorizationObject:(id)object forFeatureType:(FeatureType)itemType {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    if (object) {
        if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSString class]]) {
            [defaults setObject:object forKey:kUserDefaultsAuthKeyForFeatureType(itemType)];
        }
    } else {
        [defaults removeObjectForKey:kUserDefaultsAuthKeyForFeatureType(itemType)];
    }
    [defaults synchronize];
    
    //Feed support
    if (itemType == FeatureTypeFacebook) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSignInOutCrossBorder object:nil userInfo:@{@"action":(object?@"in":@"out")}];
    }
}

- (id)authorizationObjectForFeatureType:(FeatureType)itemType {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    return [userDefaults objectForKey:kUserDefaultsAuthKeyForFeatureType(itemType)];
}

@end

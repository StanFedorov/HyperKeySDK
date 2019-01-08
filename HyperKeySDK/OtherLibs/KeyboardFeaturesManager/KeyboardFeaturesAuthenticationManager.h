//
//  KeyboardFeaturesAuthenticationManager.h
//  Better Word
//
//  Created by Sergey Vinogradov on 08.04.16.
//
//

#import <Foundation/Foundation.h>
#import "Config.h"

@interface KeyboardFeaturesAuthenticationManager : NSObject

+ (instancetype)sharedManager;

- (BOOL)isRequireAuthorizationForFeatureType:(FeatureType)itemType;
- (BOOL)isItemAuthorizedWithFeatureType:(FeatureType)itemType;
- (void)setAuthorizationObject:(id)object forFeatureType:(FeatureType)itemType;
- (id)authorizationObjectForFeatureType:(FeatureType)itemType;

@end

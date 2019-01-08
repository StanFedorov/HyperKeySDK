//
//  KeyboardFeature.h
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import <UIKit/UIKit.h>

#import "Config.h"

@interface KeyboardFeature : NSObject

@property (assign, nonatomic, readonly) FeatureType type;
@property (assign, nonatomic) FeaturesSectionType sectionType;
@property (assign, nonatomic) FeaturesState state;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *information;
@property (strong, nonatomic) NSString *imageNameOrUrl;
@property (strong, nonatomic) NSString *dataSource;
@property (strong, nonatomic) NSString *storeProductID;
@property (strong, nonatomic) NSString *storeProductPrice;

@property (assign, nonatomic, getter = isDynamicSetted) BOOL dynamicSetted;//if image/title have to be changed from standart

+ (instancetype)featureWithType:(FeatureType)type;

- (instancetype)initWithType:(FeatureType)type;

- (BOOL)isImageFromResources;
- (BOOL)isSameTo:(KeyboardFeature *)otherFeature;
- (NSString *)typeDescription;

@end

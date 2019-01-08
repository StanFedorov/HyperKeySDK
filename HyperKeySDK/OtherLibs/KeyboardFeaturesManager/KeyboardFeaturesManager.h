//
//  KeyboardFeaturesManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import <UIKit/UIKit.h>

#import "KeyboardFeature.h"

extern NSString *const kNotificationUpdateFeaturesList;

@interface KeyboardFeaturesManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *enabledItemsList;

+ (instancetype)sharedManager;

- (void)reloadEnabledAndAllDynamicItemsList;
- (void)moveEnabledItemFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex;
- (NSArray *)allItemsList;
- (KeyboardFeature *)staticDefinedItemForType:(FeatureType)type;
- (NSArray *)itemsListForSection:(FeaturesSectionType)sectionType;
- (NSArray *)staticItemsListForAllSectionsExceptSections:(NSArray *)sectionTypeList;
- (void)setIsEnabled:(BOOL)isEnabled forItem:(KeyboardFeature *)item;
- (void)addDynamicItem:(KeyboardFeature *)item;
- (void)removeDynamicItem:(KeyboardFeature *)item;

- (void)updateUserGifCameraFeatureWithUserDictionary:(NSDictionary *)userDictionary;
- (void)saveListOfFeatures;
- (void)cleanListOfFeatures;

- (BOOL)checkBranchPreinstallItems;

#ifdef BETTER_WORD_TARGET
#ifdef kStoreEnabled
- (void)updateInAppPurchases;
- (void)byFeature:(KeyboardFeature *)feature;
- (void)restoreAllPurchases;
#endif
#endif

@end

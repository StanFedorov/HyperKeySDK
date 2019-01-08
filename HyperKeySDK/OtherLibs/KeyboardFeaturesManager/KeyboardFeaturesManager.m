//
//  KeyboardFeaturesManager.m
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import "KeyboardFeaturesManager.h"

#import "Macroses.h"
#define DEFAULT_ENABLED_FEATURES_TYPES @[@(FeatureTypeEmojiKeypad), @(FeatureTypeGif), @(FeatureTypeRecentShared)]

NSString *const kItemSerializationTitleKey = @"title";
NSString *const kItemSerializationInformationKey = @"information";
NSString *const kItemSerializationImageUrlKey = @"image_url";
NSString *const kItemSerializationDataSourceKey = @"data_source";
NSString *const kItemSerializationTypeKey = @"type";
NSString *const kItemSerializationSectionKey = @"section";

NSString *const kNotificationUpdateFeaturesList = @"NotificationUpdateFeaturesList";

@interface KeyboardFeaturesManager()

@property (strong, nonatomic, readwrite) NSMutableArray *enabledItemsList;
@property (strong, nonatomic) NSArray *featureTypesOrderList;
@property (strong, nonatomic) NSMutableArray *staticSettedItemsList;
@property (strong, nonatomic) NSMutableArray *dynamicallyAddedItemsList;

@end

@implementation KeyboardFeaturesManager

#ifdef BETTER_WORD_TARGET
#ifdef kStoreEnabled
- (void)dealloc {
    [self removeInAppPurchaseObserver];
}
#endif
#endif

+ (instancetype)sharedManager {
    static KeyboardFeaturesManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KeyboardFeaturesManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.staticSettedItemsList = [[NSMutableArray alloc] init];
        self.dynamicallyAddedItemsList = [[NSMutableArray alloc] init];
        self.enabledItemsList = [[NSMutableArray alloc] init];
        [self fillWithStaticSettedItems];
        [self reloadEnabledAndAllDynamicItemsList];
    }
    return self;
}

- (void)fillWithStaticSettedItems {
    [self.staticSettedItemsList removeAllObjects];
    
//    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeSticker]];
  //  [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeDrawImage]];
 //   [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeMojiSMPepsi]];
  //  [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeMojiSMBurgerKing]];
   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeMojiSMDelish]];
    //[self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeMojiSMHarpers]];
   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeMojiSMVodafone]];
   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeMojiSMCosmopolitan]];

    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeGif]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeYelp]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeAmazon]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeCamFind]];
  //  [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeTwitch]];
    //[self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeSpotify]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeYoutube]];
   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeEbay]];

   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeInstagram]];
   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeFacebook]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypePhotoLibrary]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeGoogleTranslate]];
    [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeShareLocation]];
  //  [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeDropbox]];
  //  [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeGoogleDrive]];
  //  [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeFrequentlyUsedPhrases]];
   // [self.staticSettedItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeCamFind]];

    if (!self.featureTypesOrderList) {
        self.featureTypesOrderList = @[@(FeatureTypeEmojiKeypad),
                                       @(FeatureTypeGif),
                                       @(FeatureTypeSticker),
                                       @(FeatureTypeDrawImage),
                                       @(FeatureTypeMojiSMPepsi),
                                       @(FeatureTypeMojiSMBurgerKing),
                                       @(FeatureTypeMojiSMDelish),
                                       @(FeatureTypeMojiSMHarpers),
                                       @(FeatureTypeMojiSMVodafone),
                                       @(FeatureTypeMojiSMCosmopolitan),
                                       @(FeatureTypeMeme),
                                       @(FeatureTypeMinions),
                                       @(FeatureTypeMemeGenerator),
                                       @(FeatureTypeAmazon),
                                       @(FeatureTypePhotoLibrary),
                                       @(FeatureTypeInstagram),
                                       @(FeatureTypeFacebook),
                                       @(FeatureTypeGoogleTranslate),
                                       @(FeatureTypeYelp),
                                       @(FeatureTypeTwitch),
                                       @(FeatureTypeShareLocation),
                                       @(FeatureTypeYoutube),
                                       @(FeatureTypeSpotify),
                                       @(FeatureTypeEbay),
                                       @(FeatureTypeFrequentlyUsedPhrases),
                                       @(FeatureTypeGoogleDrive),
                                       @(FeatureTypeDropbox),
                                       @(FeatureTypeCamFind),
                                       @(FeatureTypeSoundsCatalog)];
    }
    
    // TODO: Uncomment after bring localization
    //NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    //if ([userDefaults boolForKey:kUserDefaultsMainLangIsEnglish]) { }
 
}

- (NSArray *)sortAccordingToOrderFeaturesList:(NSArray *)featuresList {
    NSArray *result = [featuresList sortedArrayUsingComparator:^NSComparisonResult(KeyboardFeature * _Nonnull obj1, KeyboardFeature * _Nonnull obj2) {
        return [self.featureTypesOrderList indexOfObject:@(obj1.type)] > [self.featureTypesOrderList indexOfObject:@(obj2.type)];
    }];
    return result;
}

- (void)moveEnabledItemFromIndex:(NSUInteger)oldIndex toIndex:(NSUInteger)newIndex {
    if (oldIndex != newIndex) {
        KeyboardFeature *item = [self.enabledItemsList objectAtIndex:oldIndex];
        [self.enabledItemsList removeObject:item];
        [self.enabledItemsList insertObject:item atIndex:newIndex];
        
        [self saveEnabledAndAllDynamicsLists];
    }
}

- (void)reloadEnabledAndAllDynamicItemsList {
    [self.dynamicallyAddedItemsList removeAllObjects];
    [self.enabledItemsList removeAllObjects];
    
    [self.enabledItemsList addObject:[KeyboardFeature featureWithType:FeatureTypeEmojiKeypad]];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    NSArray *allDynamicFeaturesList = [userDefaults objectForKey:kUserDefaultsAllDynamicFeaturesListKey];
    if (allDynamicFeaturesList) {
        for (NSDictionary *itemDictionary in allDynamicFeaturesList) {
            KeyboardFeature *item = [[KeyboardFeature alloc] initWithType:[itemDictionary[kItemSerializationTypeKey] intValue]];
            item.sectionType = [itemDictionary[kItemSerializationSectionKey] intValue];
            item.title = itemDictionary[kItemSerializationTitleKey];
            item.information = itemDictionary[kItemSerializationInformationKey];
            item.imageNameOrUrl = itemDictionary[kItemSerializationImageUrlKey];
            item.dataSource = itemDictionary[kItemSerializationDataSourceKey];
            item.dynamicSetted = YES;
            [self.dynamicallyAddedItemsList addObject:item];
        }
    }

    NSArray *allItemsList = [self allItemsList];
    NSArray *enabledFeaturesList = [userDefaults objectForKey:kUserDefaultsEnabledFeaturesListKey];
    if (enabledFeaturesList) {
        for (NSDictionary *itemShortInfo in enabledFeaturesList) {
            int type = [itemShortInfo[kItemSerializationTypeKey] intValue];
            
            // Ignore recent
            if (type == FeatureTypeRecentShared) {
                continue;
            }
            
            NSString *dataSource = itemShortInfo[kItemSerializationDataSourceKey];
            
            for (KeyboardFeature *item in allItemsList) {
                if ((item.type == type) && (((item.dataSource) && (dataSource) && ([item.dataSource isEqualToString:dataSource])) || ((!item.dataSource) && (!dataSource)))) {
                    [self.enabledItemsList addObject:item];
                }
            }
        }
    } else {
        for (KeyboardFeature *item in allItemsList) {
         //   if ([DEFAULT_ENABLED_FEATURES_TYPES containsObject:@(item.type)]) {
                [self.enabledItemsList addObject:item];
           // }
        }
    }
}

- (KeyboardFeature *)staticDefinedItemForType:(FeatureType)type {
    return [[self.staticSettedItemsList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type = %d", type]] firstObject];
}

- (void)saveEnabledAndAllDynamicsLists {
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    NSMutableArray *serializedAllDynamicFeaturesList = [[NSMutableArray alloc] init];
    for (KeyboardFeature *item in self.dynamicallyAddedItemsList) {
        NSMutableDictionary *itemDictionary = [@{kItemSerializationTypeKey: @(item.type), kItemSerializationSectionKey: @(item.sectionType)} mutableCopy];
        if (item.title) {
            itemDictionary[kItemSerializationTitleKey] = item.title;
        }
        if (item.imageNameOrUrl) {
            itemDictionary[kItemSerializationImageUrlKey] = item.imageNameOrUrl;
        }
        if (item.information) {
            itemDictionary[kItemSerializationInformationKey] = item.information;
        }
        if (item.dataSource) {
            itemDictionary[kItemSerializationDataSourceKey] = item.dataSource;
        }
        [serializedAllDynamicFeaturesList addObject:itemDictionary];
    }
    [userDefaults setObject:serializedAllDynamicFeaturesList forKey:kUserDefaultsAllDynamicFeaturesListKey];
    
    NSMutableArray *serializedEnabledFeaturesList = [[NSMutableArray alloc] init];
    self.enabledItemsList = [[self sortAccordingToOrderFeaturesList:self.enabledItemsList] mutableCopy];
    for (KeyboardFeature *item in self.enabledItemsList) {
        NSMutableDictionary *itemDictionary = [[NSMutableDictionary alloc] init];
        itemDictionary[kItemSerializationTypeKey] = @(item.type);
        if (item.dataSource) {
            itemDictionary[kItemSerializationDataSourceKey] = item.dataSource;
        }
        [serializedEnabledFeaturesList addObject:itemDictionary];
    }
    [userDefaults setObject:serializedEnabledFeaturesList forKey:kUserDefaultsEnabledFeaturesListKey];
    [userDefaults synchronize];
}

- (NSArray *)allItemsList {
    return [self.staticSettedItemsList arrayByAddingObjectsFromArray:self.dynamicallyAddedItemsList];
}

- (NSArray *)itemsListForSection:(FeaturesSectionType)sectionType {
    NSMutableArray *result = [NSMutableArray array];
    NSArray *allItemsList = [self allItemsList];
    
    for (KeyboardFeature *item in allItemsList) {
        if (item.sectionType == sectionType) {
            [result addObject:item];
        }
    }

    return [self sortAccordingToOrderFeaturesList:result];
}

- (NSArray *)staticItemsListForAllSectionsExceptSections:(NSArray *)sectionTypeList {
    NSArray *result = [self.staticSettedItemsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        KeyboardFeature *feature = (KeyboardFeature *)evaluatedObject;
        return ![sectionTypeList containsObject:@(feature.sectionType)];
    }]];
    
    return [self sortAccordingToOrderFeaturesList:result];
}

- (void)setIsEnabled:(BOOL)isEnabled forItem:(KeyboardFeature *)item {
    if (item) {

        [self.enabledItemsList removeObject:item];
        if (isEnabled) {
            [self.enabledItemsList addObject:item];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFeaturesList object:nil];
        
        [self saveEnabledAndAllDynamicsLists];
    }
}

- (void)addDynamicItem:(KeyboardFeature *)item {
    if (!item.isDynamicSetted) {
        return;
    }
    
    BOOL isExists = NO;
    
    for (KeyboardFeature *someItem in self.dynamicallyAddedItemsList) {
        if ([item isSameTo:someItem]) {
            isExists = YES;
            break;
        }
    }

    if (!isExists) {
        [self.dynamicallyAddedItemsList addObject:item];
        [self.enabledItemsList addObject:item];
        [self saveEnabledAndAllDynamicsLists];
    }
}

- (void)removeDynamicItem:(KeyboardFeature *)item {
    if (!item.isDynamicSetted) {
        return;
    }

    [self.enabledItemsList removeObject:item];
    [self.dynamicallyAddedItemsList removeObject:item];

    [self saveEnabledAndAllDynamicsLists];
}


#pragma mark - Public

- (void)updateUserGifCameraFeatureWithUserDictionary:(NSDictionary *)dict {
    NSString *userID = dict[@"userId"];
    NSArray *array = [self.dynamicallyAddedItemsList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(KeyboardFeature *feature, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [feature.dataSource isEqualToString:userID];
    }]];
    
    KeyboardFeature *feature;
    if (array.count) {
        feature = array.firstObject;
    } else {
        feature = [[KeyboardFeature alloc] initWithType:FeatureTypeGifCamera];
        feature.sectionType = FeaturesSectionGifCamera;
    }
    
    if ([dict[@"name"] length]) {
        feature.title = dict[@"name"];
    } else {
        NSString *nick = ([dict[@"username"] length] ? [@"@" stringByAppendingString:dict[@"username"]] : @"");
        feature.title = nick;
    }
    
    feature.information = ([dict[@"description"] length] ? dict[@"description"] : (dict[@"username"] ? [@"nickname: " stringByAppendingString:dict[@"username"]] : nil));
    feature.dynamicSetted = YES;
    feature.imageNameOrUrl = dict[@"avatar"];
    feature.dataSource = dict[@"userId"];
    
    if (array.count) {
        [self saveEnabledAndAllDynamicsLists];
    } else {
        [self addDynamicItem:feature];
        
        NSUInteger index = [self.enabledItemsList indexOfObject:feature];
        [self moveEnabledItemFromIndex:index toIndex:0];
    }
}

- (void)saveListOfFeatures {
    [self saveEnabledAndAllDynamicsLists];
}

- (void)cleanListOfFeatures {
    [self.dynamicallyAddedItemsList removeAllObjects];
    [self.enabledItemsList removeAllObjects];
    
    [self saveListOfFeatures];
}


@end

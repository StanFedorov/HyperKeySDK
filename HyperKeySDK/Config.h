//
//  Config.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 06.01.16.
//
//

#import <UIKit/UIKit.h>

//#define kFabricEnabled
//#define kStoreEnabled

// Notifications
extern NSString *const kNotificationDropboxDidAuth;

extern NSString *const kNotificationHKProgress;
extern NSString *const kNotificationKeyValue;

// UserDefaults
extern NSString *const kUserDefaultsKey;
extern NSString *const kUserDefaultsSuiteName;
extern NSString *const kUserDefaultsBundleID;
extern NSString *const kUserDefaultsContainerTutotialShowedBefore;
extern NSString *const kUserDefaultsAppRunCount;
extern NSString *const kUserDefaultsCamfindClose;
extern NSString *const kUserDefaultsCamfindRefresh;
extern NSString *const kUserDefaultsCamfindCompleted;
extern NSString *const kUserDefaultsCheckEmptyFullNameRunCount;
extern NSString *const kUserDefaultsFacebookInviteReminder;
extern NSString *const kUserDefaultsAskReviewShowedBefore;
extern NSString *const kUserDefaultsKeyboardTutorialShowedBefore;
extern NSString *const kUserDefaultsKeyboardOverlayButtonTutorialShowedCount;
extern NSString *const kUserDefaultsKeyboardFourthTutorialShowedBefore;
extern NSString *const kUserDefaultsKeyboardSwitched;
extern NSString *const kUserDefaultsFullAccessGranted;
extern NSString *const kUserDefaultsFourthShowedBefore;
extern NSString *const kUserDefaultsServieListNotificationShowedBefore;
extern NSString *const kUserDefaultsKeyboardShowedBeforeBlockDate;
extern NSString *const kUserDefaultsStarsCountKey;
extern NSString *const kUserDefaultsPreviousKeyboardEnabled;
extern NSString *const kUserDefaultsNotificationFirstInstallStarted;
extern NSString *const kUserDefaultsAlreadyAskAboutPush;
extern NSString *const kUserDefaultsAlreadyAskAboutPushCounter;
extern NSString *const kUserDefaultsAlreadyOpenAppAuthorized;
//TODO: Uncomment after bring localization extern NSString *const kUserDefaultsMainLangIsEnglish;

extern NSString *const kUserDefaultsKeyboardGuideStep;
extern NSString *const kUserDefaultsKeyboardGuideShowCount;
extern NSString *const kUserDefaultsKeyboardGuideMenuTapCount;

extern NSString *const kUserDefaultsKeyboardWasOpenedLast;
extern NSString *const kUserDefaultsKeyboardMemGeneratorNotNeedGuide;

extern NSString *const kUserDefaultsSettingWordSuggestions;
extern NSString *const kUserDefaultsSettingWordAutocorrections;
extern NSString *const kUserDefaultsSettingQuickPeriod;
extern NSString *const kUserDefaultsSettingAutoCapitalize;
extern NSString *const kUserDefaultsSettingKeyClickSounds;
extern NSString *const kUserDefaultsSettingQuickEmojiKey;
extern NSString *const kUserDefaultsSettingEmojiSkinTone;
extern NSString *const kUserDefaultsSettingMainKeyboard;
extern NSString *const kUserDefaultsSettingAllowGifStripe;

extern NSString *const kUserDefaultsBotAvatarAlreadySent;

extern NSString *const kAppShareText;
extern NSString *const kMixpanelToken;

// Social
extern NSString *const kUserDefaultsFacebookFullname;
extern NSString *const kUserDefaultsFacebookID;
extern NSString *const kUserDefaultsFacebookIcon;
extern NSString *const kUserDefaultsFacebookFriendsCount;
extern NSString *const kUserDefaultsFeedToken;
extern NSString *const kUserDefaultsFeedUsername;
extern NSString *const kUserDefaultsFeedFullName;
extern NSString *const kUserDefaultsUsernameSyncSuccess;
extern NSString *const kUserDefaultsFeedLat;
extern NSString *const kUserDefaultsFeedLng;

extern NSString *const kNotificationFeedAvailabilityCheck;
extern NSString *const kNotificationSignInOutCrossBorder;
extern NSString *const kNotificationHaveToResetAllPages;
extern NSString *const kNotificationFileDidUploadSuccess;
extern NSString *const kNotificationFindNonUploadsFiles;

// Menu section
extern NSString *const kUserDefaultsEnabledFeaturesListKey;
extern NSString *const kUserDefaultsAllDynamicFeaturesListKey;

extern NSString *const kLocalizedTableSymbols;

// Index doesn't change!
typedef NS_ENUM(NSUInteger, FeatureType) {
    FeatureTypeNone                  =  0,
    FeatureTypeEmojiKeypad           =  1,
    FeatureTypeGif                   =  2,
    FeatureTypeSticker               =  3,
    FeatureTypeMojiSMPepsi           =  4,
    FeatureTypeMojiSMBurgerKing      =  5,
    FeatureTypeMojiSMDelish          =  6,
    FeatureTypeMojiSMHarpers         =  7,
    FeatureTypeMojiSMVodafone        =  8,
    FeatureTypeMojiSMCosmopolitan    =  9,
    FeatureTypeYelp                  = 10,
    FeatureTypeDropbox               = 11,
    FeatureTypeGoogleDrive           = 12,
    FeatureTypeInstagram             = 13,
    FeatureTypeFacebook              = 14,
    FeatureTypeDrawImage             = 15,
    FeatureTypeSpotify               = 16,
    FeatureTypeGoogleTranslate       = 17,
    FeatureTypeShareLocation         = 18,
    FeatureTypePhotoLibrary          = 19,
    FeatureTypeAppURL                = 20,
    FeatureTypeYoutube               = 21,
    FeatureTypeEbay                  = 22,
    FeatureTypeMeme                  = 23,
    FeatureTypeMemeGenerator         = 24,
    FeatureTypeMinions               = 25,
    FeatureTypeFrequentlyUsedPhrases = 26,
    FeatureTypeSoundsCatalog         = 27,
    FeatureTypeRecentShared          = 28,
    FeatureTypeTwitch                = 29,
    FeatureTypeFeedFriends           = 30,
    FeatureTypeGifCamera             = 31,
    FeatureTypeGifStripe             = 32,
    //especially for iMessage extention, can not be used somewhere else
    FeatureTypeGif_im                = 61,
    FeatureTypeSticker_im            = 62,
    FeatureTypeFeedFriends_im        = 63,
    FeatureTypeGifCamera_im          = 64,
    FeatureTypeCamFind         = 65,
    FeatureTypeAmazon         = 66
};

NSString *kUserDefaultsAuthKeyForFeatureType(FeatureType itemType);

typedef NS_ENUM(NSUInteger, FeaturesSectionType) {
    FeaturesSectionFun,
    FeaturesSectionSearch,
    FeaturesSectionProductivity,
    FeaturesSectionSoundsCatalog,
    FeaturesSectionGifCamera
};
NSString *kSectionNameForType(FeaturesSectionType sectionType);

typedef NS_ENUM(NSUInteger, FeaturesState) {
    FeaturesStateEnabled,
    FeaturesStateWaiting,
    FeaturesStatePayment,
};

// Keyboard Theme section
extern NSString *const kUserDefaultsKeyboardTheme;
extern NSString *const kThemeSelectorText;

typedef NS_ENUM(NSInteger, KBTheme) {
    KBThemeClassic      = 0,
    KBThemeOriginal,
    KBThemeTransparent
};

typedef NS_ENUM(NSUInteger, EmojiSkinTone) {
    EmojiSkinToneYellow = 0,
    EmojiSkinToneWhite,
    EmojiSkinToneTanned,
    EmojiSkinToneGrilled,
    EmojiSkinToneHalfBrown,
    EmojiSkinToneBrown
};

// Feed Section
extern NSString *const kFeedBaseUrl;
extern NSString *const kFeedFilesUrl;

// Index doesn't change!
typedef NS_ENUM(NSUInteger, DataType) {
    DataTypeUnknown = 0,
    DataTypeJPEG    = 1,
    DataTypePNG     = 2,
    DataTypeGIF     = 3,
    DataTypeVideo   = 4,
    DataTypeURL     = 5,
    DataTypeEmoji   = 6
};
NSString *kExtensionForDataType(DataType dataType);

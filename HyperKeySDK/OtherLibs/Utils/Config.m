//
//  Config.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 06.01.16.
//
//

#import "Config.h"

#pragma mark - Notifications

NSString *const kNotificationDropboxDidAuth = @"NotificationDropboxDidAuth";

NSString *const kNotificationHKProgress = @"NotificationHKProgress";
NSString *const kNotificationKeyValue = @"NotificationKeyValue";

#pragma mark - UserDefaults

NSString *const kUserDefaultsKey = @"UserDefaultsKey";
NSString *const kUserDefaultsSuiteName = @"group.net.hyperkey.sdk.keyboard";
NSString *const kUserDefaultsBundleID = @"net.hyperkey.keyboard";
NSString *const kUserDefaultsContainerTutotialShowedBefore = @"isTutotialShowsBefore";
NSString *const kUserDefaultsAppRunCount = @"UserDefaultsAppRunCount";
NSString *const kUserDefaultsCamfindClose = @"UserDefaultsCamfindClose";
NSString *const kUserDefaultsCamfindRefresh = @"UserDefaultsCamfindRefresh";
NSString *const kUserDefaultsCamfindCompleted = @"UserDefaultsCamfindCompleted";
NSString *const kUserDefaultsCheckEmptyFullNameRunCount = @"UserDefaultsCheckEmptyFullNameRunCount";
NSString *const kUserDefaultsFacebookInviteReminder = @"UserDefaultsFacebookInviteReminder";
NSString *const kUserDefaultsAskReviewShowedBefore = @"UserDefaultsAskReviewShowedBefore";
NSString *const kUserDefaultsKeyboardTutorialShowedBefore = @"IsExtentionKeyboardShowedBefore";
NSString *const kUserDefaultsKeyboardOverlayButtonTutorialShowedCount = @"UserDefaultsKeyboardOverlayButtonTutorialShowedCount";
NSString *const kUserDefaultsKeyboardFourthTutorialShowedBefore = @"UserDefaultsKeyboardFourthTutorialShowedBefore";
NSString *const kUserDefaultsKeyboardSwitched = @"UserDefaultsKeyboardSwitched";
NSString *const kUserDefaultsFullAccessGranted = @"UserDefaultsFullAccessGranted";
NSString *const kUserDefaultsServieListNotificationShowedBefore = @"UserDefaultsServieListNotificationShowedBefore";
NSString *const kUserDefaultsKeyboardShowedBeforeBlockDate = @"keyboardShowedBeforeBlockDate";
NSString *const kUserDefaultsStarsCountKey = @"starsCountKey";
NSString *const kUserDefaultsPreviousKeyboardEnabled = @"UserDefaultsPreviousKeyboardEnabled";
NSString *const kUserDefaultsNotificationFirstInstallStarted = @"UserDefaultsNotificationFirstInstallStarted";
NSString *const kUserDefaultsAlreadyAskAboutPush = @"UserDefaultsAlreadyAskAboutPush";
NSString *const kUserDefaultsAlreadyAskAboutPushCounter = @"UserDefaultsAlreadyAskAboutPushCounter";
NSString *const kUserDefaultsAlreadyOpenAppAuthorized = @"UserDefaultsAlreadyOpenAppAuthorized";
//TODO: Uncomment after bring localization NSString *const kUserDefaultsMainLangIsEnglish = @"UserDefaultsEnglishIsTheMainLanguage";

NSString *const kUserDefaultsKeyboardGuideStep = @"UserDefaultsGuideStep";
NSString *const kUserDefaultsKeyboardGuideShowCount = @"UserDefaultsGuideShowCountCurrentStep";
NSString *const kUserDefaultsKeyboardGuideMenuTapCount = @"UserDefaultsGuideMenuTapCount";

NSString *const kUserDefaultsKeyboardWasOpenedLast = @"UserDefaultsKeyboardWasOpenedLast";
NSString *const kUserDefaultsKeyboardMemGeneratorNotNeedGuide = @"UserDefaultsKeyboardMemGeneratorGuideNotNeeded";

NSString *const kUserDefaultsSettingWordSuggestions = @"UserDefaultsWordSuggestions";
NSString *const kUserDefaultsSettingWordAutocorrections = @"UserDefaultsWordAutocorrections";
NSString *const kUserDefaultsSettingQuickPeriod = @"UserDefaultsQuickPeriod";
NSString *const kUserDefaultsSettingAutoCapitalize = @"UserDefaultsAutoCapitalize";
NSString *const kUserDefaultsSettingKeyClickSounds = @"UserDefaultsKeyClickSounds";
NSString *const kUserDefaultsSettingQuickEmojiKey  = @"UserDefaultsQuickEmojiKey";
NSString *const kUserDefaultsSettingEmojiSkinTone = @"UserDefaultsEmojiSkinTone";
NSString *const kUserDefaultsSettingMainKeyboard = @"UserDefaultsMainKeyboard";
NSString *const kUserDefaultsSettingAllowGifStripe = @"UserDefaultsSettingAllowGifStripe";

NSString *const kUserDefaultsBotAvatarAlreadySent = @"UserDefaultsBotAvatarAlreadySent";


NSString *const kAppShareText = @"Don’t you want to know what I share in chat? … check it out http://bit.ly/hyperkey ";
NSString *const kMixpanelToken = @"a5a445103c3c0c380161fc736bdd0dc2";


#pragma maek - Social

NSString *const kUserDefaultsFacebookFullname = @"facebook_fullname";
NSString *const kUserDefaultsFacebookID = @"facebook_id";
NSString *const kUserDefaultsFacebookIcon = @"facebook_icon";
NSString *const kUserDefaultsFacebookFriendsCount = @"facebook_friendsCount";
NSString *const kUserDefaultsFeedToken = @"OurselfApiToken";
NSString *const kUserDefaultsFeedUsername = @"OurselfApiUsername";
NSString *const kUserDefaultsFeedFullName = @"OurselfApiFullNname";
NSString *const kUserDefaultsUsernameSyncSuccess = @"UsernameSyncSuccess";
NSString *const kUserDefaultsFeedLat = @"OurselfApiLat";
NSString *const kUserDefaultsFeedLng = @"OurselfApiLng";

NSString *const kNotificationFeedAvailabilityCheck = @"NotificationFeedAvailabilityCheck";
NSString *const kNotificationSignInOutCrossBorder = @"Especially for sent from KeyboardFeaturesAuthenticationManager-setAuthorizationObject";
NSString *const kNotificationHaveToResetAllPages = @"NotificationHaveToResetAllPages";
NSString *const kNotificationFileDidUploadSuccess = @"NotificationFileDidUploadSuccess";
NSString *const kNotificationFindNonUploadsFiles = @"NotificationFindNonUploadsFiles";

#pragma mark - Menu section

NSString *const kUserDefaultsEnabledFeaturesListKey = @"UserDefaultsEnabledFeaturesList";
NSString *const kUserDefaultsAllDynamicFeaturesListKey = @"UserDefaultsAllDynamicFeaturesList";

NSString *const kLocalizedTableSymbols = @"LocalizedTableSymbols";


#pragma mark - Add text notification

NSString *kUserDefaultsAuthKeyForFeatureType(FeatureType itemType){
    switch (itemType) {
        case FeatureTypeDropbox:
            return @"dropBoxAccessToken";
            
        case FeatureTypeGoogleDrive:
            return @"googleDriveAccessToken";
            
        case FeatureTypeInstagram:
            return @"instAccessToken";
            
        case FeatureTypeFacebook:
            return @"fbAccessToken";
            
        case FeatureTypeTwitch:
            return @"TwitchToken";
            
        case FeatureTypeCamFind:
            return @"CamFindToken";
            
        default:
            return nil;
    }
}

NSString *kSectionNameForType(FeaturesSectionType sectionType) {
    switch (sectionType) {
        case FeaturesSectionFun:
            return @"Fun";
            
        case FeaturesSectionSearch:
            return @"Search";
            
        case FeaturesSectionProductivity:
            return @"Productivity";
            
            case FeaturesSectionGifCamera:
            return @"GifCamera";
            
        default:
            return nil;
    }
}


#pragma mark - Keyboard Theme section

NSString *const kUserDefaultsKeyboardTheme = @"UserDefaultsKeyboardTheme";
NSString *const kThemeSelectorText = @"HyperkeyThemeSelector";


#pragma mark - Feed

NSString *const kFeedFilesUrl = @""; // TODO: Remove
NSString *const kFeedBaseUrl  = @"http://52.34.139.66/API_V_2/";
//NSString *const kFeedBaseUrl = @"http://52.34.139.66/TEST2/";


#pragma mark - Data type

NSString *kExtensionForDataType(DataType dataType) {
    switch (dataType) {
        case DataTypeJPEG:
            return @"jpg";
            
        case DataTypePNG:
            return @"png";
            
        case DataTypeGIF:
            return @"gif";
            
        case DataTypeVideo:
            return @"mov";
            
        default:
            return @"";
    }
}

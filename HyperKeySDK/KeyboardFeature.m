//
//  KeyboardFeature.m
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import "KeyboardFeature.h"

@interface KeyboardFeature ()

@property (assign, nonatomic, readwrite) FeatureType type;

@end

@implementation KeyboardFeature

#pragma mark - Class

+ (instancetype)featureWithType:(FeatureType)type {
    return [[KeyboardFeature alloc] initWithType:type];
}

#pragma mark - Lifecycle

- (instancetype)initWithType:(FeatureType)type {
    if (self = [super init]) {
        self.type = type;
        self.sectionType = FeaturesSectionFun;
        self.state = FeaturesStateEnabled;
        self.title = nil;
        self.information = nil;
        self.imageNameOrUrl = nil;
        self.dataSource = nil;
        self.storeProductID = nil;
        self.storeProductPrice = nil;
        
        switch (type) {
            case FeatureTypeNone:
                break;
                
            case FeatureTypeEmojiKeypad:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Emoji";
                self.information = @"Classic emoji pack";
                self.imageNameOrUrl = @"feature_emojikeypad_icon";
                break;
                
            case FeatureTypeGif:
            case FeatureTypeGif_im:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"GIFS";
                self.information = @"Share animated gifs";
                self.imageNameOrUrl = @"feature_giphy_icon";
                break;
                
            case FeatureTypeSticker:
            case FeatureTypeSticker_im:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Imoji";
                self.information = @"Thousands of stickers";
                self.imageNameOrUrl = @"feature_imoji_icon";
                break;
                
            case FeatureTypeMojiSMPepsi:
                self.sectionType = FeaturesSectionFun;
                self.title = @"PepsiMoji";
                self.information = @"Have fun, talk less and say more";
                self.imageNameOrUrl = @"feature_mojism_pepsi_icon";
                break;
                
            case FeatureTypeMojiSMBurgerKing:
                self.sectionType = FeaturesSectionFun;
                self.title = @"BurgerKing Moji";
                self.information = @"Express yourself with chicken fries emojis";
                self.imageNameOrUrl = @"feature_mojism_burgerking_icon";
                break;
                
            case FeatureTypeMojiSMDelish:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Delish Eatmoji";
                self.information = @"Eat your feelings";
                self.imageNameOrUrl = @"feature_mojism_delish_icon";
                break;
                
            case FeatureTypeMojiSMHarpers:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Harper’s Bazaar Emoji";
                self.information = @"Because fashion is beyond words";
                self.imageNameOrUrl = @"feature_mojism_harpers_icon";
                break;
                
            case FeatureTypeMojiSMVodafone:
                self.sectionType = FeaturesSectionFun;
                self.title = @"BeStrong by Vodafone";
                self.information = @"Take a stand to show you are against cyberbullying";
                self.imageNameOrUrl = @"feature_mojism_vodafone_icon";
                break;
                
            case FeatureTypeMojiSMCosmopolitan:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Cosmopolitan";
                self.information = @"Rose, Cheese fries, Birth Control and more Sexy emojis";
                self.imageNameOrUrl = @"feature_mojism_cosmopolitan_icon";
                break;
                
            case FeatureTypeYelp:
                self.sectionType = FeaturesSectionSearch;
                self.title = @"Places";
                self.information = @"Search for local places and restaurants";
                self.imageNameOrUrl = @"feature_yelp_icon";
                self.storeProductID = @"net.hyperkey.yelp";
                break;
                
            case FeatureTypeDropbox:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Files";
                self.information = @"Search and share files with one tap";
                self.imageNameOrUrl = @"feature_dropbox_icon";
                self.storeProductID = @"net.hyperkey.dropbox";
                break;
                
            case FeatureTypeGoogleDrive:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Google Drive";
                self.information = @"Search and share your documents";
                self.imageNameOrUrl = @"feature_gdrive_icon";
                self.storeProductID = @"net.hyperkey.googledrive";
                break;
                
            case FeatureTypeInstagram:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Instagram";
                self.information = @"Share your Instagram photos";
                self.imageNameOrUrl = @"feature_instagram_icon";
                self.storeProductID = @"net.hyperkey.instagram";
                break;
                
            case FeatureTypeFacebook:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Facebook";
                self.information = @"Share your Facebook photos";
                self.imageNameOrUrl = @"feature_facebook_icon";
                break;
                
            case FeatureTypeDrawImage:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Sketchpad";
                self.information = @"Sketch and send drawings";
                self.imageNameOrUrl = @"feature_sketchpad_icon";
                break;
                
            case FeatureTypeSpotify:
                self.sectionType = FeaturesSectionSearch;
                self.title = @"Spotify";
                self.information = @"Search and share music";
                self.imageNameOrUrl = @"feature_spotify_icon";
                self.storeProductID = @"net.hyperkey.spotify";
                break;
                
            case FeatureTypeGoogleTranslate:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Translator";
                self.information = @"Translate text into a different language as you type";
                self.imageNameOrUrl = @"feature_translator_icon";
                self.storeProductID = @"net.hyperkey.googletranslate";
                break;
                
            case FeatureTypeShareLocation:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Share Location";
                self.information = @"Instantly send your current address";
                self.imageNameOrUrl = @"feature_geolocation_icon";
                break;
                
            case FeatureTypePhotoLibrary:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Photos";
                self.information = @"Instant access to your iOS photos";
                self.imageNameOrUrl = @"feature_photos_icon";
                break;
                
            case FeatureTypeAppURL:
                break;
                
            case FeatureTypeYoutube:
                self.sectionType = FeaturesSectionSearch;
                self.title = @"Videos";
                self.information = @"Search and share your favorite videos";
                self.imageNameOrUrl = @"feature_youtube_icon";
                self.storeProductID = @"net.hyperkey.youtube";
                break;
                
            case FeatureTypeEbay:
                self.sectionType = FeaturesSectionSearch;
                self.title = @"Ebay";
                self.information = @"Quick access to your items and store";
                self.imageNameOrUrl = @"feature_ebay_icon";
                self.storeProductID = @"net.hyperkey.ebay";
                break;
                
            case FeatureTypeMeme:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Memes";
                self.information = @"Express yourself in a quick and sharp way";
                self.imageNameOrUrl = @"feature_meme_icon";
                break;
                
            case FeatureTypeMemeGenerator:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Memes Creator";
                self.information = @"Create your own funny memes";
                self.imageNameOrUrl = @"feature_memegenerator_icon";
                break;
                
            case FeatureTypeMinions:
                self.sectionType = FeaturesSectionFun;
                self.title = @"Minion Translator";
                self.information = @"Translate from English to Minion Speak. Yi kai banana!";
                self.imageNameOrUrl = @"feature_minion_icon";
                break;
                
            case FeatureTypeFrequentlyUsedPhrases:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Acronym Creator";
                self.information = @"Tap an expression and convert it. (OMG and WTF)";
                self.imageNameOrUrl = @"feature_acronym_icon";
                break;
                
            case FeatureTypeSoundsCatalog:
                self.sectionType = FeaturesSectionSoundsCatalog;
                self.title = @"Soundboard";
                self.information = @"Share funny sounds when you chat";
                self.imageNameOrUrl = @"feature_soundboard_icon";
                break;
                
            case FeatureTypeCamFind:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"CamFind";
                self.information = @"Search the physical world.";
                self.imageNameOrUrl = @"feature_camfind_icon";
                break;
            case FeatureTypeAmazon:
                self.sectionType = FeaturesSectionProductivity;
                self.title = @"Amazon";
                self.information = @"Amazon shopping.\nAs an Amazon Associate HyperKey earns from qualifying purchases";
                self.imageNameOrUrl = @"feature_amazon_icon";
                break;
            case FeatureTypeRecentShared:
                break;
                
            case FeatureTypeTwitch:
                self.sectionType = FeaturesSectionSearch;
                self.title = @"Twitch";
                self.information = @"A live streaming video platform";
                self.imageNameOrUrl = @"feature_twitch_icon";
                break;
                
            case FeatureTypeFeedFriends:
            case FeatureTypeFeedFriends_im:
                break;
                
            case FeatureTypeGifCamera:
            case FeatureTypeGifCamera_im:
                self.sectionType = FeaturesSectionGifCamera;
                self.title = @"Gif Camera";
                self.information = @"The eastest way to create \"selfie\" animated gifs";
                self.imageNameOrUrl = @"feature_gifcamera_icon";
                break;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; type = %@; stype = %@; dataSource = %@", [super description], [self typeDescription], kSectionNameForType(self.sectionType), (self.dataSource) ? : @"default"];
}


#pragma mark - Public

- (BOOL)isImageFromResources {
    BOOL result = YES;
    if ([self.imageNameOrUrl rangeOfString:@"."].location != NSNotFound) {
        result = NO;
    }
    
    return result;
}

- (BOOL)isSameTo:(KeyboardFeature *)otherFeature {
    return ((self.sectionType == otherFeature.sectionType) && (self.type == otherFeature.type) && (((self.dataSource) && (otherFeature.dataSource) && ([self.dataSource isEqualToString:otherFeature.dataSource])) || ((!self.dataSource) && (!otherFeature.dataSource))));
}

- (NSString *)typeDescription {
    NSString *result = nil;
    if (self.type == FeatureTypeNone) {
        result = @"<+>";
    } else if (self.type == FeatureTypeAppURL) {
        result = @"Share Url";
    } else {
        result = self.title;
    }
    
    return result;
}

@end

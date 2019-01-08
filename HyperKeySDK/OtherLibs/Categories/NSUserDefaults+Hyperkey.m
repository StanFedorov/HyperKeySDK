//
//  NSUserDefaults+Hyperkey.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 26.04.16.
//
//

#import "NSUserDefaults+Hyperkey.h"

#import "Config.h"

@implementation NSUserDefaults (Hyperkey)

+ (void)setupDefaultValues {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    
    if (![defaults objectForKey:kUserDefaultsKey]) {
        [defaults setObject:@(YES) forKey:kUserDefaultsKey];
        [defaults setObject:@(YES) forKey:kUserDefaultsSettingWordSuggestions];
        [defaults setObject:@(YES) forKey:kUserDefaultsSettingWordAutocorrections];
        [defaults setObject:@(YES) forKey:kUserDefaultsSettingQuickPeriod];
        [defaults setObject:@(YES) forKey:kUserDefaultsSettingAutoCapitalize];
        [defaults setObject:@(NO) forKey:kUserDefaultsSettingKeyClickSounds];
        [defaults setObject:@(NO) forKey:kUserDefaultsSettingQuickEmojiKey];
        [defaults setObject:@(YES) forKey:kUserDefaultsSettingAllowGifStripe];
        [defaults setBool:NO forKey:kUserDefaultsSettingMainKeyboard];
        [defaults setInteger:KBThemeClassic forKey:kUserDefaultsKeyboardTheme];
        
        [defaults setObject:@(EmojiSkinToneTanned) forKey:kUserDefaultsSettingEmojiSkinTone];
        
        [defaults setInteger:0 forKey:kUserDefaultsAppRunCount];
        
        [defaults synchronize];
    }
}

@end

//
//  GTViewController.h
//  Better Word
//
//  Created by Sergey Vinogradov on 06.01.16.
//
//

#import "GTTranslatorDelegate.h"
#import "HKKeyboardViewController.h"

@interface GTViewController : BaseVC

@property (weak, nonatomic) id<GTTranslatorDelegate, KeyboardContainerDelegate> delegate;
@property (assign, nonatomic) BOOL isItFirstStart;

@property (strong, nonatomic) NSString *originText;
@property (strong, nonatomic) NSString *translatedText;

@property (assign, nonatomic) BOOL weAreOnline;
@property (strong, nonatomic) NSArray *languagesList;
@property (assign, nonatomic) BOOL isItTranslatedPasteboard;

- (void)stopCheckingPasteboard;
- (void)checkLanguageSelector;
- (void)textInInputDidEnd;

@end

//
//  GTTranslatorDelegate.h
//  Better Word
//
//  Created by Sergey Vinogradov on 14.04.16.
//
//

#import "BaseVC.h"

@protocol GTTranslatorDelegate <KeyboardContainerDelegate>

- (void)changeOriginText:(NSString *)origin forTranslatedText:(NSString *)translated;

@optional
- (void)textDidTranslated:(NSString *)translatedText;

@end

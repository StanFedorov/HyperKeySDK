//
//  ThemeChangesResponderProtocol.h
//  Better Word
//
//  Created by Sergey Vinogradov on 11.03.16.
//
//

#import "Config.h"

@protocol ThemeChangesResponderProtocol <NSObject>

@required
- (void)setTheme:(KBTheme)theme;

@end

//
//  Macroses.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 08.01.16.
//
//

// Devices
#define IS_IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0)
#define IS_IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] > 10.0)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) == 667.0)
#define IS_IPHONE_6_PLUS (IS_IPHONE && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) == 736.0)
#define IS_IPADPRO (IS_IPAD && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) > 1024)
#define IS_IPHONE_X (IS_IPHONE && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) == 812.0)
#define IS_IPHONE_X_MAX (IS_IPHONE && MAX(SCREEN_WIDTH, SCREEN_HEIGHT) == 896.0)

// Scale
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_SCALE ([UIScreen mainScreen].scale)

#define AUTO_SCALE_FACTOR (IS_IPHONE_6_PLUS ? (736.0 / 568.0) : (IS_IPHONE_6 ? (667.0 / 568.0) : 1))
#define AUTO_SCALE(size) roundf(AUTO_SCALE_FACTOR * (CGFloat)size)
#define MANUAL_SCALE(iPhone5Size, iPhone6Size, iPhone6PSize) (IS_IPHONE_6_PLUS ? iPhone6PSize : (IS_IPHONE_6 ? iPhone6Size : iPhone5Size))

// Color
#define RGBA(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]
#define RGB(r, g, b) RGBA(r, g, b, 1)
#define HEX(rgbValue) RGB((rgbValue & 0xFF0000) >> 16), (rgbValue & 0x00FF00) >>  8), (rgbValue & 0x0000FF))

// Segue
#define IB_SEGUE(value) [NSString stringWithFormat:@"Segue%@", NSStringFromClass([value class])]
#define IB_SHOW_SEGUE(value) [self performSegueWithIdentifier:IB_SEGUE(value) sender:nil]

//
//  HProgress.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 09.01.16.
//
//

#import "MBProgressHUD.h"
#import "Macroses.h"

// Default mode: MBProgressHUDModeCustomView

typedef NS_ENUM(NSInteger, HProgressHUDSizeType) {
    HProgressHUDSizeTypeSmall, // Default
    HProgressHUDSizeTypeSmallWhite,
    HProgressHUDSizeTypeBig,
    HProgressHUDSizeTypeBigWhite,
    HProgressHUDSizeTypeSystemSmall,
};

@interface HProgressHUD : MBProgressHUD

@property (assign, nonatomic, readonly) BOOL isAnimating;
@property (assign, nonatomic) HProgressHUDSizeType sizeType;

+ (instancetype)showHUDSizeType:(HProgressHUDSizeType)sizeType addedTo:(UIView *)view animated:(BOOL)animated;

@end

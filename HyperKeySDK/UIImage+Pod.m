//
//  UIImage+Pod.m
//  HyperKeySDK
//
//  Created by Stanislav Fedorov on 08/01/2019.
//  Copyright © 2019 Stanislav Fedorov. All rights reserved.
//

#import "UIImage+Pod.h"

@implementation UIImage (Pod)

+ (UIImage *)imageNamedPod:(NSString *)name {
    return [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:NSClassFromString(@"HKKeyboardViewController")] compatibleWithTraitCollection:nil];
}


@end

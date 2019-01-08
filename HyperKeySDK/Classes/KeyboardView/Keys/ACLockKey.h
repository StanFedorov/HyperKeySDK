//
//  ACLockKey.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 8/17/14.
//
//

#import "ACKey.h"

@interface ACLockKey : ACKey

@property (assign, nonatomic, getter = isLocked) BOOL locked;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *lockImage;

@end

//
//  ACActivatedKey.h
//  Better Word
//
//  Created by Sergey Vinogradov on 24.03.16.
//
//

#import "ACKey.h"

@interface ACActivatedKey : ACKey

@property (strong, nonatomic) UIImage *imageActive;
@property (strong, nonatomic) UIImage *imageInactive;

- (void)setActiveImage:(UIImage *)imageActive andInactiveImage:(UIImage *)imageNonactive;

@end

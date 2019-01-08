//
//  ACKeyMat.m
//  Better Word
//
//  Created by Sergey Vinogradov on 03.03.16.
//
//

#import "ACKeyMat.h"
#import "ACKey.h"

@implementation ACKeyMat

+ (instancetype)matForKey:(ACKey *)key {
    ACKeyMat *mat = [[self alloc] initWithKey:key];
    return mat;
}

- (instancetype)initWithKey:(ACKey *)key {
    self = [super init];
    if (self) {
        self.key = key;
        if (key.allTargets.count == 1) {
            NSArray *arr = [key actionsForTarget:key.allTargets.anyObject forControlEvent:key.allControlEvents];
            SEL action = NSSelectorFromString(((NSString *)arr.firstObject));
            [self addTarget:key.allTargets.anyObject action:action forControlEvents:key.allControlEvents];
        }
    }
    return self;
}


#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (self.key && [self.key respondsToSelector:@selector(touchesBegan:withEvent:)]) {
        [self.key touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // TODO: Break when "location in view:" not actually inside view
    [super touchesMoved:touches withEvent:event];
    
    if (self.key && [self.key respondsToSelector:@selector(touchesMoved:withEvent:)]) {
        [self.key touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.key && [self.key respondsToSelector:@selector(touchesEnded:withEvent:)]) {
        [self.key touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.key && [self.key respondsToSelector:@selector(touchesCancelled:withEvent:)]) {
        [self.key touchesCancelled:touches withEvent:event];
    }
}

@end

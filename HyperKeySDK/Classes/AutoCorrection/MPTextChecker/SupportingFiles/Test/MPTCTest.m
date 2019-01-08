//
//  MPTCTest.m
//  ACFastMemory
//
//  Created by Maxim Popov popovme@gmail.com on 30.03.16.
//  Copyright © 2016 Popovme. All rights reserved.
//

#import "MPTCTest.h"

#import "ACCharacterOperation.h"

NSString * const kMPTCTestCorrectFileName = @"mptc_test_correct";
NSUInteger const kMPTCTestMaxLevel = 2;
NSUInteger const kMPTCTestMaxRepatCount = 1;

@interface MPTCTest ()

@property (nonatomic, strong) MPTextChecker *textChecker;
@property (nonatomic, strong) NSMutableDictionary *samples;
@property (nonatomic, assign) NSUInteger level;

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, assign) NSUInteger repeatCount;

@property (atomic, strong) NSOperationQueue *correctionQueue;

@end

@implementation MPTCTest

#pragma mark - Public

- (void)runWithLevel:(NSUInteger)level {
    NSCParameterAssert(level > 0);
    
    self.level = level;
    
    self.repeatCount = 1;
    
    self.correctionQueue = [[NSOperationQueue alloc] init];
    self.correctionQueue.maxConcurrentOperationCount = 1;
    self.correctionQueue.qualityOfService = NSQualityOfServiceBackground;
    
    self.samples = [[NSMutableDictionary alloc] init];
    
    self.textChecker = [[MPTextChecker alloc] init];
    [self.textChecker initializeLanguage:@"en_US" dataCreation:YES completion:^{
        NSLog(@"Test Started");
        self.time = [NSDate date];
        [self addOperationsWithFileName:kMPTCTestCorrectFileName];
    }];
}


#pragma mark - Work

- (void)addOperationsWithFileName:(NSString *)fileName {
    NSArray *lines = [self linesFromFileName:fileName];
    [lines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *values = [self valuesFromLine:line];
        NSUInteger count = values.count;
        if (line.length > 0 && (count < 2 || count > (kMPTCTestMaxLevel + 1))) {
            NSLog(@"WARNING: Incorrect Test Data, line: %@", line);
            return;
        }
        
        NSString *text = values[0];
        NSMutableArray *corrects = [[NSMutableArray alloc] initWithCapacity:count - 1];
        for (NSInteger i = 1; i < count; i ++) {
            [corrects addObject:values[i]];
        }
        
        self.samples[text] = corrects;
    }];
    
    NSArray *texts = [self.samples allKeys];
    
    [texts enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
        ACCharacterOperation *operation = [[ACCharacterOperation alloc] initWithTextChecker:self.textChecker text:text];
        
        __weak __typeof(self)weakSelf = self;
        operation.willCompletionBlock = ^(NSString *text, NSString *original, MPTCString *correction, NSArray *other) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                NSArray *corrections = nil;
                if (correction) {
                    corrections = [@[correction] arrayByAddingObjectsFromArray:other];
                } else {
                    corrections = other;
                }
                [strongSelf checkWithText:text corrections:corrections];
            }
        };
        
        [self.correctionQueue addOperation:operation];
    }];
}

- (void)checkWithText:(NSString *)text corrections:(NSArray *)corrections {
    NSArray *samples = self.samples[text];
    
    BOOL success = YES;
    NSUInteger maxLength = 0;
    
    NSInteger count = MIN(self.level, samples.count);
    for (NSInteger i = 0; i < count; i++) {
        NSString *sample = samples[i];
        MPTCString *correct = i < corrections.count ? corrections[i] : nil;
        if (![sample isEqualToString:correct.string]) {
            success = NO;
        }
        if (sample.length > maxLength) {
            maxLength = sample.length;
        }
    }
    if (text.length > maxLength) {
        maxLength = text.length;
    }
    
    if (!success) {
        NSString *format = [NSString stringWithFormat:@"T: %%-%@s | V: %%-%@s | X: %%@", @(maxLength), @(maxLength)];
        for (NSInteger i = 0; i < count; i ++) {
            NSString *sample = samples[i];
            MPTCString *correct = i < corrections.count ? corrections[i] : nil;
            NSLog(format, [text UTF8String], [sample UTF8String], correct);
        }
    }
    
    if (self.correctionQueue.operationCount == 1) {
        
        if (self.repeatCount < kMPTCTestMaxRepatCount) {
            self.repeatCount ++;
            [self addOperationsWithFileName:kMPTCTestCorrectFileName];
        } else {
            NSLog(@"Test Finished, time: %.3f", -[self.time timeIntervalSinceNow]);
        }
    }
}

- (NSArray *)linesFromFileName:(NSString *)fileName {
    NSString *filePath = [[NSBundle bundleForClass:NSClassFromString(@"HKKeyboardViewController")] pathForResource:fileName ofType:@"txt"];
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    fileContents = [fileContents stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

- (NSArray *)valuesFromLine:(NSString *)line {
    NSString *trimLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [trimLine componentsSeparatedByString:@"|"];
}

@end

//
//  LoadFileDataOperation.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 31.08.16.
//
//

#import "LoadFileDataOperation.h"

@interface LoadFileDataOperation ()

@property (strong, nonatomic, readwrite) NSString *filePath;
@property (strong, nonatomic, readwrite) NSIndexPath *indexPath;

@end

@implementation LoadFileDataOperation

#pragma mark - Public

- (instancetype)initWithFilePath:(NSString *)filePath indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (self) {
        self.filePath = filePath;
        self.indexPath = indexPath;
    }
    return self;
}


#pragma mark - Main

- (void)main {
    NSData *data = nil;
    
    if (self.filePath) {
        data = [NSData dataWithContentsOfFile:self.filePath];
    }
    
    if (self.willCompletionBlock) {
        self.willCompletionBlock(data);
    }
}

@end

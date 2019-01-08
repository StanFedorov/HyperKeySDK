//
//  LoadDataOperation.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 31.08.16.
//
//

#import "LoadURLDataOperation.h"

@interface LoadURLDataOperation ()

@property (strong, nonatomic, readwrite) NSString *urlString;
@property (strong, nonatomic, readwrite) NSIndexPath *indexPath;

@end

@implementation LoadURLDataOperation

#pragma mark - Bublic

- (instancetype)initWithURLSting:(NSString *)urlString indexPath:(NSIndexPath *)indexPath {
    self = [super init];
    if (self) {
        self.urlString = urlString;
        self.indexPath = indexPath;
    }
    return self;
}


#pragma mark - Main

- (void)main {
    NSData *data = nil;
    
    if (self.urlString) {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.urlString]];
    }
    
    if (self.willCompletionBlock) {
        self.willCompletionBlock(data);
    }
}

@end

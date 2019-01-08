//
//  DropBoxImageLoader.m
//  DropBox
//
//  Created by Dmitriy gonchar on 10/19/15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import "DropBoxImageLoader.h"

/*#import <DropboxSDK/DropboxSDK.h>

@interface DropBoxImageLoader () <DBRestClientDelegate>

@property (strong, nonatomic) DBRestClient *restClient;
@property (copy, nonatomic) ResponceBlockWithError result;

@end

@implementation DropBoxImageLoader

- (void)loadDropThumbnailByPath:(NSString *)path withCompletion:(void (^)(id, NSError *))completion {
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    self.result = ^(id object, NSError * error) {
        if (completion) completion (object, error);
    };
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@%@", documentsDirectory, path];
    [self.restClient loadThumbnail:path ofSize:@"m" intoPath:fileName];
}


#pragma mark - RestClient delegate

- (void)restClient:(DBRestClient *)client loadedThumbnail:(NSString *)destPath metadata:(DBMetadata *)metadata {
    UIImage *savedImage = [UIImage imageWithContentsOfFile:destPath];
    
    self.result(savedImage, nil);
}

- (void)restClient:(DBRestClient *)client loadThumbnailFailedWithError:(NSError *)error {
    self.result(nil, error);
}

@end*/

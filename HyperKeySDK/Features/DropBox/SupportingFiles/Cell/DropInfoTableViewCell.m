//
//  DropInfoTableViewCell.m
//  DropBox
//
//  Created by Dmitriy Gonchar on 18.10.15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import "DropInfoTableViewCell.h"
#import "KeyboardFeaturesAuthenticationManager.h"
#import "UIImage+Pod.h"

@interface DropInfoTableViewCell ()
@property (nonatomic,strong) DBUserClient *client;
@end

@implementation DropInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dropFileImageView.image = nil;
    self.dropFileImageView.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *dropTokenInfo = [[KeyboardFeaturesAuthenticationManager sharedManager] authorizationObjectForFeatureType:FeatureTypeDropbox];
    self.client = [[DBUserClient alloc] initWithAccessToken:dropTokenInfo[0]];
}


#pragma mark - Load Image

- (void)loadDropThumbnailByPath:(NSString *)path andFileName:(NSString *)fileName {
  //  [self.restClient cancelAllRequests];
    
    if (self.shouldLoadImages) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
        
        if (self.isFolder) {
            self.dropFileImageView.image = [UIImage imageNamed:@"dropbox_folder"];
            self.dropFileImageView.contentMode = UIViewContentModeCenter;
        } else if ([self.fileData.name containsString:@".zip"] || [self.fileData.name containsString:@".rar"]) {
            self.dropFileImageView.image = [UIImage imageNamed:@"dropbox_archive"];
            self.dropFileImageView.contentMode = UIViewContentModeCenter;
        } else {
            UIImage *savedImage = [UIImage imageWithContentsOfFile:filePath];
            if (savedImage) {
                self.dropFileImageView.image = savedImage;
                self.dropFileImageView.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                self.dropFileImageView.image = [UIImage imageNamed:@"dropbox_file"];
                self.dropFileImageView.contentMode = UIViewContentModeCenter;
            //    [self loadThumbnail:self.fileData.pathDisplay];
          //      [self.restClient loadThumbnail:path ofSize:@"m" intoPath:filePath];
            }
        }
    } else {
        self.dropFileImageView.image = nil;
    }
}

- (void) loadThumbnail:(NSString*)path {
    [[self.client.filesRoutes getThumbnailData:path]
     setResponseBlock:^(id result, DBFILESCreateFolderError *routeError, DBRequestError *networkError, NSData *imageData) {
         if (result) {
             UIImage *savedImage = [UIImage imageWithData:imageData];
             self.dropFileImageView.image = savedImage;
             self.dropFileImageView.contentMode = UIViewContentModeScaleAspectFit;
         }
     }];
}
/*#pragma mark - RestClient delegate

- (void)restClient:(DBRestClient *)client loadedThumbnail:(NSString *)destPath metadata:(DBMetadata *)metadata {
    UIImage *savedImage = [UIImage imageWithContentsOfFile:destPath];
    self.dropFileImageView.image = savedImage;
    self.dropFileImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)restClient:(DBRestClient *)client loadThumbnailFailedWithError:(NSError *)error {
    self.dropFileImageView.image = [UIImage imageNamed:@"dropbox_file"];
    self.dropFileImageView.contentMode = UIViewContentModeCenter;
}
*/
@end


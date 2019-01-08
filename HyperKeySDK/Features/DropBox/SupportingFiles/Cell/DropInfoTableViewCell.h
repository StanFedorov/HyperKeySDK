//
//  DropInfoTableViewCell.h
//  DropBox
//
//  Created by Dmitriy Gonchar on 18.10.15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

#import "DropBoxImageLoader.h"

@interface DropInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView * dropFileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileDateLabel;
@property (weak, nonatomic) IBOutlet UIView *hoverView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileSizeLabelWidthConstarint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *namePadding;

@property (strong, nonatomic) DBFILESMetadata *fileData;
@property (strong, nonatomic) DBFILESFolderMetadata *folderData;

@property (assign, nonatomic) BOOL shouldLoadImages;
@property (assign, nonatomic) BOOL isFolder;

- (void)loadDropThumbnailByPath:(NSString *)path andFileName:(NSString *)fileName;

@end

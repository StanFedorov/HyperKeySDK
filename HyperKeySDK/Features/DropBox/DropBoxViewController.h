//
//  ViewController.h
//  DropBox
//
//  Created by Dmitriy Gonchar on 18.10.15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import "BaseDropAndDriveViewController.h"

@interface DropBoxViewController : BaseDropAndDriveViewController
- (void)performSearch:(NSString*)query;
- (void)setLastSearch:(NSString *)search;
@property (strong, nonatomic) NSString *filePath;

@end


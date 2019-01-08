//
//  BaseDropAndDriveViewController.h
//  DropBox
//
//  Created by Dmitriy Gonchar on 20.10.15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import "BaseVC.h"

@interface BaseDropAndDriveViewController : BaseVC

@property (weak, nonatomic) id<KeyboardContainerDelegate,UITextFieldIndirectDelegate> delegate;
@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (strong, nonatomic, readonly) NSDateFormatter *dateFormatterWithDate;

- (NSDate *)onlyMonthAndYearDate:(NSDate *)oldDate;

@end

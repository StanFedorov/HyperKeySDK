//
//  BaseDropAndDriveViewController.m
//  DropBox
//
//  Created by Dmitriy Gonchar on 20.10.15.
//  Copyright (c) 2015 Dmitriy Gonchar. All rights reserved.
//

#import "BaseDropAndDriveViewController.h"

@interface BaseDropAndDriveViewController ()

@property (strong, nonatomic, readwrite) NSDateFormatter *dateFormatter;
@property (strong, nonatomic, readwrite) NSDateFormatter *dateFormatterWithDate;

@property (strong, nonatomic) NSCalendar *calendar;

@end

@implementation BaseDropAndDriveViewController

@synthesize delegate;

#pragma mark - Propery Private

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _calendar;
}


#pragma mark - Property

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MMMM yyyy"];
    };
    return _dateFormatter;
}

- (NSDateFormatter *)dateFormatterWithDate {
    if (!_dateFormatterWithDate) {
        _dateFormatterWithDate = [[NSDateFormatter alloc] init];
        [_dateFormatterWithDate setDateFormat:@"dd MMMM yyyy"];
    };
    return _dateFormatterWithDate;
}


#pragma mark - Public

- (NSDate *)onlyMonthAndYearDate:(NSDate *)oldDate {
    NSDateComponents *components = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:oldDate];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.day = 0;
    comps.month = components.month;
    comps.year = components.year;
    comps.hour = 0;
    comps.minute = 0;
    comps.second = 0;
    
    NSDate *date = [[self calendar] dateFromComponents:comps];
    
    //NSLog(@"oldDate: %@ newDate: %@", oldDate, date);
    
    return date;
}

@end

//
//  ExtendedBaseVC.m
//  Better Word
//
//  Created by Sergey Vinogradov on 19.05.16.
//
//

#import "ExtendedBaseVC.h"

NSString *const kSearchFieldImageNameShow = @"btn_search_field";
NSString *const kSearchFieldImageNameHide = @"btn_search_field_hide";

@implementation ExtendedBaseVC

@synthesize delegate;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.showKeyboardButton addTarget:self action:@selector(showKeyboardButtonTap:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)keyboardDidDisappear {
    NSAssert(NO, @"Subclasses need to overwrite keyboardDidDisappear method");
}

- (void)showKeyboardButtonTap:(id)sender {
    NSAssert(NO, @"Subclasses need to overwrite showKeyboardButtonTap: method");
}

@end

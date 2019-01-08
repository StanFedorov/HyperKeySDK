//
//  UIScreen+Orientation.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSData *)data;
- (NSString *)sha256;
- (NSString *)MD5;
- (NSData *)base64DecodedData;
- (NSString *)base64EncodedString;

@end

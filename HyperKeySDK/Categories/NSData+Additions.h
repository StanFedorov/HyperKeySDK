//
//  NSData+Additions.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import <Foundation/Foundation.h>

@interface NSData (Additions)

- (NSString *)string;
- (NSString *)base64EncodedString;
- (NSData *)base64DecodedData;
- (NSData *)sha256;

@end

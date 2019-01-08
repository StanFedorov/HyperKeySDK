//
//  NSString+Additions.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import "NSString+Additions.h"
#import "NSData+Additions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Additions)

- (NSData *)data {
	return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)sha256 {
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char sha256Buffer[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(data.bytes, (unsigned int)data.length, sha256Buffer);
	NSMutableString *result  = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH << 1];
	for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
		[result appendString:[NSString stringWithFormat:@"%02x", sha256Buffer[i]]];
	}
	return [result copy];
}

- (NSString *)MD5 {
    const char *pointer = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}

- (NSData *)base64DecodedData {
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64DecodedData];
}

- (NSString *)base64EncodedString {
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

@end

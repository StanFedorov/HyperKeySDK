//
//  NSData+Additions.h
//  ACKeyboard
//
//  Created by Arnaud Coomans on 11/2/14.
//
//

#import "NSData+Additions.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <zlib.h>

@implementation NSData (Additions)

- (NSString *)string {
	return [[NSString alloc] initWithBytes:self.bytes length:self.length encoding:NSUTF8StringEncoding];
}

- (NSString *)base64EncodedString {
	return [self base64EncodedStringWithOptions:0];
}

- (NSData *)base64DecodedData {
	return [[NSData alloc] initWithBase64EncodedData:self options:0];
}

- (NSData *)sha256 {
	unsigned char sha256Buffer[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(self.bytes, (unsigned int)self.length, sha256Buffer);
	return [NSData dataWithBytes:sha256Buffer length:CC_SHA256_DIGEST_LENGTH];
}

@end

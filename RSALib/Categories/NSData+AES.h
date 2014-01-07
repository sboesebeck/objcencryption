//
//  NSData+AESCrypt.h
//  EncryptedChat
//
//  Created by Stephan Bösebeck on 03.09.13.
//  Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (AESCrypt)

- (NSData *)AES256EncryptWithKey:(NSString *)key;

- (NSData *)AES256DecryptWithKey:(NSString *)key;

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;

- (id)initWithBase64EncodedString:(NSString *)string;

- (BOOL)hasPrefixBytes:(const void *)prefix length:(NSUInteger)length;

- (BOOL)hasSuffixBytes:(const void *)suffix length:(NSUInteger)length;
@end

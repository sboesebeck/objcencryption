//
// Created by Stephan Bösebeck on 07.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AES : NSObject
- (char *)encryptBlock:(char *)plain;

- (char *)decryptBlock:(char *)cipher;

- (void)setEncryptionKey:(NSData *)key;

- (NSData *)encrypt:(NSData *)data;

- (NSData *)decrypt:(NSData *)data;
@end
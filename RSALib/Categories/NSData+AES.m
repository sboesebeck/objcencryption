//
//  NSData+AESCrypt.m
//  EncryptedChat
//
//  Created by Stephan Bösebeck on 03.09.13.
//  Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//

#import "NSData+AES.h"
#import "AES.h"


@implementation NSData (AESCrypt)

- (NSData *)AES256EncryptWithKey:(NSData *)key {
    AES *aes = [[AES alloc] init];
    [aes setEncryptionKey:key];
    return [aes encrypt:self];
}

- (NSData *)AES256DecryptWithKey:(NSData *)key {
    AES *aes = [[AES alloc] init];
    [aes setEncryptionKey:key];
    return [aes decrypt:self];

}

@end

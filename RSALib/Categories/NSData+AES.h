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

@end

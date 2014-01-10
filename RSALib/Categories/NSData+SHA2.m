//
// Created by Stephan Bösebeck on 10.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import "NSData+SHA2.h"
#import "SHA2.h"

@implementation NSData (SHA2)
- (NSData *)sha2 {
    SHA2 *sha = [[SHA2 alloc] init];
    [sha setup];
    [sha engineUpdate:self.bytes off:0 len:self.length];
    char *dig = [sha engineDigest];

    return [[NSData alloc] initWithBytes:dig length:64];
}

- (NSData *)sha2OfBitLen:(int)len {
    SHA2 *sha = [[SHA2 alloc] init];
    [sha setup];
    [sha engineUpdate:self.bytes off:0 len:self.length];
    char *dig = [sha engineDigestOfBitLen:len];

    return [[NSData alloc] initWithBytes:dig length:len / 8];
}

@end
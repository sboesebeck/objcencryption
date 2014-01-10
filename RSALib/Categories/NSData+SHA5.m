//
// Created by Stephan Bösebeck on 10.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import "NSData+SHA5.h"
#import "SHA5.h"

@implementation NSData (SHA5)
- (NSData *)sha5 {
    SHA5 *sha = [[SHA5 alloc] init];
    [sha setup];
    [sha engineUpdate:self.bytes off:0 len:self.length];
    char *dig = [sha engineDigest];

    return [[NSData alloc] initWithBytes:dig length:64];
}

@end
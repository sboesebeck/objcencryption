//
// Created by Stephan Bösebeck on 10.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (SHA2)
- (NSData *)sha2;

- (NSData *)sha2OfBitLen:(int)len;
@end
//
// Created by Stephan Bösebeck on 08.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SHA5 : NSObject
+ (NSData *)hash:(NSData *)data;

- (void)engineUpdate:(char)b;

- (void)engineUpdate:(char *)b off:(int)off len:(int)len;

- (void)setup;

- (void)setInitialHash:(int64_t *)values;

- (char *)engineDigest;

- (void)performDigest:(char *)hashvalue off:(int)offset len:(int)resultLength;
@end

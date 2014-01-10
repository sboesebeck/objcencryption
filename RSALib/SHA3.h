//
// Created by Stephan Bösebeck on 08.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHA2.h"


@interface SHA3 : SHA2
- (instancetype)initWithLength:(int)length;

+ (NSData *)createHashOf:(NSData *)data length:(int)l;
@end
//
// Created by Stephan Bösebeck on 09.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import "NSData+SHA3.h"


@implementation NSData (SHA3)
- (NSData *)sha3OfBitlen:(int)length {
    int l = length / 8;
    if (l != 32 && l != 64 && l != 48) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"Cant create SHA3 of given bitlen" userInfo:@{@"bitlen" : [NSNumber numberWithInt:length]}];
    }
    return [SHA3 createHashOf:self length:length / 8];
}
@end
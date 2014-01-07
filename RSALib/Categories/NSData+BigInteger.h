//
// Created by Stephan Bösebeck on 01.10.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface NSData (BigInteger)

+ (NSData *)serializeInts:(NSArray *)bigInts;

+ (NSData *)dataFromBigIntArray:(NSArray *)bigInts;

+ (NSData *)dataFromBigIntArray:(NSArray *)bigInts hasPrefix:(BOOL)prefix;

- (NSArray *)deSerializeInts;

- (NSArray *)getIntegersofBitLength:(int)bitLen;
@end
//
// Created by Stephan Bösebeck on 22.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface MPN : NSObject
+ (int64_t)add_1:(int64_t *)dest x:(int64_t *)x size:(int)size y:(int64_t)y;

+ (int64_t)add_n:(int64_t *)dest x:(int64_t *)x y:(int64_t *)y len:(int)len;

+ (int64_t)sub_n:(int64_t *)dest x:(int64_t *)X y:(int64_t *)Y size:(int64_t)size;

+ (int64_t)mul_1:(int64_t *)dest x:(int64_t *)x len:(int64_t)len y:(int64_t)y;

+ (void)mul:(int64_t *)dest x:(int64_t *)x xlen:(int64_t)xlen y:(int64_t *)y ylen:(int64_t)ylen;

+ (int64_t)udiv_qrnnd:(int64_t)N D:(int32_t)D;

+ (int64_t)divmod_1:(int64_t *)quotient divident:(int64_t *)dividend len:(int64_t)len divisor:(int64_t)divisor;

+ (int32_t)submul_1:(int64_t *)dest offset:(int64_t)offset x:(int64_t *)x len:(int64_t)len y:(int64_t)y;

+ (void)divide:(int64_t *)zds nx:(int)nx y:(int64_t *)y ny:(int)ny;

+ (int)chars_per_word:(int64_t)radix;

+ (int)count_leading_zeros:(int64_t)i;

+ (int64_t)set_str:(int64_t *)dest str:(int64_t *)str strLen:(int)str_len base:(int64_t)base;

+ (int)cmp:(int64_t *)x y:(int64_t *)y size:(int64_t)size;

+ (int)cmp:(int64_t *)x xlen:(int64_t)xlen y:(int64_t *)y ylen:(int64_t)ylen;

+ (int64_t)rshift:(int64_t *)dest x:(int64_t *)x x_start:(int)x_start len:(int)len count:(int)count;

+ (void)rshift0:(int64_t *)dest x:(int64_t *)x x_start:(int)x_start len:(int)len count:(int)count;

+ (int64_t)rshift_long:(int64_t *)x len:(int)len count:(int)count;

+ (int64_t)lshift:(int64_t *)dest d_offset:(int64_t)d_offset x:(int64_t *)x len:(int64_t)len count:(int64_t)count;

+ (int)findLowestBit:(int64_t)word;

+ (int)findLowestBitInArr:(int64_t *)words;

+ (int64_t)gcd:(int64_t *)x y:(int64_t *)y len:(int)len;

+ (int)intLength:(int64_t)i;

+ (int)intLength:(int64_t *)words len:(int64_t)len;
@end
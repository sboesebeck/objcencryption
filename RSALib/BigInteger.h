//
// Created by Stephan Bösebeck on 22.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#define MINFIXNUMS (int)-100
#define MAXFIXNUMS (int)1024
#define NUMFIXNUM MAXFIXNUMS - MINFIXNUMS -1


@interface BigInteger : NSObject

@property(nonatomic) int64_t *data;
//@property (nonatomic) int64_t dataSize;

/** All integers are stored in 2's-complement form.
    * If words == null, the ival is the value of this BigInteger.
    * Otherwise, the first ival elements of words make the value
    * of this BigInteger, stored in little-endian order, 2's-complement form. */
@property(nonatomic) int64_t iVal;
//@property(nonatomic, readonly) BOOL isSimple;

+ (int64_t *)allocData:(int)size;

+ (BigInteger *)fromBytes:(NSData *)dat atOffset:(int *)offset;

- (NSData *)bytes;

- (id)initWithData:(int64_t *)data iVal:(int64_t)size;

- (id)initWith:(int64_t)value;

+ (BigInteger *)randomBigInt:(int)bits;

+ (BigInteger *)bigIntegerWithBigInteger:(BigInteger *)b;

- (int)intValue;

- (int64_t)longValue;

- (void)getAbsolute:(int64_t *)words length:(int)wlen;

+ (void)divideBig:(BigInteger *)x by:(BigInteger *)y quotient:(BigInteger *)quotient remainder:(BigInteger *)remainder1 usingRoundingMode:(int)rounding_mode;

- (BigInteger *)negate;

+ (BigInteger *)times:(BigInteger *)x yBig:(BigInteger *)y;

- (BigInteger *)multiply:(BigInteger *)y;

- (BigInteger *)subtract:(BigInteger *)val;

+ (BigInteger *)add:(BigInteger *)x y:(BigInteger *)y k:(int64_t)k;

- (BigInteger *)add:(BigInteger *)val;

- (int)compareTo:(BigInteger *)val;

- (BigInteger *)divideBy:(BigInteger *)val;

- (BigInteger *)remainder:(BigInteger *)val;

- (NSArray *)divideAndRemainder:(BigInteger *)val;

- (BigInteger *)mod:(BigInteger *)m;

- (int)bitLength;

- (BOOL)isProbablePrime:(int)certainty;

+ (void)euclidInv:(BigInteger *)a b:(BigInteger *)b preDiv:(BigInteger *)prevDiv xy:(NSMutableArray *)xy;

- (void)pack;

- (BigInteger *)modInverse:(BigInteger *)y;

- (BigInteger *)modPow:(BigInteger *)exponent modulo:(BigInteger *)m;

- (BigInteger *)abs;

- (BigInteger *)gcd:(BigInteger *)y;

+ (BOOL)equals:(BigInteger *)x y:(BigInteger *)y;

- (BOOL)isEqualTo:(id)other;

- (id)initWithRandomBits:(int)numBits;

+ (BigInteger *)valueOf:(int64_t)val;

+ (BigInteger *)valueOf:(NSString *)s usingRadix:(int)radix;

- (BigInteger *)canonicalize;

- (BOOL)isNegative;

+ (BigInteger *)and:(BigInteger *)x y:(int64_t)y2;

- (BigInteger *)and:(BigInteger *)y;

- (BigInteger *)or:(BigInteger *)y2;

- (BigInteger *)xor:(BigInteger *)y;

- (BigInteger *)not;

- (BigInteger *)andNot:(BigInteger *)val;

- (BigInteger *)clearBit:(int64_t)n;

- (BigInteger *)setBit:(int64_t)n;

- (BOOL)testBit:(int64_t)n;

- (BigInteger *)flipBit:(int64_t)n;

- (BigInteger *)shiftLeft:(int64_t)n;

- (BigInteger *)shiftRight:(int64_t)n;

- (void)set:(int64_t)y;

- (int64_t)getLowestSetBit;

- (BOOL)isZero;

- (BOOL)isOne;

+ (BigInteger *)randomProbablePrime:(int)bitLength primeProbability:(int)certainty useThreads:(int)threads;

- (NSString *)getHex;

@end
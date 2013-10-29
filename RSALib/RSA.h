//
// Created by Stephan Bösebeck on 24.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class BigInteger;


@interface RSA : NSObject
@property(nonatomic, strong) BigInteger *n;
@property(nonatomic, strong) BigInteger *d;
@property(nonatomic, strong) BigInteger *e;
@property(nonatomic, readonly) int bitLen;
@property(nonatomic, strong) NSString *id;
@property(nonatomic, strong) NSData *privateKey;
@property(nonatomic, strong) NSData *publicKey;
@property(nonatomic, readonly) BOOL hasPublicKey;
@property(nonatomic, readonly) BOOL hasPrivateKey;

@property(nonatomic) int threads;

- (id)initWithBitLen:(int)bits;

- (id)initWithBitLen:(int)bits andThreads:(int)thr;

- (id)initWithN:(BigInteger *)n d:(BigInteger *)d e:(BigInteger *)e bitLen:(int)len;

+ (id)RSAFromBytes:(NSData *)data;

- (NSData *)bytes;

- (BOOL)isEqualTo:(id)other;

- (NSData *)encrypt:(NSData *)data;

- (NSData *)decrypt:(NSData *)data;

- (BigInteger *)encryptBigInteger:(BigInteger *)message;

- (BigInteger *)decryptBigInteger:(BigInteger *)message;

//Public Key is (n, e) and Private Key is (d, n).

- (NSData *)sign:(NSData *)clear;

- (BOOL)isValidSinged:(NSData *)signature message:(NSData *)message;
@end
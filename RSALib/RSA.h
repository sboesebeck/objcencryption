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

- (id)initWithBitLen:(int)bits andThreads:(int)thr andProgressBlock:(void (^)(int))callbackBlock;

- (id)initWithN:(BigInteger *)n d:(BigInteger *)d e:(BigInteger *)e bitLen:(int)len;

+ (id)RSAFromBytes:(NSData *)data;

- (NSData *)bytes;

- (BOOL)isEqualTo:(id)other;

- (NSData *)encrypt:(NSData *)data;

- (NSData *)encrypt:(NSData *)data progressCallback:(void (^)(int))callbackBlock;

- (NSData *)encrypt:(NSData *)data withModPow:(id)mp andMod:(id)mod progressCallback:(void (^)(int))callbackBlock;

- (NSData *)decrypt:(NSData *)data progressCallback:(void (^)(int))callbackBlock;

- (NSData *)decrypt:(NSData *)data;

- (NSData *)decrypt:(NSData *)data withModPow:(id)mp andMod:(id)mod progressCallback:(void (^)(int))callbackBlock;

- (BigInteger *)encryptBigInteger:(BigInteger *)message;

- (BigInteger *)decryptBigInteger:(BigInteger *)message;

//Public Key is (n, e) and Private Key is (d, n).

- (NSData *)sign:(NSData *)clear;

- (BOOL)isValidSinged:(NSData *)signature message:(NSData *)message;
@end
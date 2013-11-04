//
// Created by Stephan Bösebeck on 24.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RSA.h"
#import "BigInteger.h"
#import "NSData+BigInteger.h"
#import "NSData+MD5.h"


@implementation RSA

- (id)initWithBitLen:(int)bits {
    self = [super init];
    if (self) {
        self = [self initWithBitLen:bits andThreads:1];
    }
    return self;
}


- (BOOL)hasPrivateKey {

    return self.n != nil && self.d != nil;
}

- (BOOL)hasPublicKey {
    return self.n != nil && self.e != nil;
}


- (id)initWithBitLen:(int)bits andThreads:(int)thr {
    return [self initWithBitLen:bits andThreads:thr andProgressBlock:nil];
}

- (id)initWithBitLen:(int)bits andThreads:(int)thr andProgressBlock:(void (^)(int))callbackBlock {
    self = [super init];
    if (self) {
        self.threads = thr;
        self.d = [BigInteger valueOf:0];
//        int count = 0;
        int prz = 0;
        while ([self.d isZero]) {
            if (callbackBlock != nil) callbackBlock(prz);
//            count++;
            int length = bits / 2;
            _bitLen = length * 2;
//            NSLog(@"%d => Creating p... with %d threads", count, self.threads);
            BigInteger *p = [BigInteger randomProbablePrime:length primeProbability:100 useThreads:self.threads];
            prz += 20;
            if (callbackBlock != nil) callbackBlock(prz);

//            NSLog(@"Found it: %@\n Creating q...", p);
            BigInteger *q = [BigInteger randomProbablePrime:length primeProbability:100 useThreads:self.threads];
            prz += 20;
            if (callbackBlock != nil) callbackBlock(prz);
//            NSLog(@"Got q.. %@\nnow n...", q);
            self.n = [p multiply:q];
            BigInteger *m = [[p subtract:[BigInteger valueOf:1]] multiply:[q subtract:[BigInteger valueOf:1]]];
            while (true) {
                self.e = [BigInteger randomBigInt:bits];
                prz++;
                if (callbackBlock != nil) callbackBlock(prz);
                while ([[m gcd:self.e] intValue] > 1) {
                    self.e = [self.e add:[BigInteger randomBigInt:bits]];
                }
                if (callbackBlock != nil) callbackBlock(++prz);
//                NSLog(@"Got: e: %@ m: %@", self.e, m);
//                NSLog(@"%@", self);
                @try {
                    self.d = [self.e modInverse:m];
                    if (callbackBlock != nil) callbackBlock(++prz);
//                    if ([self.d bitLength] > bits) {
//                        NSLog(@"Bitlength of d is too big? %d vs %d", [self.d bitLength], length);
//                        continue;
//                    }
//                    if ([self.d isZero]) {
//                        NSLog(@"%@ modinverse: %@ ====> 0!!!", self.e, m);
//                    }
                    break;
                } @catch (NSException *ex) {
//                   NSLog(@"Can't inverse %@ modinverse %@",self.e,m);
                    prz -= 10;
                }
            }

            //test encryption / decryption
            //TODO: remove when creation is fixed
            BigInteger *tst = [BigInteger randomBigInt:length - 1];
            if (![[self decryptBigInteger:[self encryptBigInteger:tst]] isEqualTo:tst]) {
//                NSLog(@"Decryption test failed - retrying");
                _d = [BigInteger valueOf:0];
                _e = nil;
                _n = nil;
                prz -= 20;
            } else {
//                NSLog(@"done!");
                if (callbackBlock != nil) callbackBlock(100);
            }
        }
    }

    return self;
}

- (int)threads {
    if (_threads == 0) {
        _threads = 2;
    }
    return _threads;
}


- (id)initWithN:(BigInteger *)n d:(BigInteger *)d e:(BigInteger *)e bitLen:(int)len {
    self = [super init];
    if (self) {
        self.n = n;
        self.e = e;
        self.d = d;
        _bitLen = len;
        if (_bitLen != [e bitLength]) {
//            NSLog(@"BitLength Missmatch! WARNING! %d != e.bitlength %d", self.bitLen, e.bitLength);
        }
    }
    return self;
}


//Public Key is (n, e) and Private Key is (d, n).

+ (id)RSAFromBytes:(NSData *)data {
    NSArray *arr = [data deSerializeInts];
    BigInteger *bitLen = arr[0];
    BigInteger *n = arr[1];
    BigInteger *e = arr[2];
    BigInteger *d = nil;
    if (arr.count > 3) {
        d = arr[3];
    }
    RSA *ret = [[RSA alloc] initWithN:n d:d e:e bitLen:[bitLen intValue]];
    return ret;
}

- (NSData *)privateKey {
    NSMutableData *ret = [[NSMutableData alloc] init];
    BigInteger *bitLen = [BigInteger valueOf:self.bitLen];
    [ret appendData:[bitLen seralize]];
    [ret appendData:[self.n seralize]];
    [ret appendData:[self.d seralize]];
    return ret;
}


- (void)setPrivateKey:(NSData *)privateKey {
    NSArray *bi = [privateKey deSerializeInts];
    if ([bi count] != 3)
        @throw [NSException exceptionWithName:@"Illegal argument" reason:@"Number of ints wrong" userInfo:nil];
    if (self.n != nil && ![self.n isEqualTo:bi[1]]) {
        @throw [NSException exceptionWithName:@"Illegal argument" reason:@"Key Mismatch" userInfo:nil];
    }
    self.n = bi[1];
    int i = [bi[0] intValue];
    if (_bitLen != 0 && _bitLen != i) {
        NSLog(@"WARNING: Bitlength mismatch!");
    }
    _bitLen = i;
    self.d = bi[2];

}

- (NSData *)publicKey {
    NSMutableData *ret = [[NSMutableData alloc] init];
    BigInteger *bitLen = [BigInteger valueOf:self.bitLen];
    [ret appendData:[bitLen seralize]];
    [ret appendData:[self.n seralize]];
    [ret appendData:[self.e seralize]];
    return ret;
}

- (void)setPublicKey:(NSData *)publicKey {
    NSArray *bi = [publicKey deSerializeInts];
    self.n = bi[1];
    _bitLen = [bi[0] intValue];
    self.e = bi[2];
}


- (NSData *)bytes {
    NSMutableData *ret = [[NSMutableData alloc] init];

    BigInteger *r = [BigInteger valueOf:self.bitLen];
    [ret appendData:[r seralize]];
    [ret appendData:[self.n seralize]];
    [ret appendData:[self.e seralize]];
    [ret appendData:[self.d seralize]];
    return ret;
}


- (BOOL)isEqualTo:(id)other {
    RSA *o = (RSA *) other;
    return (o.bitLen == self.bitLen && [o.n isEqualTo:self.n] && [o.e isEqualTo:self.e] && [o.d isEqualTo:self.d]);
}

//

- (NSData *)encrypt:(NSData *)data {
    return [self encrypt:data withModPow:self.e andMod:self.n progressCallback:nil];
}

- (NSData *)encrypt:(NSData *)data progressCallback:(void (^)(int))callbackBlock {
    return [self encrypt:data withModPow:self.e andMod:self.n progressCallback:callbackBlock];
}

- (NSData *)encrypt:(NSData *)data withModPow:mp andMod:mod {
    return [self encrypt:data withModPow:mp andMod:mod progressCallback:nil];
}


- (NSData *)encrypt:(NSData *)data withModPow:mp andMod:mod progressCallback:(void (^)(int))callbackBlock {
    __block NSArray *bi = [data getIntegersofBitLength:self.bitLen - 8]; //PAdding problem - prefixed. Might be a problem, when biginteger > 255 ints
    __block int progress = 0;
    NSMutableArray *encryptedBis = [[NSMutableArray alloc] init];
    int threads = self.threads;
    int thrCount = bi.count / threads;
    int rest = bi.count % threads;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    NSLog(@"size %d,  BIs per thread %d, rest %d",bi.count,thrCount,rest);
    if (bi.count < threads) {
        //less then one per thread???
//        NSLog(@"not enough data (%d) for threads %d ",bi.count,self.threads);
        rest = 0;
        threads = bi.count;
        thrCount = 1;
    }
    for (int t = 0; t < threads; t++) {
        //start thread for 1/t_rd of
        __block NSMutableArray *thrDat = [[NSMutableArray alloc] init];
        [encryptedBis addObject:thrDat];

        dispatch_block_t block = (dispatch_block_t) ^{
//                NSLog(@"Processing");
            for (int i = t * thrCount; i < (t + 1) * thrCount; i++) {
//                    NSLog(@"... %d", i);
                BigInteger *enc = [self cryptBigInteger:bi[i] withModPow:mp andMod:mod];
                progress++;
                if (callbackBlock != nil) callbackBlock(progress * 90 / bi.count);
//                    NSLog(@"Encrypting: %@",bi[i]);
                [thrDat addObject:enc];
            }
            dispatch_semaphore_signal(semaphore);
//                NSLog(@"Finished");

        };

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, NULL), block);


    }

    NSMutableArray *thrDat = [[NSMutableArray alloc] init];
    [encryptedBis addObject:thrDat];
    //threads started
    //process "rest"
    for (int i = 0; i < rest; i++) {
        BigInteger *enc = [self encryptBigInteger:bi[(NSUInteger) (threads * thrCount + i)]];
//        NSLog(@"Processing in main %d: %@ => %@", i, bi[threads * thrCount + i], enc);
        if (callbackBlock != nil) callbackBlock(progress * 90 / bi.count);
        [thrDat addObject:enc];

    }

    for (int i = 0; i < threads; i++) {
//        NSLog(@"Waiting for threads to finish");
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        NSLog(@"=>done");
    }
    NSMutableData *ret = [[NSMutableData alloc] init];
    if (callbackBlock != nil) callbackBlock(progress * 90 / bi.count);
    for (int i = 0; i < encryptedBis.count; i++) {
        NSMutableArray *d = encryptedBis[i];
        [ret appendData:[NSData serializeInts:d]];
    }
    if (callbackBlock != nil) callbackBlock(100);
//    NSLog(@"Created Data %@", [ret hexDump:NO]);
    return ret;
}


- (NSData *)decrypt:(NSData *)data progressCallback:(void (^)(int))callbackBlock {
    return [self decrypt:data withModPow:self.d andMod:self.n progressCallback:callbackBlock];
}

- (NSData *)decrypt:(NSData *)data {
    return [self decrypt:data withModPow:self.d andMod:self.n progressCallback:nil];
}

- (NSData *)decrypt:(NSData *)data withModPow:mp andMod:mod {
    return [self decrypt:data withModPow:self.d andMod:self.n progressCallback:nil];

}

- (NSData *)decrypt:(NSData *)data withModPow:mp andMod:mod progressCallback:(void (^)(int))callbackBlock {
    __block NSArray *bi = [data deSerializeInts];
    NSMutableArray *decryptedBIs = [[NSMutableArray alloc] init];
    int threads = self.threads;
    int thrCount = bi.count / threads;
    int rest = bi.count % threads;

    __block int progress = 0;
//    NSLog(@"size %d,  BIs per thread %d, rest %d",bi.count,thrCount,rest);

    if (bi.count < threads) {
        //less then one per thread???
//        NSLog(@"No threadding - not enough data");
        rest = 0;
        threads = bi.count;
        thrCount = 1;
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    for (int t = 0; t < threads; t++) {
        //start thread for 1/t_rd of
        __block NSMutableArray *thrDat = [[NSMutableArray alloc] init];
        [decryptedBIs addObject:thrDat];

        dispatch_block_t block = (dispatch_block_t) ^{
//            NSLog(@"Processing");
            for (int i = t * thrCount; i < (t + 1) * thrCount; i++) {
//                NSLog(@"... %d", i);
                BigInteger *enc = [self cryptBigInteger:bi[i] withModPow:mp andMod:mod];
                progress++;
                if (callbackBlock != nil) callbackBlock(100 * progress / bi.count);
                [thrDat addObject:enc];
            }
            dispatch_semaphore_signal(semaphore);
//            NSLog(@"Finished");

        };

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, (unsigned long) NULL), block);

    }

    NSMutableArray *thrDat = [[NSMutableArray alloc] init];
    [decryptedBIs addObject:thrDat];
    //threads started
    //process "rest"
    for (int i = 0; i < rest; i++) {
        BigInteger *enc = [self decryptBigInteger:bi[(NSUInteger) (threads * thrCount + i)]];
//        NSLog(@"Processing in main %d: %@ => %@", i,bi[threads * thrCount + i],enc);
        if (callbackBlock != nil) callbackBlock(100 * progress / bi.count);

        [thrDat addObject:enc];

    }
    for (int i = 0; i < threads; i++) {
//        NSLog(@"Waiting for threads to finish");
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//        NSLog(@"=>done");
    }
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int i = 0; i < decryptedBIs.count; i++) {
        NSMutableArray *d = decryptedBIs[i];
        [ret appendData:[NSData dataFromBigIntArray:d]];
    }
    if (callbackBlock != nil) callbackBlock(100);
//    NSLog(@"Created Data %@", [ret hexDump:NO]);
    return ret;
//    NSArray *bi = [data deSerializeInts];
//    NSMutableArray *decryptedBis = [[NSMutableArray alloc] init];
//
//
//    for (int i = 0; i < bi.count; i++) {
//        BigInteger *dec = [self decryptBigInteger:bi[i]];
//        [decryptedBis addObject:dec];
//    }
//    return [NSData dataFromBigIntArray:decryptedBis withBitLength:self.bitLen-1];
}

- (BigInteger *)encryptBigInteger:(BigInteger *)message {
    if (self.e == nil) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"No public key" userInfo:nil];

    }
//    return [message modPow:self.e modulo:self.n];
    return [self cryptBigInteger:message withModPow:self.e andMod:self.n];
}

- (BigInteger *)cryptBigInteger:(BigInteger *)message withModPow:mp andMod:mod {
    BigInteger *b = [message modPow:mp modulo:mod];
    [b pack];
    return b;
}

- (BigInteger *)decryptBigInteger:(BigInteger *)message {
//    return [message modPow:self.d modulo:self.n];
    if (self.d == nil) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"No private key" userInfo:nil];

    }
    return [self cryptBigInteger:message withModPow:self.d andMod:self.n];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"Length: %d n: %@ d: %@ e: %@", self.bitLen, self.n, self.d, self.e];
}

- (NSData *)sign:(NSData *)clear {
    NSString *md5 = [clear md5];

    NSData *dat = [md5 dataUsingEncoding:NSUTF8StringEncoding];
    return [self encrypt:dat withModPow:self.d andMod:self.n];
}

- (BOOL)isValidSinged:(NSData *)signature message:(NSData *)message {
    //TODO: is this really ok?
    NSData *sgn = [self sign:message];
    if (![sgn isEqualToData:signature]) {
        return NO;
    }
    NSData *decSign = [self decrypt:signature withModPow:self.e andMod:self.n];
    NSString *md5 = [[NSString alloc] initWithData:decSign encoding:NSUTF8StringEncoding];
    return [md5 isEqualToString:[message md5]];
}

@end
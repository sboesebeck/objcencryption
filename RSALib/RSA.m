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


+ (BOOL)isValidData:(NSData *)data {
    char *arr = malloc(4);
    arr[0] = arr[1] = arr[2] = arr[3] = 0;
    NSRange range = NSMakeRange(0, 4);
    [data getBytes:arr range:range];
    //1st int is always 00000004 => length of the integer
    if (arr[0] == arr[1] == arr[2] == 0 && arr[3] == 4) {
        free(arr);
        return YES;
    }
    free(arr);
    return NO;
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

        int prz = 0;
        while ([self.d isZero]) {
            if (callbackBlock != nil) callbackBlock(prz);

            int length = bits / 2;
            _bitLen = length * 2;

            BigInteger *p = [BigInteger randomProbablePrime:length primeProbability:100 useThreads:self.threads];
            prz += 20;
            if (callbackBlock != nil) callbackBlock(prz);


            BigInteger *q = [BigInteger randomProbablePrime:length primeProbability:100 useThreads:self.threads];
            prz += 20;
            if (callbackBlock != nil) callbackBlock(prz);

            self.n = [p multiply:q];
            BigInteger *m = [[p subtract:[[BigInteger alloc] initWith:1]] multiply:[q subtract:[[BigInteger alloc] initWith:1]]];
            while (true) {
                @autoreleasepool {
                    self.e = [BigInteger randomBigInt:bits];
                    prz++;
                    if (prz > 99) {
                        prz = 95;
                    }
                    if (callbackBlock != nil) callbackBlock(prz);
                    while ([[m gcd:self.e] intValue] > 1) {
                        self.e = [self.e add:[BigInteger randomBigInt:bits]];
                    }
                    if (callbackBlock != nil) callbackBlock(++prz);
                    @try {
                        self.d = [self.e modInverse:m];
                        if (callbackBlock != nil) callbackBlock(++prz);
                        break;
                    } @catch (NSException *ex) {
//                        NSLog(@"Exception...");
                        prz -= 10;
                        if (prz < 10) {
                            prz = 15;
                        }
                    }
                }
            }

            //test encryption / decryption
            //TODO: remove when creation is fixed
            BigInteger *tst = [BigInteger randomBigInt:length - 1];
            if (![[self decryptBigInteger:[self encryptBigInteger:tst]] isEqualTo:tst]) {
//                NSLog(@"Decryption test failed - retrying");
                _d = [[BigInteger alloc] initWith:0];
                _e = nil;
                _n = nil;
                prz -= 20;
                if (prz < 10) {
                    prz = 15;
                }
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
    BigInteger *bitLen = [[BigInteger alloc] initWith:self.bitLen];
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
    BigInteger *bitLen = [[BigInteger alloc] initWith:self.bitLen];
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

    BigInteger *r = [[BigInteger alloc] initWith:self.bitLen];
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
    if (bi.count < threads) {
        rest = 0;
        threads = bi.count;
        thrCount = 1;
    }
    for (int t = 0; t < threads; t++) {
        //start thread for 1/t_rd of
        __block NSMutableArray *thrDat = [[NSMutableArray alloc] init];
        [encryptedBis addObject:thrDat];

        dispatch_block_t block = (dispatch_block_t) ^{
            for (int i = t * thrCount; i < (t + 1) * thrCount; i++) {
                @autoreleasepool {
                    BigInteger *enc = [self cryptBigInteger:bi[i] withModPow:mp andMod:mod];
                    progress++;
                    if (callbackBlock != nil) callbackBlock(progress * 90 / bi.count);
                    [thrDat addObject:enc];
                }
            }
            dispatch_semaphore_signal(semaphore);
        };

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);


    }

    NSMutableArray *thrDat = [[NSMutableArray alloc] init];
    [encryptedBis addObject:thrDat];
    //threads started
    //process "rest"
    for (int i = 0; i < rest; i++) {
        BigInteger *enc = [self encryptBigInteger:bi[(NSUInteger) (threads * thrCount + i)]];
        if (callbackBlock != nil) callbackBlock(progress * 90 / bi.count);
        [thrDat addObject:enc];

    }

    for (int i = 0; i < threads; i++) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    NSMutableData *ret = [[NSMutableData alloc] init];
    if (callbackBlock != nil) callbackBlock(progress * 90 / bi.count);
    for (int i = 0; i < encryptedBis.count; i++) {
        NSMutableArray *d = encryptedBis[i];
        [ret appendData:[NSData serializeInts:d]];
    }
    if (callbackBlock != nil) callbackBlock(100);
    thrDat = nil;
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


    if (bi.count < threads) {
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
            for (int i = t * thrCount; i < (t + 1) * thrCount; i++) {
                BigInteger *enc = [self cryptBigInteger:bi[i] withModPow:mp andMod:mod];
                progress++;
                if (callbackBlock != nil) callbackBlock(100 * progress / bi.count);
                [thrDat addObject:enc];
            }
            dispatch_semaphore_signal(semaphore);

        };

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long) NULL), block);

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
    thrDat = nil;
    return ret;
}

- (BigInteger *)encryptBigInteger:(BigInteger *)message {
    if (self.e == nil) {
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"No public key" userInfo:nil];

    }
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
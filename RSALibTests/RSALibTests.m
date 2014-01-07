//
//  RSALibTests.m
//  RSALibTests
//
//  Created by Stephan Bösebeck on 29.10.13.
//  Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "BigInteger.h"
#import "RSA.h"
#import "NSData+HexDump.h"
#import "NSData+MD5.h"
#import "NSData+BigInteger.h"
#import "AES.h"

@interface RSALibTests : XCTestCase

@end

@implementation RSALibTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testSimpleBigInt {
    BigInteger *int1 = [BigInteger valueOf:@"F0" usingRadix:16];
    BigInteger *int2 = [BigInteger valueOf:@"2" usingRadix:16];
    BigInteger *res = [int1 multiply:int2];
    if (![[res description] isEqualToString:@"1E0"]) {
        XCTFail(@"Multiplication failed: should be 1E0 but is %@", res);
    }

}

- (void)testExplicitMultDivTest {
    //456FC3181B75AC6EA15BD1B9FFF3AC53*A5C14DCDA3F7CB6707C52F603A9A7002
    //2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6
    //2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6

    BigInteger *int1 = [BigInteger valueOf:@"456FC3181B75AC6EA15BD1B9FFF3AC53" usingRadix:16];
    BigInteger *int2 = [BigInteger valueOf:@"A5C14DCDA3F7CB6707C52F603A9A7002" usingRadix:16];
    BigInteger *prod = [int1 multiply:int2];
    BigInteger *prod2 = [BigInteger valueOf:@"2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6" usingRadix:16];
    XCTAssertEqualObjects(prod, prod2, "WRONG!");
    XCTAssertEqualObjects([prod description], @"2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6", "Product wrong %@!", [prod description]);
    BigInteger *div = [prod divideBy:int2];
    XCTAssertEqualObjects(div, int1, "Division wrong %@ != %@", int1, div);
}

- (void)testRandomBigInt {
    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:128];
        BigInteger *int2 = [BigInteger valueOf:[int1 description] usingRadix:16];
        if (int1.iVal != int2.iVal) {
            NSLog(@"Something's wrong!");
        }
        XCTAssertTrue(int1.iVal == int2.iVal);
//    BOOL s1=int1.isSimple;
//    BOOL s2=int2.isSimple;
//    XCTAssertTrue(s1==s2);
//    if (!s1) {
//        return;
//    }

        for (int i = 0; i < int1.iVal; i++) {
            if ((int32_t) int1.data[i] != (int32_t) int2.data[i]) {
                XCTFail(@"Error: %d != %d", int1.data[i], int2.data[i]);
            }
        }
    }

}

- (void)testRemainder {
    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:128 + i];
        BigInteger *add = [BigInteger valueOf:0];
        for (int i = 1; i <= 17; i++) {
            add = [add add:int1];
        }
        BigInteger *div = [add divideBy:int1];

        XCTAssertTrue([[div description] isEqualToString:@"11"]);

        BigInteger *int2 = [int1 subtract:[BigInteger valueOf:1]];
        add = [add add:int2];

        NSArray *res = [add divideAndRemainder:int1];
        XCTAssertTrue(res.count == 2);
        XCTAssertTrue([res[0] isEqual:div], @"Division is wrong %@", res[0]);
        XCTAssertTrue([res[1] isEqual:int2], @"Remainder is wrong %@", res[1]);

        BigInteger *rem = [add remainder:int1];
        XCTAssertEqualObjects(rem, int2, @"REmainder is wrong %@", rem);
    }
}

- (void)testAdd {
//    BigInteger *tst1=[BigInteger valueOf:@"65247DF5E" usingRadix:16];
//    BigInteger *tst2=[BigInteger valueOf:@"18C5A8DE2" usingRadix:16];
//    BigInteger *tst3=[tst1 subtract:tst2];

    BigInteger *int1 = [BigInteger randomBigInt:128];
    for (int i = 1; i <= 512; i++) {
        BigInteger *int2 = [BigInteger randomBigInt:120 + i];
        BigInteger *add = [int1 add:int2];
//        NSLog(@"Adding %@ + %@ = %@",int1,int2,add);
        BigInteger *dif = [add subtract:int2];
        if (![dif isEqual:int1]) {
            NSLog(@"WRONG! %d", i);
            [add subtract:int2];
            BOOL eq = [dif isEqual:int1];
        }
        XCTAssertEqualObjects(dif, int1, @"Error: %@ != %@", dif, int1);
    }
}

- (void)testMultiplyDivide {
    for (int i = 1; i <= 512; i++) {
        for (int j = 0; j < 5; j++) {
//        NSLog(@"Test no %d",i);
            BigInteger *int1 = [BigInteger randomBigInt:128 + i];
            BigInteger *int2 = [BigInteger randomBigInt:127 + i];


            BigInteger *prod = [int1 multiply:int2];
            prod = [BigInteger valueOf:[prod description] usingRadix:16];
            BigInteger *div = [prod divideBy:int2];

            if (![div isEqual:int1]) {
                NSLog(@"Error - not equals");
                [div isEqual:int1];
            }
            XCTAssertTrue([[div description] isEqualTo:[int1 description]], @"Division failed int1: %@, div: %@", int1, div);
            XCTAssertTrue([div isEqual:int1], @"Division failed int1: %@, div: %@", int1, div);
        }
    }
}


- (void)testMultShift {
    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:126 + i];
        BigInteger *int2 = [BigInteger valueOf:2];
        BigInteger *prod = [int1 multiply:int2];
        BigInteger *prod2 = [int1 shiftLeft:1];
        XCTAssertTrue([prod isEqualTo:prod2], @"ShifMult failed prod: %@, prod2: %@", prod, prod2);
    }
}

- (void)testAddNegative {
    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:128 + i];
        BigInteger *int2 = [BigInteger randomBigInt:100 + i];
        BigInteger *s1 = [int1 subtract:int2];
        int2 = [int2 negate];
        BigInteger *s = [int1 add:int2];
        XCTAssertEqualObjects(s, s1, @"Objects differ? %@,%@", s, s1);
    }
}

- (void)testMultNeg {
    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:126 + i];
        BigInteger *int2 = [BigInteger randomBigInt:126 + i];
        BigInteger *m = [int1 multiply:int2];
        BigInteger *mint1 = [int1 negate];
        if (mint1.data == nil) {
            mint1.data = [BigInteger allocData:1];
            mint1.data[0] = mint1.iVal;
            mint1.iVal = 1;
        }
        BigInteger *mint2 = [int2 negate];
        if (mint2.data == nil) {
            mint2.data = [BigInteger allocData:1];
            mint2.data[0] = mint2.iVal;
            mint2.iVal = 1;
        }
        //TODO: fix it here
        BigInteger *m2 = [mint1 multiply:mint2];
        if (m2.isNegative) {
            NSLog(@"WRong!");
        }
        XCTAssertEqualObjects(m, m2, @"- * - should get +");
    }

}

- (void)testOrBig {
    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:126 + i];
        BigInteger *int2 = [BigInteger valueOf:0];
        XCTAssertEqualObjects([int2 or:int1], int1);
        XCTAssertEqualObjects([int1 or:int1], int1);
        XCTAssertEqualObjects([int1 xor:int1], int2);
    }
}

- (void)testCompare {

    BigInteger *tst1 = [BigInteger valueOf:@"298DF8C9C767D7DB5AA943694ACD8385552" usingRadix:16];
    BigInteger *tst2 = [BigInteger valueOf:@"7E36DA5F" usingRadix:16];
    BigInteger *tst3 = [tst1 add:tst2];

    int c = [tst1 compareTo:tst2];

    for (int i = 0; i < 512; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:122 + i];
        NSLog(@"i is %d: %@", i, int1);
        BigInteger *toAdd = [BigInteger randomBigInt:16 + i];
        BigInteger *toAdd2 = [BigInteger valueOf:[toAdd description] usingRadix:16];
        BigInteger *int12 = [BigInteger valueOf:[int1 description] usingRadix:16];
        BigInteger *int2 = [int1 add:toAdd];
        int cmp = [int1 compareTo:int2];
        if (cmp >= 0) {
            NSLog(@"Wrong %@  %@", int1, int2);
            [int1 add:toAdd];
        }
        XCTAssertTrue(cmp < 0, @"Cmp value is %d", cmp);
        int2 = [int2 subtract:[toAdd multiply:[BigInteger valueOf:2]]];
        cmp = [int1 compareTo:int2];
        XCTAssertTrue(cmp > 0, @"Cmp value of %@ and %@ is %d", int1, int2, cmp);
        BigInteger *int3 = [int2 add:toAdd];
        cmp = [int1 compareTo:int3];
        if (cmp != 0) {
            NSLog(@"Wrong");
            [int1 compareTo:int3];
            [int2 add:toAdd];
            [int1 add:toAdd];
        }
        XCTAssertTrue(cmp == 0, @"'%@' Not equal '%@'? cmp=%d", int1, int3, cmp);
    }

}

- (void)testRandom {
    for (int i = 0; i < 1024; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:128];
        NSLog(@"Got %@", int1);
    }
}

- (void)testPrimeCheck {
    BigInteger *int1 = [BigInteger valueOf:@"F1DA144956AFD98AEF578E45D99BF86D" usingRadix:16];

    BigInteger *m = [BigInteger valueOf:@"3C76851255ABF662BBD5E3917666FE1B" usingRadix:16];
    BigInteger *r1 = [[BigInteger valueOf:3] modPow:m modulo:int1];


    BOOL prime = [int1 isProbablePrime:100];
    if (!prime) {
        NSLog(@"Something is wrong!");
    }
    XCTAssertTrue(prime);

}

- (void)testModInvert {
    BigInteger *int1 = [BigInteger valueOf:@"E10271E7CFF5BD11EC53B5D5C6718E486A8154148488546192672A6E7D700D08ABB3D08E973DC612ACBFD12FF0AA2802B737C74EE599423D4789FD55EA0C080649567EBBA7F791F10C5CD90124D67157E0E0B69519BF1135A295E985137A67C0" usingRadix:16];
    BigInteger *int2 = [BigInteger valueOf:@"18FF86790796D5B318D6C11EAEF5AA20E8D9F4875513624ECA5C5A50D00387707D3D65C971B7F8FFDF5F1E47896C1080072B48FF793233D8EEB784A7C066513EF030146619F974AA6BB1DB564A1D23C67176CE588BC92F0A476C30B276D130E5" usingRadix:16];
    BigInteger *d = [int1 modInverse:int2]; //no Exception
}

- (void)testProbablePrime {

    for (int i = 0; i < 2048; i += 17) {
        NSLog(@"Getting prime of size %d", i + 128);
        BigInteger *int1 = [BigInteger randomProbablePrime:128 primeProbability:100 useThreads:1];
        NSLog(@"Got one: %@", int1);
        //check if it's really a prime
        BigInteger *idx = [BigInteger valueOf:2];
        BigInteger *end = [int1 shiftRight:1];
        end = [end subtract:[BigInteger valueOf:1]];
        //could count to end and divide... takes way too long
    }

}


- (void)testEncryptionBigInteger {
    for (int i = 0; i < 512; i += 19) {
        RSA *rsa = [[RSA alloc] initWithBitLen:126 + i andThreads:4];
        BigInteger *int1 = [BigInteger randomBigInt:rsa.bitLen - 2];
        NSLog(@"N.length: %d d: %d e: %d   int: %d", rsa.n.bitLength, rsa.d.bitLength, rsa.e.bitLength, int1.bitLength);
        BigInteger *enc = [rsa encryptBigInteger:int1];
        BigInteger *dec = [rsa decryptBigInteger:enc];
        XCTAssertEqualObjects(int1, dec, @"decoding failed: %@ != %@", int1, dec);
    }
}

- (void)testStringConversion {
    NSString *clear = @"Cleartext to encrypt....";
    for (int i = 0; i < 6; i++) {
        clear = [clear stringByAppendingString:clear];
    }
    for (int i = 126; i < 512; i += 17) {
        NSData *data = [clear dataUsingEncoding:NSUTF8StringEncoding];
//        NSLog(@"Dat md5: %@", [data md5]);
        NSArray *ints = [data getIntegersofBitLength:i];
        NSData *ret = [NSData dataFromBigIntArray:ints];

//        NSLog(@"Ret md5: %@", [ret md5]);
        XCTAssertEqualObjects([ret md5], [data md5], "Ret: %@  data %@", [ret md5], [data md5]);
    }

    NSLog(@"Done string conversions");


}

- (void)testEncryptText {
    NSString *clear = @"Cleartext to encrypt....";
    for (int i = 0; i < 6; i++) {
        clear = [clear stringByAppendingString:clear];
    }
    NSData *data = [clear dataUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < 1024; i += 59) {
        NSLog(@"i=%d", i);
        RSA *rsa = [[RSA alloc] initWithBitLen:i + 126 andThreads:4];
        NSLog(@"got RSA bitLen %d", rsa.bitLen);

        for (int t = 1; t < 10; t *= 2) {
            rsa.threads = t;
            NSDate *start = [NSDate date];
            NSData *enc = [rsa encrypt:data];
            NSData *dec = [rsa decrypt:enc];
            double timePassed_ms = [start timeIntervalSinceNow] * -1000.0;
            NSLog(@"En- and decryption of %d bytes with %d threads took %f ms in total", (int) data.length, t, timePassed_ms);

            NSString *string = [data hexDump:NO];
//            NSString *stringEnc = [enc hexDump:NO];
            NSString *stringDec = [dec hexDump:NO];


            XCTAssertEqualObjects(string, stringDec, @"decoding failed!");

            if (![string isEqualToString:stringDec]) {
                enc = [rsa encrypt:data];
                dec = [rsa decrypt:enc];
                return;
            }


            NSString *decStr = [[NSString alloc] initWithData:dec encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(clear, decStr, @"decoding failed");
        }
    }
}


- (void)testConversions {
    char *bytes = (char *) [BigInteger allocData:4];
    //to bigIntArray and back
    for (int l = 0; l < 100; l++) {
        int len = 7 + l;
        NSLog(@"Round %d - %d bytes", l, len);

        NSMutableData *dat = [[NSMutableData alloc] init];
        for (int i = 1; i <= len; i++) {
            bytes[0] = (char) ([BigInteger nextRand] & 0xff);
            bytes[1] = (char) ([BigInteger nextRand] & 0xff);
            bytes[2] = (char) ([BigInteger nextRand] & 0xff);
            bytes[3] = (char) ([BigInteger nextRand] & 0xff);
            [dat appendBytes:bytes length:4];
        }

        NSArray *ints = [dat getIntegersofBitLength:128];

        NSData *data = [NSData dataFromBigIntArray:ints];

        NSString *dataHex = [data hexDump:NO];
        NSLog(@"Data HEx: %@", dataHex);
        NSString *origHex = [dat hexDump:NO];
        NSLog(@"orig HEx: %@", origHex);
        XCTAssertEqualObjects(dataHex, origHex);
        if (![origHex isEqualToString:dataHex]) {
            return;
        }
    }
    free(bytes);
}

- (void)testSigning {
    //TODO implement
}

- (void)testCommunication {
    RSA *serverKeys = [[RSA alloc] initWithBitLen:2048 andThreads:3];
    RSA *clientKeys = [[RSA alloc] initWithBitLen:512 andThreads:3];

    NSData *clientPubKeyDat = [clientKeys publicKey];
    NSData *serverPubKeyDat = [serverKeys publicKey];

    //client gets Server PublicKey
    RSA *serverKeyAtClient = [[RSA alloc] init];
    serverKeyAtClient.publicKey = serverPubKeyDat;
    //client encrypts his pubkey and sends it
    NSData *encryptedPubKeyClient = [serverKeyAtClient encrypt:clientPubKeyDat];

    //server gets encrypted pub key, decrypts it
    NSData *decryptedClientKey = [serverKeys decrypt:encryptedPubKeyClient];
    //now there is the clients key...
    if (![[decryptedClientKey md5] isEqualToString:clientPubKeyDat.md5]) {
        NSLog(@"orig MD5: %@", [clientPubKeyDat hexDump:NO]);
        NSLog(@"dec  MD5: %@", [decryptedClientKey hexDump:NO]);
        XCTFail(@"conversion byte array error");
        return;
    }
    RSA *keyFromClient = [[RSA alloc] init];
    keyFromClient.publicKey = decryptedClientKey;
    if (![keyFromClient.n isEqual:clientKeys.n]) {
        NSLog(@"ClientKey.n: %@", keyFromClient.n);
        NSLog(@"Original  n: %@", clientKeys.n);
        XCTAssertEqualObjects(keyFromClient.n, clientKeys.n, @"N is wrong!");
        return;
    }

    if (![keyFromClient.n isEqual:clientKeys.n]) {
        NSLog(@"ClientKey.e: %@", keyFromClient.e);
        NSLog(@"Original  e: %@", clientKeys.e);
        XCTAssertEqualObjects(keyFromClient.e, clientKeys.e, @"E wrong!");

    }


}


- (void)testRSAFromBytes {
    RSA *r1 = [[RSA alloc] initWithBitLen:512];
    NSData *r1Bytes = r1.bytes;
    RSA *r2 = [RSA RSAFromBytes:r1Bytes];
    XCTAssertEqualObjects(r1.description, r2.description);
}


- (void)testEncryptLarge {
    for (int r = 1; r <= 3; r++) {
        int bits = r * 1024;
        NSLog(@"Generating keys for round %d - bits: %d", r, bits);
        RSA *rsa = [[RSA alloc] initWithBitLen:bits andThreads:4];
        NSString *text = @"asdfg";
        for (int i = 0; i < 10; i++) {
            NSLog(@"Round %d", i + 1);
            text = [text stringByAppendingFormat:@"...%d", i];
            NSData *txtDat = [text dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *txtArr = [txtDat getIntegersofBitLength:bits - 8];
            NSData *decodedData = [NSData dataFromBigIntArray:txtArr];
            NSString *text2 = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            if (![text isEqualToString:text2]) {
                NSLog(@"Text  : %@", text);
                NSLog(@"Text2 : %@", text2);
                NSLog(@"txtDat: %@", [txtDat hexDump:NO]);
                NSLog(@"BigInt: %@", txtArr[0]);

                txtArr = [txtDat getIntegersofBitLength:bits - 8];
                decodedData = [NSData dataFromBigIntArray:txtArr];
                XCTAssertEqualObjects(text, text2, "%@ != %@", text, text2);
                return;
            }
            NSData *enc = [rsa encrypt:txtDat];
            NSData *dec = [rsa decrypt:enc];
            NSString *decText = [[NSString alloc] initWithData:dec encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(text, decText, "%@ != %@", text, decText);
        }
    }

}


- (void)testRsaLargeCallback {

    void (^callback)(int) = ^(int prz) {
        NSLog(@"Perzentage %d %%", prz);
    };
    RSA *rsa = [[RSA alloc] initWithBitLen:2048 andThreads:8 andProgressBlock:callback];

    NSString *longTxt = @"abcdefghijklmopqurstuvwxyz";
    for (int i = 0; i < 10; i++) {
        longTxt = [longTxt stringByAppendingString:longTxt];
    }

    NSLog(@"\n\nEncryption");
    NSData *enc = [rsa encrypt:[longTxt dataUsingEncoding:NSUTF8StringEncoding] progressCallback:callback];
    NSLog(@"\n\nDecryption");
    NSData *dec = [rsa decrypt:enc progressCallback:callback];

}


- (void)testAesBlock {
    AES *aes = [[AES alloc] init];
    [aes setEncryptionKey:[@"the secret key!!the secret key!!" dataUsingEncoding:NSUTF8StringEncoding]];
    char *dat = malloc(16);
    for (int i = 1; i <= 16; i++) {
        dat[i - 1] = (char) i;
    }
    NSData *b = [[NSData alloc] initWithBytes:dat length:16];
    NSLog(@"Cleartext: %@", [b hexDump:NO]);
    char *enc = [aes encryptBlock:dat];
    NSLog(@"Encrypted: %@", [[[NSData alloc] initWithBytes:enc length:16] hexDump:NO]);
    char *dec = [aes decryptBlock:enc];
    NSString *string = [[[NSData alloc] initWithBytes:dec length:16] hexDump:NO];
    NSLog(@"Decrypted: %@", string);

    XCTAssertEqualObjects(string, [b hexDump:NO], "%@ != %@", string, [b hexDump:NO]);

    for (int i = 1; i <= 16; i++) {
        if (i < 10) {
            dat[i - 1] = (char) 0;
        } else {
            dat[i - 1] = (char) i;
        }
    }
    b = [[NSData alloc] initWithBytes:dat length:16];
    NSLog(@"Cleartext: %@", [b hexDump:NO]);
    enc = [aes encryptBlock:dat];
    NSLog(@"Encrypted: %@", [[[NSData alloc] initWithBytes:enc length:16] hexDump:NO]);
    dec = [aes decryptBlock:enc];
    string = [[[NSData alloc] initWithBytes:dec length:16] hexDump:NO];
    NSLog(@"Decrypted: %@", string);
    XCTAssertEqualObjects(string, [b hexDump:NO], "%@ != %@", string, [b hexDump:NO]);

    for (int i = 1; i <= 16; i++) {
        if (i > 10) {
            dat[i - 1] = (char) 0;
        } else {
            dat[i - 1] = (char) i;
        }
    }
    b = [[NSData alloc] initWithBytes:dat length:16];
    NSLog(@"Cleartext: %@", [b hexDump:NO]);
    enc = [aes encryptBlock:dat];
    NSLog(@"Encrypted: %@", [[[NSData alloc] initWithBytes:enc length:16] hexDump:NO]);
    dec = [aes decryptBlock:enc];
    string = [[[NSData alloc] initWithBytes:dec length:16] hexDump:NO];
    NSLog(@"Decrypted: %@", string);
    XCTAssertEqualObjects(string, [b hexDump:NO], "%@ != %@", string, [b hexDump:NO]);
}


- (void)testAesBig {
    NSString *str = @"This is a long text! This is a long text! This is a long text! This is a long text! This is a long text! This is a long text! This is a long text! ";
    AES *aes = [[AES alloc] init];
    [aes setEncryptionKey:[@"the secret key!!the secret key!!" dataUsingEncoding:NSUTF8StringEncoding]];

    NSData *enc = [aes encrypt:[str dataUsingEncoding:NSUTF8StringEncoding]];
//    NSLog(@"Encrypted: %@",[enc hexDump:NO]);
    NSData *dec = [aes decrypt:enc];
    NSString *decStr = [[NSString alloc] initWithData:dec encoding:NSUTF8StringEncoding];
    NSLog(@"Decoded %@", decStr);
}
@end

//
//  RSALibTests.m
//  RSALibTests
//
//  Created by Stephan Bösebeck on 29.10.13.
//  Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//

#import <XCTest/XCTest.h>
#include "BigInteger.h"

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
    BigInteger *int1 = [BigInteger randomBigInt:128];
    BigInteger *int2 = [BigInteger valueOf:[int1 description] usingRadix:16];
    if (int1.iVal != int2.iVal) {
        NSLog(@"Something's wrong!");
    }
    XCTAssertTrue(int1.iVal == int2.iVal);
    for (int i = 0; i < int1.iVal; i++) {
        if ((int32_t) int1.data[i] != (int32_t) int2.data[i]) {
            XCTFail(@"Error: %d != %d", int1.data[i], int2.data[i]);
        }
    }

}

- (void)testRemainder {
    BigInteger *int1 = [BigInteger randomBigInt:128];
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

- (void)testAdd {
//    BigInteger *tst1=[BigInteger valueOf:@"65247DF5E" usingRadix:16];
//    BigInteger *tst2=[BigInteger valueOf:@"18C5A8DE2" usingRadix:16];
//    BigInteger *tst3=[tst1 subtract:tst2];

    BigInteger *int1 = [BigInteger randomBigInt:128];
    for (int i = 1; i <= 64; i++) {
        BigInteger *int2 = [BigInteger randomBigInt:120 + i];
        BigInteger *add = [int1 add:int2];
//        NSLog(@"Adding %@ + %@ = %@",int1,int2,add);
        BigInteger *dif = [add subtract:int2];
        if (![dif isEqual:int1]) {
            NSLog(@"WRONG! %d",i);
            [add subtract:int2];
            BOOL eq = [dif isEqual:int1];
        }
        XCTAssertEqualObjects(dif, int1, @"Error: %@ != %@", dif, int1);
    }
}

- (void)testMultiplyDivide {
    for (int i = 1; i <= 128; i++) {
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
    for (int i = 0; i < 64; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:126 + i];
        BigInteger *int2 = [BigInteger valueOf:2];
        BigInteger *prod = [int1 multiply:int2];
        BigInteger *prod2 = [int1 shiftLeft:1];
        XCTAssertTrue([prod isEqualTo:prod2], @"ShifMult failed prod: %@, prod2: %@", prod, prod2);
    }
}

- (void)testAddNegative {
    for (int i = 0; i < 128; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:128+i];
        BigInteger *int2 = [BigInteger randomBigInt:100+i];
        BigInteger *s1 = [int1 subtract:int2];
        int2 = [int2 negate];
        BigInteger *s = [int1 add:int2];
        XCTAssertEqualObjects(s, s1, @"Objects differ? %@,%@", s, s1);
    }
}

- (void)testMultNeg {
    for (int i = 0; i < 68; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:126 + i];
        BigInteger *int2 = [BigInteger randomBigInt:126 + i];
        BigInteger *m = [int1 multiply:int2];
        BigInteger *mint1 = [int1 negate];
        BigInteger *mint2 = [int2 negate];
        //TODO: fix it here
        BigInteger *m2 = [mint1 multiply:mint2];
        XCTAssertEqualObjects(m, m2, @"- * - should get +");
    }

}

- (void)testOrBig {
    for (int i = 0; i < 68; i++) {
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

    int c=[tst1 compareTo:tst2];

    for (int i = 0; i < 130; i++) {
        BigInteger *int1 = [BigInteger randomBigInt:122 + i];
        NSLog(@"i is %d: %@", i, int1);
        BigInteger *toAdd = [BigInteger randomBigInt:16 + i];
        BigInteger *toAdd2=[BigInteger valueOf:[toAdd description] usingRadix:16];
        BigInteger *int12=[BigInteger valueOf:[int1 description] usingRadix:16];
        BigInteger *int2 = [int1 add:toAdd];
        int cmp = [int1 compareTo:int2];
        if (cmp>=0) {
            NSLog(@"Wrong %@  %@",int1, int2);
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
            [int2 add:toAdd];
            [int1 add:toAdd];
        }
        XCTAssertTrue(cmp == 0, @"'%@' Not equal '%@'? cmp=%d", int1, int3, cmp);
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

- (void)testProbablePrime {


    NSLog(@"Getting prime");
    BigInteger *int1 = [BigInteger randomProbablePrime:1024 primeProbability:100 useThreads:3];
    NSLog(@"Got one");
    //check if it's really a prime
    BigInteger *idx = [BigInteger valueOf:2];
    BigInteger *end = [int1 shiftRight:1];
    end = [end subtract:[BigInteger valueOf:1]];

    //Would do... if I had a lot of time...
//        while ([idx compareTo:end] < 0) {
//            NSLog(@"Checking...%@",idx);
//
//            idx = [idx add:[BigInteger valueOf:1]];
//            BigInteger *rem = [int1 mod:idx];
//            if ([rem isZero]) {
//                NSLog(@"Found divident: %@ %% %@ = %@",int1,idx,rem);
//            }
//            XCTAssertFalse([rem isZero]);
//
//        }

}


@end

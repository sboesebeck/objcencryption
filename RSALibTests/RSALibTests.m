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

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void) testSimpleBigInt {
    BigInteger *int1 = [BigInteger valueOf:@"F0" usingRadix:16];
    BigInteger *int2 = [BigInteger valueOf:@"2" usingRadix:16];
    BigInteger *res=[int1 multiply:int2];
    if (![[res description] isEqualToString:@"1E0"]) {
        XCTFail(@"Multiplication failed: should be 1E0 but is %@",res);
    }
    
}

-(void) testExplicitMultDivTest {
    //456FC3181B75AC6EA15BD1B9FFF3AC53*A5C14DCDA3F7CB6707C52F603A9A7002
    //2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6
    //2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6

    BigInteger *int1=[BigInteger valueOf:@"456FC3181B75AC6EA15BD1B9FFF3AC53" usingRadix:16];
    BigInteger *int2= [BigInteger valueOf:@"A5C14DCDA3F7CB6707C52F603A9A7002" usingRadix:16];
    BigInteger *prod=[int1 multiply:int2];
    BigInteger *prod2=[BigInteger valueOf:@"2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6" usingRadix:16];
    XCTAssertEqualObjects(prod,prod2,"WRONG!");
    XCTAssertEqualObjects([prod description], @"2CF5771B038665A3D705C183684A4E760F7ED7A6A74E3092553D0D2F1339A8A6","Product wrong %@!", [prod description]);
    BigInteger *div=[prod divideBy:int2];
    XCTAssertEqualObjects(div,int1,"Division wrong %@ != %@",int1,div);
}

-(void) testRandomBigInt {
    BigInteger *int1 = [BigInteger randomBigInt:128];
    BigInteger *int2 = [BigInteger valueOf:[int1 description] usingRadix:16];
    if (int1.iVal!=int2.iVal) {
        NSLog(@"Something's wrong!");
    }
    XCTAssertTrue(int1.iVal==int2.iVal);
    for (int i=0;i<int1.iVal;i++) {
        if ((int32_t)int1.data[i]!= (int32_t)int2.data[i]) {
            XCTFail(@"Error: %d != %d",int1.data[i],int2.data[i]);
        }
    }

}

-(void) testRemainder {
    BigInteger *int1=[BigInteger randomBigInt:128];
    BigInteger *add=[BigInteger valueOf:0];
    for (int i = 1; i <= 17; i++) {
        add=[add add:int1];
    }
    BigInteger *div=[add divideBy:int1];
    XCTAssertTrue([[div description] isEqualToString:@"11"]);

    BigInteger *int2=[int1 subtract:[BigInteger valueOf:1]];
    add=[add add:int2];
    NSArray *res=[add divideAndRemainder:int2];
    XCTAssertTrue(res.count==2);

    XCTAssertTrue([res[0] isEqual:int2]);
    XCTAssertTrue([res[1] isEqual:div]);

}
-(void) testAdd {
    BigInteger *int1=[BigInteger randomBigInt:128];
    for (int i = 1; i <= 64; i++) {
        BigInteger *int2=[BigInteger randomBigInt:64+i];
        BigInteger *add=[int1 add:int2];
        BigInteger *dif=[add subtract:int2];
        XCTAssertEqualObjects(dif, int1,@"Error: %@ != %@",dif,int1);
    }
}

-(void) testMultiplyDivide {
    for (int i = 1; i <= 64; i++) {
//        NSLog(@"Test no %d",i);
        BigInteger *int1 = [BigInteger randomBigInt:128+i];
        BigInteger *int2 = [BigInteger randomBigInt:127+i];


        BigInteger *prod = [int1 multiply:int2];

        BigInteger *div = [prod divideBy:int2];
        if (![div isEqual:int1]) {
            NSLog(@"Error - not equals");
        }
        XCTAssertTrue([[div description] isEqualTo:[int1 description]], @"Division failed int1: %@, div: %@", int1, div);
        XCTAssertTrue([div isEqual:int1], @"Division failed int1: %@, div: %@", int1, div);
    }
}


-(void) testMultShift {
    BigInteger *int1=[BigInteger randomBigInt:126];
    BigInteger *int2=[BigInteger valueOf:2];
    BigInteger *prod=[int1 multiply:int2];
    BigInteger *prod2=[int1 shiftLeft:1];
    XCTAssertTrue([prod isEqualTo:prod2], @"ShifMult failed prod: %@, prod2: %@",prod,prod2);

}


@end

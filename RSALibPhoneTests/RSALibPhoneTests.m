//
//  RSALibPhoneTests.m
//  RSALibPhoneTests
//
//  Created by Stephan Bösebeck on 29.10.13.
//  Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BigInteger.h"

@interface RSALibPhoneTests : XCTestCase

@end

@implementation RSALibPhoneTests

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

//- (void)testExample
//{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//}

-(void) bigIntTest {
    BigInteger *int1 = [BigInteger valueOf:@"F0" usingRadix:16];
    BigInteger *int2 = [BigInteger valueOf:@"2" usingRadix:16];
    BigInteger *res=[int1 multiply:int2];
    if (![[res description] isEqualToString:@"1E0"]) {
        XCTFail(@"Multiplication failed: should be 1E0 but is %@",res);
    }
    
}


-(void) testMultiplyDivide {
    BigInteger *int1=[BigInteger randomBigInt:128];
    BigInteger *int2=[BigInteger randomBigInt:120];
    BigInteger *prod=[int1 multiply:int2];

    BigInteger *div=[prod divideBy:int2];
    XCTAssertTrue([[div description] isEqual:[int1 description]], @"Division failed int1: %@, div: %@",int1,div);
    XCTAssertTrue([div isEqual:int1], @"Division failed int1: %@, div: %@",int1,div);

}


@end

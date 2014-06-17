//
//  RandomPrimeGenerator.h
//  RSALib
//
//  Created by Stephan Bösebeck on 27.05.14.
//  Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInteger.h"

@protocol RandomPrimeGenerator <NSObject>

- (BigInteger*) nextPrime:(int) length;
@end

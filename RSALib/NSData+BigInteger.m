//
// Created by Stephan Bösebeck on 01.10.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSData+BigInteger.h"
#import "BigInteger.h"


@implementation NSData (BigInteger)

+ (NSData *)serializeInts:(NSArray *)bigInts {
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int i = 0; i < bigInts.count; i++) {
        [ret appendData:[((BigInteger *) bigInts[i]) bytes]];
    }
    return ret;
}


+ (NSData *)dataFromBigIntArray:(NSArray *)bigInts withBitLength:(int)bitLen {
    char *buffer = malloc(sizeof(char) * 4); //4byte = 1int
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int i = 0; i < bigInts.count; i++) {
        BigInteger *integer = (BigInteger *) bigInts[i];
//        NSLog(@"processing %@",integer);
        buffer[0] = buffer[1] = buffer[2] = buffer[3] = 0;
        //stepping through integers
        BOOL skip = YES;
        for (int j = (int) (integer.iVal - 1); j >= 0; j--) {
            int64_t v = 0;
            if (!integer.isSimple) {
                v = integer.data[j];
            } else {
                v = integer.iVal;
            }
            if (v == 0 && skip) continue; //leading zeros
            int idx = 0;
            char val = (char) ((v >> 24) & 0xff);
            int skipBytes = 0;
            if (val != 0 || !skip) {
                buffer[idx++] = val;
                skip = NO;
            } else {
                skipBytes++;
            }
            val = (char) ((v >> 16) & 0xff);
            if (val != 0 || !skip) {
                buffer[idx++] = val;
                skip = NO;
            } else {
                skipBytes++;
            }
            val = (char) ((v >> 8) & 0xff);
            if (val != 0 || !skip) {
                buffer[idx++] = val;
                skip = NO;
            } else {
                skipBytes++;
            }
            val = (char) ((v) & 0xff);
            if (val != 0 || !skip) {
                buffer[idx++] = val;
                skip = NO;
            } else {
                skipBytes++;
            }
            [ret appendBytes:buffer length:(NSUInteger) (4 - skipBytes)];
            if (integer.isSimple) break;
        }


    }
    return ret;
//    return nil;
}

- (NSArray *)deSerializeInts {
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.length;) {
        BigInteger *bi = [BigInteger fromBytes:self atOffset:&i];
        [ret addObject:bi];
    }
    return ret;
}

- (NSArray *)getIntegersofBitLength:(int)bitLen {
////take the self, chunks of bitsize - 1
//    //create BigInteger of it
//    //add self of bigInteger to nsself????
//    //padding?
//    //
//
    bitLen -= 32;
    int dataSize = (bitLen - 1) / 31; //bytes for this bitlength allowdd
    if ((bitLen - 1) % 31 != 0) {
        dataSize++;
    }
    int skip = 0;
    int numBis = self.length / dataSize / 4;
    if (self.length % (dataSize * 4) != 0) {
        numBis++;

    }

//    skip = self.length % sizeof (int64_t);


//    NSLog(@"ints allowed %d, own key length %d Bit, number of BigIntegers %d => Length of self to decode %d byte", dataSize, bitLen, numBis, (int) self.length);
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:(NSUInteger) numBis];

    char *buffer = malloc(self.length);

    NSRange range = NSMakeRange(0, self.length);

    [self getBytes:buffer range:range];
    while (ret.count < numBis) {
        //creating numBis integers
        for (int loc = 0; loc < self.length; loc += (dataSize * 4)) {
            int64_t *numDat = [BigInteger allocData:dataSize];
            int numDatIdx = dataSize - 1;
            range.location = (NSUInteger) loc;
            if (loc + dataSize * 4 > self.length) {
                range.length = self.length - loc;
                numDatIdx = range.length / 4;
                if (range.length % 4 == 0) numDatIdx--;
            } else {
                range.length = (NSUInteger) dataSize * 4;
            }


//            NSLog(@"Got buffer %d, %d    %@", range.location, range.length, [[NSData dataWithBytes:(buffer + range.location) length:range.length] hexDump:NO]);

            for (int i = range.location; i < range.location + range.length; i += 4) {
                unsigned char c = (unsigned char) buffer[i];
//                NSLog(@"Processing idx %d-%d", i, i + 4);
                int v = c << 24;
                if (i + 1 >= range.location + range.length) {
                    numDat[numDatIdx--] = v;
                    skip = 24;
                    break;
                }
                c = (unsigned char) buffer[i + 1];
                v |= c << 16;

                if (i + 2 >= range.location + range.length) {
                    numDat[numDatIdx--] = v;
                    skip = 16;
                    break;
                }
                c = (unsigned char) buffer[i + 2];
                v |= c << 8;

                if (i + 3 >= range.location + range.length) {
//                    v=v>>8;
                    numDat[numDatIdx--] = v;
                    skip = 8;
                    break;
                }
                c = (unsigned char) buffer[i + 3];
                v |= c;
                numDat[numDatIdx--] = v;
                skip = 0;
            }
            BigInteger *bi = [[BigInteger alloc] initWithData:numDat iVal:dataSize];
            if (numDatIdx > -1) {
                //need to skip bytes
                numDatIdx += 1;
                int64_t *arr = (int64_t *) [BigInteger allocData:(int) (bi.iVal - numDatIdx)];
                memcpy(arr, bi.data + numDatIdx, bi.iVal - numDatIdx);
                bi.data = arr;
                bi.iVal = bi.iVal - numDatIdx;
            }
//            NSLog(@"Created BigInteger Ints : %@", bi);
//            NSLog(@"  bits: %d, DataSize %d", bi.bitLength,bi.iVal);
            [ret addObject:bi];
        }


    }
    BigInteger *bi = [ret lastObject];
    if (skip > 0) {

        [ret removeLastObject];
        if (![bi isZero]) {
            bi = [bi shiftRight:skip];
//            bi=[bi or:[BigInteger valueOf:last]];
            [bi pack];
            if (![bi isZero])
                [ret addObject:bi];
        }
    }
    return ret;
}
@end
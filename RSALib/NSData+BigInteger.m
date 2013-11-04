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
        [ret appendData:[((BigInteger *) bigInts[i]) seralize]];
    }
    return ret;
}


+ (NSData *)dataFromBigIntArray:(NSArray *)bigInts {
    return [NSData dataFromBigIntArray:bigInts hasPrefix:YES];
}

+ (NSData *)dataFromBigIntArray:(NSArray *)bigInts hasPrefix:(BOOL)prefix {
    char *buffer = malloc(sizeof(char) * 4); //4byte = 1int
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int i = 0; i < bigInts.count; i++) {
        BigInteger *integer = (BigInteger *) bigInts[i];

//        NSLog(@"processing %@",integer);
        buffer[0] = buffer[1] = buffer[2] = buffer[3] = 0;
        //stepping through integers
        int j = (int) (integer.iVal - (prefix ? 2 : 1));
        int skipBytes = 0;
        if (prefix) {
            //read prefix, add bytes if not enough in BigInteger
            int pr = (int) integer.data[integer.iVal - 1];
            if (pr < (integer.iVal - 1) * 4) {
                //too many 000
                skipBytes = (int) ((integer.iVal - 1) * 4 - pr);
            }
        }
        int skip = skipBytes;
        for (; j >= 0; j--) {
            int64_t v = integer.data[j];
            int idx = 0;
            char val;
            if (skip > 0) {
                skip--;
            } else {
                val= = (char) ((v >> 24) & 0xff);
                buffer[idx++] = val;
            }

            
            if (skip > 0) {
                skip--;
            } else {
                val = (char) ((v >> 16) & 0xff);
                buffer[idx++] = val;
            }

            if (skip > 0) {
                skip--;
            } else {
                val = (char) ((v >> 8) & 0xff);
                buffer[idx++] = val;
            }

            if (skip > 0) {
                skip--;
            } else {
                buffer[idx++] = val;
                val = (char) ((v) & 0xff);
            }

            if (skipBytes > 4) {
                skipBytes = skipBytes - 4;
            } else {
                [ret appendBytes:buffer length:(NSUInteger) (4 - skipBytes)];
                skipBytes = 0;
            }
        }


    }
    free(buffer);
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
//    bitLen -= 32;
    int dataSize = (bitLen - 1) / 32; //bytes for this bitlength allowdd

    int numBis = self.length / dataSize / 4;
    if ((bitLen - 1) % 31 != 0) {
        numBis++;
    }
    int skip = 0;
    if (self.length % (dataSize * 4) != 0) {
        numBis++;
    }

    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:(NSUInteger) numBis];

    char *buffer = malloc(self.length);

    NSRange range = NSMakeRange(0, self.length);

    [self getBytes:buffer range:range];
//    while (ret.count < numBis) {
    //creating numBis integers
    for (int loc = 0; loc < self.length; loc += (dataSize * 4)) {
        int numDatIdx = 0;

        range.location = (NSUInteger) loc;
        if (loc + dataSize * 4 > self.length) {
            range.length = self.length - loc;
            dataSize = range.length / 4;
            if (range.length % 4 != 0) {
                dataSize++;
            }
        } else {
            range.length = (NSUInteger) dataSize * 4;
        }

        int64_t *numDat = [BigInteger allocData:dataSize + 1];


        //prefixing all bis - to make 00000000 possible
        numDat[dataSize] = dataSize * 4; //prefix number of bytes
        numDatIdx = dataSize - 1;

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

        BigInteger *bi = [[BigInteger alloc] initWithData:numDat iVal:dataSize + 1];
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
        [bi pack];
        [ret addObject:bi];
    }


//    }
    if (skip > 0) {
        BigInteger *bi = [ret lastObject];
        [ret removeLastObject];
        //remove prefix :/
        int64_t len = bi.data[bi.iVal - 1];
        len = len - skip / 8;
        bi.data[bi.iVal - 1] = 0;

        if (![bi isZero]) {
            bi = [bi shiftRight:skip];
//            bi=[bi or:[BigInteger valueOf:last]];
            [bi pack];
            int64_t *dat = [BigInteger allocData:(int) (bi.iVal + 1)];
            dat[bi.iVal] = len;

            for (int i = (int) (bi.iVal - 1); i >= 0; i--) {
                dat[i] = bi.data[i];
            }
            bi.data = dat;
            bi.iVal += 1;

            if (![bi isZero])
                [ret addObject:bi];
        }
    }
    return ret;
}
@end
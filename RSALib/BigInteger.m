//
// Created by Stephan Bösebeck on 22.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BigInteger.h"
#import "MPN.h"


@implementation BigInteger

static const int k[] = {100, 150, 200, 250, 300, 350, 400, 500, 600, 800, 1250, INT_MAX};

static const int t[] = {27, 18, 15, 12, 9, 8, 7, 6, 5, 4, 3, 2};
static int primes[] = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43,
/*Primes*/       47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107,
/*Primes*/       109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181,
/*Primes*/       191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281,
/*Primes*/       283, 293, 307, 311, 313, 317, 331, 337, 347, 349,
/*Primes*/       353, 359, 367, 373, 379, 383, 389, 397, 401, 409,
/*Primes*/       419, 421, 431, 433, 439, 443, 449, 457, 461, 463,
/*Primes*/       467, 479, 487, 491, 499, 503, 509, 521, 523, 541,
/*Primes*/       547, 557, 563, 569, 571, 577, 587, 593, 599, 601,
/*Primes*/       607, 613, 617, 619, 631, 641, 643, 647, 653, 659,
/*Primes*/       661, 673, 677, 683, 691, 701, 709, 719, 727, 733,
/*Primes*/       739, 743, 751, 757, 761, 769, 773, 787, 797, 809,
/*Primes*/       811, 821, 823, 827, 829, 839, 853, 857, 859, 863,
/*Primes*/       877, 881, 883, 887, 907, 911, 919, 929, 937, 941,
/*Primes*/       947, 953, 967, 971, 977, 983, 991, 997, 1009, 1013,
/*Primes*/       1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069,
/*Primes*/       1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123, 1129, 1151,
/*Primes*/       1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223,
/*Primes*/       1229, 1231, 1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291,
/*Primes*/       1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373,
/*Primes*/       1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451,
/*Primes*/       1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511,
/*Primes*/       1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583,
/*Primes*/       1597, 1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657,
/*Primes*/       1663, 1667, 1669, 1693, 1697, 1699, 1709, 1721, 1723, 1733,
/*Primes*/       1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811,
/*Primes*/       1823, 1831, 1847, 1861, 1867, 1871, 1873, 1877, 1879, 1889,
/*Primes*/       1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987,
/*Primes*/       1993, 1997, 1999, 2003, 2011, 2017, 2027, 2029, 2039, 2053,
/*Primes*/       2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129,
/*Primes*/       2131, 2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213,
/*Primes*/       2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287,
/*Primes*/       2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357,
/*Primes*/       2371, 2377, 2381, 2383, 2389, 2393, 2399, 2411, 2417, 2423,
/*Primes*/       2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503, 2521, 2531,
/*Primes*/       2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593, 2609, 2617,
/*Primes*/       2621, 2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687,
/*Primes*/       2689, 2693, 2699, 2707, 2711, 2713, 2719, 2729, 2731, 2741,
/*Primes*/       2749, 2753, 2767, 2777, 2789, 2791, 2797, 2801, 2803, 2819,
/*Primes*/       2833, 2837, 2843, 2851, 2857, 2861, 2879, 2887, 2897, 2903,
/*Primes*/       2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999,
/*Primes*/       3001, 3011, 3019, 3023, 3037, 3041, 3049, 3061, 3067, 3079,
/*Primes*/       3083, 3089, 3109, 3119, 3121, 3137, 3163, 3167, 3169, 3181,
/*Primes*/       3187, 3191, 3203, 3209, 3217, 3221, 3229, 3251, 3253, 3257,
/*Primes*/       3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331,
/*Primes*/       3343, 3347, 3359, 3361, 3371, 3373, 3389, 3391, 3407, 3413,
/*Primes*/       3433, 3449, 3457, 3461, 3463, 3467, 3469, 3491, 3499, 3511,
/*Primes*/       3517, 3527, 3529, 3533, 3539, 3541, 3547, 3557, 3559, 3571,
/*Primes*/       3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643,
/*Primes*/       3659, 3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727,
/*Primes*/       3733, 3739, 3761, 3767, 3769, 3779, 3793, 3797, 3803, 3821,
/*Primes*/       3823, 3833, 3847, 3851, 3853, 3863, 3877, 3881, 3889, 3907,
/*Primes*/       3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967, 3989,
/*Primes*/       4001, 4003, 4007, 4013, 4019, 4021, 4027, 4049, 4051, 4057,
/*Primes*/       4073, 4079, 4091, 4093, 4099, 4111, 4127, 4129, 4133, 4139,
/*Primes*/       4153, 4157, 4159, 4177, 4201, 4211, 4217, 4219, 4229, 4231,
/*Primes*/       4241, 4243, 4253, 4259, 4261, 4271, 4273, 4283, 4289, 4297,
/*Primes*/       4327, 4337, 4339, 4349, 4357, 4363, 4373, 4391, 4397, 4409,
/*Primes*/       4421, 4423, 4441, 4447, 4451, 4457, 4463, 4481, 4483, 4493,
/*Primes*/       4507, 4513, 4517, 4519, 4523, 4547, 4549, 4561, 4567, 4583,
/*Primes*/       4591, 4597, 4603, 4621, 4637, 4639, 4643, 4649, 4651, 4657,
/*Primes*/       4663, 4673, 4679, 4691, 4703, 4721, 4723, 4729, 4733, 4751,
/*Primes*/       4759, 4783, 4787, 4789, 4793, 4799, 4801, 4813, 4817, 4831,
/*Primes*/       4861, 4871, 4877, 4889, 4903, 4909, 4919, 4931, 4933, 4937,
/*Primes*/       4943, 4951, 4957, 4967, 4969, 4973, 4987, 4993, 4999, 5003,
/*Primes*/       5009, 5011, 5021, 5023, 5039, 5051, 5059, 5077, 5081, 5087,
/*Primes*/       5099, 5101, 5107, 5113, 5119, 5147, 5153, 5167, 5171, 5179,
/*Primes*/       5189, 5197, 5209, 5227, 5231, 5233, 5237, 5261, 5273, 5279,
/*Primes*/       5281, 5297, 5303, 5309, 5323, 5333, 5347, 5351, 5381, 5387,
/*Primes*/       5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443,
/*Primes*/       5449, 5471, 5477, 5479, 5483, 5501, 5503, 5507, 5519, 5521, -1};

static BigInteger *zero;
static BigInteger *one;
static BigInteger *two;
static BigInteger *ten;

//int64_t bitLength=0;
//int64_t certainty=100;

static int primeCount;
static int kCount;
/* Rounding modes: */
static const int FLOOR = 1;
static const int CEILING = 2;
static const int TRUNCATE = 3;
static const int ROUND = 4;


- (BOOL)isSimple {
    return (_data == nil);
}

- (void)setData:(int64_t *)data {
    if (_data != nil) {
//        NSLog(@"Resetting -> Deallocating %x, iVal %d, sz=%d", _data,_iVal,_iVal* sizeof(int32_t));
        free(_data);
    }
    _data = data;
}

- (void)dealloc {
    if (_data != nil) {
//        NSLog(@"Deallocating %x iVal=%d  sz=%d", _data,_iVal,_iVal* sizeof(int32_t));
        free(_data);
        _data = nil;
    }
}

+ (int64_t *)allocData:(int)size {
    size_t sz = (size_t) (size * sizeof(int64_t));
    int64_t *ptr = malloc(sz);
    for (int64_t i = 0; i < size; i++) {
        ptr[i] = 0;
    }
//    NSLog(@"Allocated: %x size: %d iVal: %d",ptr,sz,size);
    return ptr;
}

/**
* data: 4 bytes length in bytes => data1... dataN where data1-4 = int1, data5-8 = int2,...
*
*/
+ (BigInteger *)fromBytes:(NSData *)dat atOffset:(int *)offset {
//    char const *buffer = dat.bytes;
    int length = (int) [BigInteger getIntFrom:dat atIndex:(*offset)];

    size_t sizeT = 4; //sizeof(int64_t);
    int64_t *nums = [BigInteger allocData:length / sizeT];
    int64_t numIdx = length / sizeT;
    for (int64_t idx = (*offset) + sizeT; idx < (*offset) + length + sizeT; idx += sizeT) {
        int64_t v = [BigInteger getIntFrom:dat atIndex:idx];
        nums[--numIdx] = v;
    }
    *offset = *offset + length + sizeT;
    BigInteger *ret = [[BigInteger alloc] initWithData:nums iVal:length / sizeT];
    return ret;
}


- (NSData *)bytes {
    [self pack];
    NSMutableData *dat = [[NSMutableData alloc] init];
    char buffer[] = {0, 0, 0, 0};
    //first 4 bytes == integer show length of this integer
    // eg: 000004 => 4 bytes in length
    // if < then maxValueInt => 4 bytes
    if (self.data == nil) {
        //use iVal only
        [BigInteger fillInteger:4 into:buffer];
        [dat appendBytes:buffer length:4];
        [BigInteger fillInteger:self.iVal into:buffer];
        [dat appendBytes:buffer length:4];
        return dat;
    }

    [BigInteger fillInteger:self.iVal * 4 into:buffer];
    [dat appendBytes:buffer length:4];

    for (int64_t j = self.iVal - 1; j >= 0; j--) {
        int64_t v = (int32_t) self.data[j];
//        if (j == self.dataSize - 1 && v == 0) continue; //Why!??!?!?
        [BigInteger fillInteger:v into:buffer];
        [dat appendBytes:buffer length:4];
    }

    return dat;
}

+ (uint64_t)getIntFrom:(NSData *)dat atIndex:(int)idx {
    unsigned char const *buffer = dat.bytes;
    uint64_t v = 0;
    v |= buffer[idx + 0] << 24;
    v |= buffer[idx + 1] << 16;
    v |= buffer[idx + 2] << 8;
    v |= buffer[idx + 3];
    return v;

}

+ (void)fillInteger:(int64_t)v into:(char *)buffer {
    [BigInteger fillInteger:v into:buffer atPos:0];
}

+ (void)fillInteger:(int64_t)v into:(char *)buffer atPos:(int64_t)position {
    buffer[0 + position] = (char) ((((uint32_t) v) >> 24) & 0xff);
    buffer[1 + position] = (char) ((((uint32_t) v) >> 16) & 0xff);
    buffer[2 + position] = (char) ((((uint32_t) v) >> 8) & 0xff);
    buffer[3 + position] = (char) ((((uint32_t) v)) & 0xff);
}

+ (void)initialize {
    if (self == [BigInteger class]) {
        srandom((unsigned int) time(NULL));

        primeCount = 0;
        for (; ; primeCount++) {
            if (primes[primeCount] == -1) {
                break;
            }
        }
        kCount = 0;
        for (; ; kCount++) {
            if (k[kCount] == INT_MAX) {
                break;
            }
        }
    }
}

- (id)initWithData:(int64_t *)data iVal:(int64_t)size {
    self = [super init];
    if (self) {
        BOOL isZero = YES;
        for (int64_t i = 0; i < size; i++) {
            if (data[i] != 0) {
                isZero = NO;
                break;
            }
        }
        if (size == 1) {
            self.iVal = data[0];
            self.data = nil;
        } else if (size == 0 || isZero) {
            self.iVal = 0;
            self.data = nil;
        } else {
            self.data = data;
            self.iVal = size;
            [self pack];
        }
    }

    return self;
}

- (id)initWith:(int64_t)value {
    self = [super init];
    if (self) {
        self.iVal = value;
    }

    return self;
}

+ (BigInteger *)randomBigInt:(int)bits {
    BigInteger *ret = [[BigInteger alloc] initWithRandomBits:bits];
    return ret;
}


+ (BigInteger *)bigIntegerWithBigInteger:(BigInteger *)b {
    BigInteger *ret = [[BigInteger alloc] init];
    if ([b isSimple]) {
        ret.iVal = b.iVal;
        ret.data = nil;
    } else {
        ret.data = (int64_t *) [BigInteger allocData:(int) b.iVal];
        memcpy(ret.data, b.data, (size_t) b.iVal * (sizeof(int64_t)));
        ret.iVal = b.iVal;
    }

    return ret;
}

+ (void)divide:(int64_t)x by:(int64_t)y quotient:(BigInteger *)quotient remainder:(BigInteger *)remainder usingRoundingMode:(int)rounding_mode {
    BOOL xNegative, yNegative;
    if (x < 0) {
        xNegative = YES;
        if (x == LONG_MIN) {
            [BigInteger divideBig:[BigInteger valueOf:x] by:[BigInteger valueOf:y] quotient:quotient remainder:remainder usingRoundingMode:rounding_mode];
            return;
        }
        x = -x;
    }
    else
        xNegative = NO;

    if (y < 0) {
        yNegative = YES;
        if (y == LONG_MIN) {
            if (rounding_mode == TRUNCATE) { // x != Long.Min_VALUE implies abs(x) < abs(y)
                if (quotient != nil)
                    [quotient set:0];
                if (remainder != nil)
                    [remainder set:x];
            }
            else
                [BigInteger divideBig:[BigInteger valueOf:x] by:[BigInteger valueOf:y] quotient:quotient remainder:remainder usingRoundingMode:rounding_mode];
            return;
        }
        y = -y;
    }
    else
        yNegative = NO;

    int64_t q = (int64_t) (x / y);
    int64_t r = x % y;
    BOOL qNegative = xNegative ^ yNegative;

    BOOL add_one = NO;
    if (r != 0) {
        switch (rounding_mode) {
            case TRUNCATE:
                break;
            case CEILING:
            case FLOOR:
                if (qNegative == (rounding_mode == FLOOR))
                    add_one = YES;
                break;
            case ROUND:
                add_one = r > ((y - (q & 1)) >> 1);
                break;
            default:
                break;
        }
    }
    if (quotient != nil) {
        if (add_one)
            q++;
        if (qNegative)
            q = -q;
        [quotient set:q];
    }
    if (remainder != nil) {
        // The remainder is by definition: X-Q*Y
        if (add_one) {
            // Subtract the remainder from Y.
            r = y - r;
            // In this case, abs(Q*Y) > abs(X).
            // So sign(remainder) = -sign(X).
            xNegative = !xNegative;
        }
        else {
            // If !add_one, then: abs(Q*Y) <= abs(X).
            // So sign(remainder) = sign(X).
        }
        if (xNegative)
            r = -r;
        [remainder set:r];
    }
}

- (int)intValue {
    if (self.isSimple)
        return (int) self.iVal;
    return (int) self.data[0];
}

- (int64_t)longValue {
    if (self.isSimple)
        return self.iVal;
    if (self.iVal == 1)
        return self.data[0];
    return ((int64_t) self.data[1] << 32) + ((int64_t) self.data[0] & 0xffffffffL);
}

/** Copy the abolute value of this into an array of words.
 * Assumes words.length >= (this.words == null ? 1 : this.ival).
 * Result is zero-extended, but need not be a valid 2's complement number.
 */
- (void)getAbsolute:(int64_t *)words length:(int)wlen {
    int len;
    if (self.isSimple) {
        len = 1;
        words[0] = self.iVal;
    }
    else {
        len = (int) self.iVal;
        for (int i = len; --i >= 0;)
            words[i] = self.data[i];

    }
    if ((int32_t) words[len - 1] < 0)
        [BigInteger negate:words src:words len:len];
    for (int i = wlen; --i > len;)
        words[i] = 0;
}

/** Divide two integers, yielding quotient and remainder.
    * @param x the numerator in the division
    * @param y the denominator in the division
    * @param quotient is set to the quotient of the result (iff quotient!=nil)
    * @param remainder is set to the remainder of the result
    *  (iff remainder!=nil)
    * @param rounding_mode one of FLOOR, CEILING, TRUNCATE, or ROUND.
    */
+ (void)divideBig:(BigInteger *)x by:(BigInteger *)y quotient:(BigInteger *)quotient remainder:(BigInteger *)remainder usingRoundingMode:(int)rounding_mode {
//    NSLog(@"Dividing...");
    if ((x.isSimple || x.iVal <= 2)
            && (y.isSimple || y.iVal <= 2)) {
        int64_t x_l = [x longValue];
        int64_t y_l = [y longValue];
        if (x_l != LONG_MIN && y_l != LONG_MIN) {
            [BigInteger divide:x_l by:y_l quotient:quotient remainder:remainder usingRoundingMode:rounding_mode];
            return;
        }
    }

    if ([x isEqualTo:y]) {
        if (remainder != nil) {
            remainder.data = nil;
            remainder.iVal = 0;
        }
        if (quotient != nil) {
            quotient.iVal = 1;
            quotient.data = nil;
        }
        return;
    }
    BOOL xNegative = [x isNegative];
    BOOL yNegative = [y isNegative];
    BOOL qNegative = xNegative ^ yNegative;

    int ylen = (int) ((y.isSimple) ? 1 : y.iVal);
    int64_t *ywords = [BigInteger allocData:ylen + 1];
    [y getAbsolute:ywords length:ylen];
    while (ylen > 1 && ywords[ylen - 1] == 0) ylen--;


    int xlen = (int) ((x.isSimple) ? 1 : x.iVal);
    int64_t *xwords = [BigInteger allocData:(xlen + 2)];
    [x getAbsolute:xwords length:xlen];
    while (xlen > 1 && xwords[xlen - 1] == 0) xlen--;

    int qlen, rlen;

    int cmpval = [MPN cmp:xwords xlen:xlen y:ywords ylen:ylen];
    if (cmpval < 0)  // abs(x) < abs(y)
    { // quotient = 0;  remainder = num.
        int64_t *rwords = xwords;
        xwords = ywords;
        ywords = rwords;
        rlen = xlen;
        qlen = 1;
        xwords[0] = 0;
    }
    else if (cmpval == 0)  // abs(x) == abs(y)
    {
        xwords[0] = 1;
        qlen = 1;  // quotient = 1
        ywords[0] = 0;
        rlen = 1;  // remainder = 0;
    }
    else if (ylen == 1) {
        qlen = xlen;
        // Need to leave room for a word of leading zeros if dividing by 1
        // and the dividend has the high bit set.  It might be safe to
        // increment qlen in all cases, but it certainly is only necessary
        // in the following case.
        if (ywords[0] == 1 && xwords[xlen - 1] < 0)
            qlen++;
        rlen = 1;
        ywords[0] = [MPN divmod_1:xwords divident:xwords len:xlen divisor:ywords[0]];
    }
    else  // abs(x) > abs(y)
    {
        // Normalize the denominator, i.e. make its most significant bit set by
        // shifting it normalization_steps bits to the left.  Also shift the
        // numerator the same number of steps (to keep the quotient the same!).

        int nshift = [MPN count_leading_zeros:ywords[ylen - 1]];
        if (nshift != 0) {
            // Shift up the denominator setting the most significant bit of
            // the most significant word.
            [MPN lshift:ywords d_offset:0 x:ywords len:ylen count:nshift];

            // Shift up the numerator, possibly introducing a new most
            // significant word.
            int64_t x_high = [MPN lshift:xwords d_offset:0 x:xwords len:xlen count:nshift];

            xwords[xlen++] = x_high;
        }

        if (xlen == ylen)
            xwords[xlen++] = 0;
        [MPN divide:xwords nx:xlen y:ywords ny:ylen];
        rlen = ylen;
        [MPN rshift0:ywords x:xwords x_start:0 len:rlen count:nshift];

        qlen = xlen + 1 - ylen;
        if (quotient != nil) {
            for (int64_t i = 0; i < qlen; i++)
                xwords[i] = xwords[i + ylen];
        }
    }
    if ((int32_t) ywords[rlen - 1] < 0) {
        ywords[rlen] = 0;
        rlen++;
    }

    // Now the quotient is in xwords, and the remainder is in ywords.

    BOOL add_one = NO;
    BigInteger *tmp;
    if (rlen > 1 || ywords[0] != 0) { // Non-zero remainder i.e. in-exact quotient.
        switch (rounding_mode) {
            case TRUNCATE:
                break;
            case CEILING:
            case FLOOR:
                if (qNegative == (rounding_mode == FLOOR))
                    add_one = YES;
                break;
            case ROUND:
                // int64_t cmp = compareTo(remainder<<1, abs(y));
                tmp = remainder == nil ? [[BigInteger alloc] init] : remainder;
                [tmp set:ywords len:rlen];
                tmp = [BigInteger shift:tmp count:1];
                if (yNegative)
                    [tmp setNegative];
                int64_t cmp = [BigInteger compare:tmp to:y];
                // Now cmp == compareTo(sign(y)*(remainder<<1), y)
                if (yNegative)
                    cmp = -cmp;
                add_one = (cmp == 1) || (cmp == 0 && (xwords[0] & 1) != 0);
            default:
                break;
        }
    }
    if (quotient != nil) {
        [quotient set:xwords len:qlen];
        if (qNegative) {
            if (add_one)  // -(quotient + 1) == ~(quotient)
                [quotient setInvert];
            else
                [quotient setNegative];
        }
        else if (add_one)
            [quotient setAdd:1];
    }

    if (remainder != nil) {

        // The remainder is by definition: X-Q*Y
        [remainder set:ywords len:rlen];
        if (add_one) {
            // Subtract the remainder from Y:
            // abs(R) = abs(Y) - abs(orig_rem) = -(abs(orig_rem) - abs(Y)).
            BigInteger *tmp;
            if (y.isSimple) {
                tmp = remainder;
                [tmp set:yNegative ? ywords[0] + y.iVal : ywords[0] - y.iVal];
            }
            else
                tmp = [BigInteger add:remainder y:y k:yNegative ? 1 : -1];
            // Now tmp <= 0.
            // In this case, abs(Q) = 1 + floor(abs(X)/abs(Y)).
            // Hence, abs(Q*Y) > abs(X).
            // So sign(remainder) = -sign(X).
            if (xNegative)
                [remainder setNegative:tmp];
            else {
                remainder.iVal = tmp.iVal;
                remainder.data = (int64_t *) [BigInteger allocData:(int) tmp.iVal];
                memcpy(remainder.data, tmp.data, (size_t) tmp.iVal * (sizeof(int64_t)));
            }
        }
        else {
            // If !add_one, then: abs(Q*Y) <= abs(X).
            // So sign(remainder) = sign(X).
            if (xNegative)
                [remainder setNegative];
        }
//        BOOL isNull = YES;
//        for (int srch = 0; srch < rlen; srch++) {
//            if (remainder.data[srch] != 0) {
//                isNull = NO;
//                break;
//            }
//        }
//        if (isNull) {
//            remainder.data = nil;
//        }
//        [remainder pack];
    }
}

+ (BigInteger *)neg:(BigInteger *)x {
    if (x.isSimple && x.iVal != INT_MIN)
        return [BigInteger valueOf:(-x.iVal)];
    BigInteger *result = [[BigInteger alloc] init];
    [result setNegative:(x)];
    return [result canonicalize];
}

- (BigInteger *)negate {
    return [BigInteger neg:(self)];
}

+ (BigInteger *)times:(BigInteger *)x y:(int64_t)y {
    if (y == 0)
        return [BigInteger valueOf:0];
    if (y == 1)
        return x;
    int64_t *xwords = x.data;
    int64_t xlen = x.iVal;
    if (xwords == nil)
        return [BigInteger valueOf:((int64_t) xlen * (int64_t) y)];
    BOOL negative;
    BigInteger *result = [[BigInteger alloc] init];
    if (xwords[xlen - 1] < 0) {
        result.data = [BigInteger allocData:(int) (xlen + 1)];
        negative = YES;
        [BigInteger negate:result.data src:xwords len:xlen];
        xwords = result.data;
    }
    else
        negative = NO;
    if (y < 0) {
        negative = !negative;
        y = -y;
    }
    if (result.data == nil) {
        result.data = [BigInteger allocData:(int) (xlen + 1)];
    }
    result.data[xlen] = [MPN mul_1:result.data x:xwords len:xlen y:y];
    result.iVal = xlen + 1;
    if (negative)
        [result setNegative];
    return [result canonicalize];
}

+ (BigInteger *)times:(BigInteger *)x yBig:(BigInteger *)y {
    if (y.isSimple)
        return [BigInteger times:x y:y.iVal];
    if (x.isSimple)
        return [BigInteger times:y y:x.iVal];
    BOOL negative = NO;
    int64_t *xwords;
    int64_t *ywords;
    int64_t xlen = x.iVal;
    int64_t ylen = y.iVal;
    if ([x isNegative]) {
        negative = YES;
        xwords = [BigInteger allocData:(int) xlen];
        [BigInteger negate:xwords src:x.data len:xlen];
    }
    else {
        negative = NO;
        xwords = x.data;
    }
    if ([y isNegative]) {
        negative = !negative;
        ywords = [BigInteger allocData:(int) ylen];
        [BigInteger negate:ywords src:y.data len:ylen];
    }
    else
        ywords = y.data;
    // Swap if x is shorter then y.
    if (xlen < ylen) {
        int64_t *twords = xwords;
        xwords = ywords;
        ywords = twords;
        int64_t tlen = xlen;
        xlen = ylen;
        ylen = tlen;
    }
    BigInteger *result = [[BigInteger alloc] init];
    result.data = [BigInteger allocData:(int) (xlen + ylen)];

    [MPN mul:result.data x:xwords xlen:xlen y:ywords ylen:ylen];
    result.iVal = xlen + ylen;
    if (negative)
        [result setNegative];
    return [result canonicalize];
}

- (BigInteger *)multiply:(BigInteger *)y {
    return [BigInteger times:self yBig:y];
}

- (BigInteger *)subtract:(BigInteger *)val {
    return [BigInteger add:self y:val k:-1];
}

/** Add two BigIntegers, yielding their sum as another BigInteger. */
+ (BigInteger *)add:(BigInteger *)x y:(BigInteger *)y k:(int64_t)k {
    if (x.isSimple && y.isSimple)
        return [BigInteger valueOf:((long) k * (long) y.iVal + (long) x.iVal)];
    if (k != 1) {
        if (k == -1)
            y = [BigInteger neg:(y)];
        else
            y = [BigInteger times:y yBig:[BigInteger valueOf:k]];
    }
    if (x.isSimple)
        return [BigInteger addBig:y y:x.iVal];
    if (y.isSimple)
        return [BigInteger addBig:x y:y.iVal];
    // Both are big
    if (y.iVal > x.iVal) { // Swap so x is longer then y.
        BigInteger *tmp = x;
        x = y;
        y = tmp;
    }
    BigInteger *result = [[BigInteger alloc] init];
    result.data = [BigInteger allocData:x.iVal + 1];
    int64_t i = y.iVal;
    int64_t carry = [MPN add_n:result.data x:x.data y:y.data len:i];
    int64_t y_ext = y.data[i - 1] < 0 ? 0xffffffffL : 0;
    for (; i < x.iVal; i++) {
        carry += ((int32_t) x.data[i] & 0xffffffffL) + y_ext;
        result.data[i] = (int64_t) carry;
        carry >>= 32;
    }
    if (x.data[i - 1] < 0)
        y_ext--;
    result.data[i] = (int32_t) (carry + y_ext);
    result.iVal = i + 1;
    return [result canonicalize];
}

- (BigInteger *)add:(BigInteger *)val {
    return [BigInteger add:self y:val k:1];
}

/** Add two ints, yielding a BigInteger. */
+ (BigInteger *)add:(int64_t)x y:(int64_t)y {
    return [BigInteger valueOf:((long) x + (long) y)];
}

/** Add a BigInteger and an int64_t, yielding a new BigInteger. */
+ (BigInteger *)addBig:(BigInteger *)x y:(int64_t)y {
    if (x.isSimple)
        return [BigInteger add:(x.iVal) y:y];
    BigInteger *result = [[BigInteger alloc] init];
    [result setAdd:x y:y];
    return [result canonicalize];
}

/** Set this to the sum of x and y.
 * OK if x==this. */
- (void)setAdd:(BigInteger *)x y:(int64_t)y {
    if (x.isSimple) {
        [self set:((long) x.iVal + (long) y)];
        return;
    }
    int64_t len = x.iVal;
    [self realloc:(int) (len + 1)];
    int64_t carry = y;
    for (int i = 0; i < len; i++) {
        carry += ((int64_t) x.data[i] & 0xffffffffL);
        self.data[i] = (int32_t) carry;
        carry >>= 32;
    }
    if (x.data[len - 1] < 0)
        carry--;
    self.data[len] = (int32_t) carry;
    self.iVal = [BigInteger wordsNeeded:self.data len:(int) (len + 1)];
}

/** Destructively add an int64_t to this. */
- (void)setAdd:(int64_t)y {
    [self setAdd:self y:y];
}


- (void)setInvert {
    if (self.isSimple)
        self.iVal = ~self.iVal;
    else {
        for (int64_t i = self.iVal; --i >= 0;)
            self.data[i] = ~self.data[i];
    }
}


+ (int)compare:(BigInteger *)x to:(BigInteger *)y {
    if (x.isSimple && y.isSimple)
        return x.iVal < y.iVal ? -1 : x.iVal > y.iVal ? 1 : 0;
    BOOL x_negative = [x isNegative];
    BOOL y_negative = [y isNegative];
    if (x_negative != y_negative)
        return x_negative ? -1 : 1;
    int64_t x_len = x.isSimple ? 1 : x.iVal;
    int64_t y_len = y.isSimple ? 1 : y.iVal;
    if (x_len != y_len)
        return (x_len > y_len) != x_negative ? 1 : -1;
    return [MPN cmp:x.data y:y.data size:x_len];
}

/** @since 1.2 */
- (int)compareTo:(BigInteger *)val {
    return [BigInteger compare:self to:val];
}


/** Destructively set this to the negative of x.
 * It is OK if x==this.*/
- (void)setNegative:(BigInteger *)x {
    int64_t len = x.iVal;
    if (x.isSimple) {
        if (len == INT_MIN)
            [self set:-(int64_t) len];
        else
            [self set:(-len)];
        return;
    }
    [self realloc:(len + 1)];
    if ([BigInteger negate:self.data src:x.data len:len])
        self.data[len++] = 0;
    self.iVal = len;
}

/** Destructively negate this. */
- (void)setNegative {
    [self setNegative:self];
}

- (BigInteger *)divideBy:(BigInteger *)val {
    if ([val isZero])
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"division by zero" userInfo:nil];

    BigInteger *quot = [BigInteger valueOf:0];
    [BigInteger divideBig:self by:val quotient:quot remainder:nil usingRoundingMode:TRUNCATE];
    return [quot canonicalize];
}

- (BigInteger *)remainder:(BigInteger *)val {
    if ([val isZero])
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"modulo zero?" userInfo:nil];

    BigInteger *rem = [[BigInteger alloc] initWith:0];
    [BigInteger divideBig:self by:val quotient:nil remainder:rem usingRoundingMode:TRUNCATE];
    return [rem canonicalize];
}

- (NSArray *)divideAndRemainder:(BigInteger *)val {
    if ([val isZero])
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"divide by zero" userInfo:nil];

    NSArray *result = [[NSArray alloc] initWithObjects:[[BigInteger alloc] initWith:0], [[BigInteger alloc] initWith:0], nil];
    [BigInteger divideBig:self by:val quotient:result[0] remainder:result[1] usingRoundingMode:TRUNCATE];
    [result[0] canonicalize];
    [result[1] canonicalize];
    return result;
}

- (BigInteger *)mod:(BigInteger *)m {
    if ([m isNegative] || [m isZero])
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"non-positivve modulo" userInfo:nil];
    BigInteger *rem = [[BigInteger alloc] initWith:0];
    [BigInteger divideBig:self by:m quotient:nil remainder:rem usingRoundingMode:FLOOR];
    if (rem == nil) {
        NSLog(@"Something is wrong!");
    }
    return [rem canonicalize];
}

/** Destructively set the value of this to the given words.
   * The words array is reused, not copied. */
- (void)set:(int64_t *)words len:(int64_t)length {
    self.iVal = length;
    self.data = words;
}

/** Calculates ceiling(log2(this < 0 ? -this : this+1))
    * See Common Lisp: the Language, 2nd ed, p. 361.
    */
- (int)bitLength {
    if (self.isSimple)
        return [MPN intLength:(self.iVal)];
    return [MPN intLength:self.data len:self.iVal];
}

/**
 * <p>Returns <code>YES</code> if this BigInteger is probably prime,
 * <code>NO</code> if it's definitely composite. If <code>certainty</code>
 * is <code><= 0</code>, <code>YES</code> is returned.</p>
 *
 * @param certainty a measure of the uncertainty that the caller is willing
 * to tolerate: if the call returns <code>YES</code> the probability that
 * this BigInteger is prime exceeds <code>(1 - 1/2<sup>certainty</sup>)</code>.
 * The execution time of this method is proportional to the value of this
 * parameter.
 * @return <code>YES</code> if this BigInteger is probably prime,
 * <code>NO</code> if it's definitely composite.
 */
- (BOOL)isProbablePrime:(int)certainty {
    if (certainty < 1) {
        NSLog(@"Certainty <=0????");
        return YES;
    }

    /** We'll use the Rabin-Miller algorithm for doing a probabilistic
     * primality test.  It is fast, easy and has faster decreasing odds of a
     * composite passing than with other tests.  This means that this
     * method will actually have a probability much greater than the
     * 1 - .5^certainty specified in the JCL (p. 117), but I don't think
     * anyone will complain about better performance with greater certainty.
     *
     * The Rabin-Miller algorithm can be found on pp. 259-261 of "Applied
     * Cryptography, Second Edition" by Bruce Schneier.
     */

    // First rule out small prime factors
    BigInteger *rem = [[BigInteger alloc] init];
    int i;
    for (i = 0; i < primeCount; i++) {
        if (self.isSimple && self.iVal == primes[i])
            return YES;
        // int64_t idx = primes[i] - MINFIXNUMS;
//        if (idx > fixNum.count - 1) {
        [BigInteger divideBig:self by:[BigInteger valueOf:primes[i]] quotient:nil remainder:rem usingRoundingMode:TRUNCATE];
//        } else {
//            [BigInteger divideBig:self by:fixNum[idx] quotient:nil remainder:rem usingRoundingMode:TRUNCATE];
//        }
        if ([[rem canonicalize] isZero])
            return NO;
    }

    // Now perform the Rabin-Miller test.

    // Set b to the number of times 2 evenly divides (this - 1).
    // I.e. 2^b is the largest power of 2 that divides (this - 1).
    BigInteger *pMinus1 = [BigInteger addBig:self y:-1];
    int64_t b = [pMinus1 getLowestSetBit];

    // Set m such that this = 1 + 2^b * m.
    int64_t val = ((int64_t) 2L) << (b - 1);
    BigInteger *m = [pMinus1 divideBy:[BigInteger valueOf:val]];
    if ([m isNegative]) {
        m = [m negate];
//        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"non-positivve modulo" userInfo:nil];
    }

    // The HAC (Handbook of Applied Cryptography), Alfred Menezes & al. Note
    // 4.49 (controlling the error probability) gives the number of trials
    // for an error probability of 1/2**80, given the number of bits in the
    // number to test.  we shall use these numbers as is if/when 'certainty'
    // is less or equal to 80, and twice as much if it's greater.
    int bits = [self bitLength];
    for (i = 0; i < kCount; i++)
        if (bits <= k[i])
            break;
    int64_t trials = t[i];
    if (certainty > 80)
        trials *= 2;
    BigInteger *z;
    for (int t = 0; t < trials; t++) {
        // The HAC (Handbook of Applied Cryptography), Alfred Menezes & al.
        // Remark 4.28 states: "...A strategy that is sometimes employed
        // is to fix the bases a to be the first few primes instead of
        // choosing them at random.
        z = [[BigInteger valueOf:primes[t]] modPow:m modulo:self];
        if ([z isOne] || [z isEqualTo:pMinus1])
            continue;            // Passes the test; may be prime.

        for (i = 0; i < b;) {
            if ([z isOne])
                return NO;
            i++;
            if ([z isEqualTo:pMinus1])
                break;            // Passes the test; may be prime.

            z = [z modPow:[BigInteger valueOf:2] modulo:self];
        }

        if (i == b && ![z isEqualTo:pMinus1])
            return NO;
    }
    return YES;
}

+ (int64_t *)euclidInv:(int64_t)a b:(int64_t)b preDiv:(int64_t)prevDiv {
    if (b == 0) {
        @throw [NSException exceptionWithName:@"ArithmeticException" reason:@"not invertible" userInfo:nil];
    }

    if (b == 1) {
        // Success:  values are indeed invertible!
        // Bottom of the recursion reached; start unwinding.
        int64_t *ret = [BigInteger allocData:2];
        ret[0] = -prevDiv;
        ret[1] = 1;
        return ret;
    }
    int64_t *xy = [BigInteger euclidInv:b b:a % b preDiv:a / b];    // Recursion happens here.
    a = xy[0]; // use our local copy of 'a' as a work var
    xy[0] = a * -prevDiv + xy[1];
    xy[1] = a;
    return xy;
}

+ (void)euclidInv:(BigInteger *)a b:(BigInteger *)b preDiv:(BigInteger *)prevDiv xy:(NSMutableArray *)xy {
    if ([b isZero]) {
        @throw [NSException exceptionWithName:@"ArithmeticException" reason:@"b is null" userInfo:nil];
    }

//    NSLog(@"in euclidInv a: %@ b: %@ preDiv:%@",a,b,prevDiv);

    if ([b isOne]) {
        // Success:  values are indeed invertible!
        // Bottom of the recursion reached; start unwinding.
        xy[0] = [BigInteger neg:prevDiv];
        xy[1] = [BigInteger valueOf:1];
        return;
    }

    // Recursion happens in the following conditional!

    // If a just contains an int64_t, then use integer math for the rest.
    if (a.isSimple) {
        int64_t *xyInt = [BigInteger euclidInv:b.iVal b:a.iVal % b.iVal preDiv:a.iVal / b.iVal];
        xy[0] = [BigInteger valueOf:(int32_t) (xyInt[0])];
        xy[1] = [BigInteger valueOf:(int32_t) (xyInt[1])];
//        NSLog(@"Euclidinv (simple) returned %@,%@", xy[0], xy[1]);
    }
    else {
        BigInteger *rem = [[BigInteger alloc] init];
        BigInteger *quot = [[BigInteger alloc] init];
//        BigInteger *tst=[BigInteger valueOf:@"A432A0EC03A42121" usingRadix:16];
//        if ([[a description] isEqual:@"27F2BB8AF7480D73"]) {
//            NSLog(@"Found it!");
//        }
        [BigInteger divideBig:a by:b quotient:quot remainder:rem usingRoundingMode:FLOOR];
        // quot and rem may not be in canonical form. ensure
//        NSLog(@"Divide %@ / %@ = %@ rem %@ ival=%d",a,b,quot,rem,rem.iVal);
        [rem canonicalize];
        [quot canonicalize];
        [BigInteger euclidInv:b b:rem preDiv:quot xy:xy];
//        NSLog(@"Euclidinv returned %@,%@", xy[0], xy[1]);
    }

    BigInteger *t = xy[0];
//    NSLog(@"Processing data: xy1: %@ t:%@ prevdiv: %@", xy[1], t, prevDiv);
    xy[0] = [BigInteger add:xy[1] y:[BigInteger times:t yBig:prevDiv] k:-1];
    xy[1] = t;
}

- (void)pack {
    BOOL neg = [self isNegative];
    BOOL rebuild = NO;
    if (_data == nil) {
        return;
    }
    while (_data[_iVal - 1] == 0 && _iVal > 0) {
        _iVal--;
        rebuild = YES;
        if (neg != [self isNegative]) {
            _iVal++;
            return;
        }
    }
    if (_iVal == 1) {
        _iVal = _data[0];
        _data = nil;
        return;
    }
    if (_iVal == 0) {
        _data = nil;
        return;
    }
    if (rebuild) {
        int64_t *newDat = [BigInteger allocData:_iVal];
        for (int64_t i = 0; i < _iVal; i++) {
            newDat[i] = _data[i];
        }
        //free(_data);
        _data = newDat;
    }


}

- (BigInteger *)modInverse:(BigInteger *)y {
    if ([y isNegative] || [y isZero]) {
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"non-positivve modulo" userInfo:nil];
    }


    // Degenerate cases.
    if ([y isOne])
        return zero;
    if ([self isOne])
        return [BigInteger valueOf:1];

    // Use Euclid's algorithm as in gcd() but do this recursively
    // rather than in a loop so we can use the intermediate results as we
    // unwind from the recursion.
    // Used http://www.math.nmsu.edu/~crypto/EuclideanAlgo.html as reference.
    BigInteger *result = [[BigInteger alloc] init];
    BOOL swapped = NO;

    if (y.isSimple) {
        // The result is guaranteed to be less than the modulus, y (which is
        // an int64_t), so simplify this by working with the int64_t result of this
        // modulo y.  Also, if this is negative, make it positive via modulo
        // math.  Note that BigInteger.mod() must be used even if this is
        // already an int64_t as the % operator would provide a negative result if
        // this is negative, BigInteger.mod() never returns negative values.
        int64_t xval = (self.data != nil || [self isNegative]) ? [self mod:y].iVal : self.iVal;
        int64_t yval = y.iVal;

        // Swap values so x > y.
        if (yval > xval) {
            int64_t tmp = xval;
            xval = yval;
            yval = tmp;
            swapped = YES;
        }
        // Normally, the result is in the 2nd element of the array, but
        // if originally x < y, then x and y were swapped and the result
        // is in the 1st element of the array.
        result.iVal = [BigInteger euclidInv:yval b:xval % yval preDiv:xval / yval][swapped ? 0 : 1];

        // Result can't be negative, so make it positive by adding the
        // original modulus, y.ival (not the possibly "swapped" yval).
        if ((int32_t) result.iVal < 0)
            result.iVal += y.iVal;
    }
    else {
        // As above, force this to be a positive value via modulo math.
        BigInteger *x = [self isNegative] ? [self mod:y] : self;

        // Swap values so x > y.
        if ([x compareTo:y] < 0) {
            result = x;
            x = y;
            y = result; // use 'result' as a work var
            swapped = YES;
        }
        // As above (for ints), result will be in the 2nd element unless
        // the original x and y were swapped.
        BigInteger *rem = [[BigInteger alloc] init];
        BigInteger *quot = [[BigInteger alloc] init];
        [BigInteger divideBig:x by:y quotient:quot remainder:rem usingRoundingMode:FLOOR];
        // quot and rem may not be in canonical form. ensure
        [rem canonicalize];
        [quot canonicalize];
        NSMutableArray *xy = [[NSMutableArray alloc] initWithCapacity:2];
        [BigInteger euclidInv:y b:rem preDiv:quot xy:xy];
        result = swapped ? xy[0] : xy[1];

        // Result can't be negative, so make it positive by adding the
        // original modulus, y (which is now x if they were swapped).
        if ([result isNegative])
            result = [BigInteger add:result y:swapped ? x : y k:1];
    }

    return result;
}

- (BigInteger *)modPow:(BigInteger *)exponent modulo:(BigInteger *)m {
    if ([m isNegative] || [m isZero]) {
        NSString *reason = [NSString stringWithFormat:@"Non-positive modulo: %@", m];
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:reason userInfo:nil];
    }

    if ([exponent isNegative])
        return [[self modInverse:m] modPow:[exponent negate] modulo:m];
    if ([exponent isOne])
        return [self mod:m];

    // To do this naively by first raising this to the power of exponent
    // and then performing modulo m would be extremely expensive, especially
    // for very large numbers.  The solution is found in Number Theory
    // where a combination of partial powers and moduli can be done easily.
    //
    // We'll use the algorithm for Additive Chaining which can be found on
    // p. 244 of "Applied Cryptography, Second Edition" by Bruce Schneier.
    BigInteger *s = [BigInteger valueOf:1];
    BigInteger *t = self;
    BigInteger *u = exponent;
    int runcounter = 0;
    while (![u isZero]) {
        runcounter++;
//        NSLog(@"\n\n Round: %d", runcounter);
        if ([[u and:[BigInteger valueOf:1]] isOne]) {
            BigInteger *tmp = [BigInteger times:s yBig:t];
            s = [tmp mod:m];
//            NSLog(@"%@ mod %@ = %@", tmp, m, s);
        }
        u = [u shiftRight:1];
//        NSLog(@"U: %@",u);

        BigInteger *res = [BigInteger times:t yBig:t];
//        NSLog(@"%@ times %@ = %@ ", t, t, res);
        BigInteger *res2 = [res mod:m];
//        NSLog(@"%@ mod %@  = %@", res, m, res2);
//        if ([res2 isZero]) {
//            NSLog(@"WAAA???");
//        }
        t = res2;
    }

    return s;
}

+ (BigInteger *)abs:(BigInteger *)x {
    return [x isNegative] ? [BigInteger neg:x] : x;
}

- (BigInteger *)abs {
    return [BigInteger abs:self];
}

/** Calculate Greatest Common Divisor for non-negative ints. */
+ (int64_t)gcdInt:(int64_t)a b:(int64_t)b {
    // Euclid's algorithm, copied from libg++.
    int64_t tmp;
    if (b > a) {
        tmp = a;
        a = b;
        b = tmp;
    }
    for (; ;) {
        if (b == 0)
            return a;
        if (b == 1)
            return b;
        tmp = b;
        b = a % b;
        a = tmp;
    }
    return 0;
}

- (BigInteger *)gcd:(BigInteger *)y {
    int64_t xval = self.iVal;
    int64_t yval = y.iVal;
    if (self.isSimple) {
        if (xval == 0)
            return [BigInteger abs:y];
        if (y.isSimple
                && xval != INT_MIN && yval != INT_MIN) {
            if (xval < 0)
                xval = -xval;
            if (yval < 0)
                yval = -yval;
            return [BigInteger valueOf:[BigInteger gcdInt:xval b:yval]];
        }
        xval = 1;
    }
    if (y.isSimple) {
        if (yval == 0)
            return [BigInteger abs:self];
        yval = 1;
    }
    int64_t len = (xval > yval ? xval : yval) + 1;
    int64_t *xwords = [BigInteger allocData:(int) len];
    int64_t *ywords = [BigInteger allocData:(int) len];
    [self getAbsolute:xwords length:(int) len];
    [y getAbsolute:ywords length:(int) len];
    len = [MPN gcd:xwords y:ywords len:(int) len];
    BigInteger *result = [[BigInteger alloc] initWith:0];
    result.iVal = len;
    result.data = xwords;
    return [result canonicalize];
}


/* Assumes x and y are both canonicalized. */
+ (BOOL)equals:(BigInteger *)x y:(BigInteger *)y {
    if (x.isSimple && y.isSimple)
        return x.iVal == y.iVal;
    if ((x.isSimple || y.isSimple) && x.iVal != y.iVal)
        return NO;
    if (x.isSimple && !y.isSimple) {
        if (y.iVal==1 && y.data[0]==x.iVal) {
            return YES;
        }
        return NO;
    }
    if (!x.isSimple && y.isSimple) {
        if (x.iVal==1 && x.data[0]==y.iVal) {
            return YES;
        }
        return NO;
    }

    int end= (int) x.iVal;
    if (x.iVal != y.iVal) {
        //check high-bytes==0
        int start=0;
        int64_t *data=nil;
        if (x.iVal>y.iVal) {
            start= (int) x.iVal;
            end= (int) y.iVal;
            data=x.data;
        } else {
            start= (int) y.iVal;
            end= (int) x.iVal;
            data=y.data;
        }
        for (int i=start;--i>=end;) {
            if (data[i]&0xffffffff!=0) {
                return NO;
            }
        }
    }

    for (int i = end; --i >= 0;) {
        if (((int32_t) x.data[i]&0xffffffff) != ((int32_t) y.data[i]&0xffffffff))
            return NO;
    }
    return YES;
}

/* Assumes this and obj are both canonicalized. */
- (BOOL)isEqualTo:(id)object {
    if (object == self) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [BigInteger equals:self y:(BigInteger *) object];
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualTo:other];
}


+ (int64_t)nexRand {
    return arc4random();
//    return rand();
}

- (id)initWithRandomBits:(int)numBits {
    self = [super init];
    if (self) {
        uint64_t highbits = (uint64_t) (numBits & 31);
        // minimum number of bytes to store the above number of bits
        int64_t highBitByteCount = (highbits + 7) / 8;
        // number of bits to discard from the last byte
        int64_t discardedBitCount = highbits % 8;
        if (discardedBitCount != 0)
            discardedBitCount = 8 - discardedBitCount;
        unsigned char *highBitBytes = nil;
        if (highBitByteCount > 0) {
            highBitBytes = malloc((size_t) highBitByteCount);
            if (highBitBytes == nil) {
                @throw [NSException exceptionWithName:@"Error" reason:@"Could not allocate mem" userInfo:nil];
            }
        }
        if (highbits > 0) {
            for (int64_t i = 0; i < highBitByteCount; i++) {
                highBitBytes[i] = (unsigned char) ([BigInteger nexRand]) & 0xFF;
            }
            highbits = (((unsigned char) highBitBytes[(NSUInteger) (highBitByteCount - 1)]) & 0xFF) >> discardedBitCount;
            for (int64_t i = highBitByteCount - 2; i >= 0; i--)
                highbits = (((unsigned char) highbits) << 8) | (((unsigned char) highBitBytes[i]) & 0xFF);
        }
        int64_t nwords = numBits / 32;

        while (highbits == 0 && nwords > 0) {
            highbits = (uint64_t) [BigInteger nexRand];
            --nwords;
        }
        if (nwords == 0 && highbits >= 0) {
            self.iVal = highbits;
            self.data = nil;
        } else {
            self.iVal = highbits < 0 ? nwords + 2 : nwords + 1;
            self.data = [BigInteger allocData:(int) self.iVal];
            self.data[nwords] = highbits;
            while (--nwords >= 0) {
                self.data[nwords] = [BigInteger nexRand];
            }
        }
        if ([self isNegative]) {
            if ([self isSimple]) {
                self.iVal = -self.iVal;
            } else {
                //Workaround - somehow negative randoms keep being created
                self.data[self.iVal - 1] = -self.data[self.iVal - 1];
            }
        }
        if (highBitByteCount > 0)
            free(highBitBytes);
    }

    return self;
}


- (id)init {
    self = [super init];
    if (self) {
        _data = nil;
        _iVal = 0;
    }

    return self;
}

+ (BigInteger *)valueOf:(int64_t)val {

//    if (val >= MINFIXNUMS && val < MAXFIXNUMS)
//        return fixNum[(NSUInteger) ((int64_t) val - MINFIXNUMS)];
    int64_t i = (int32_t) val;
    if ((int32_t) i == val)
        return [[BigInteger alloc] initWith:i];

    BigInteger *result = [[BigInteger alloc] init];
    result.iVal = 2;
    result.data = [BigInteger allocData:2];
    result.data[0] = (int32_t) i;
    result.data[1] = (int64_t) (val >> 32);
    return result;
}


+ (BigInteger *)valueOf:(NSString *)s usingRadix:(int)radix {
    int len = s.length;
    // Testing (len < MPN.chars_per_word(radix)) would be more accurate,
    // but slightly more expensive, for little practical gain.
//    if (len <= 7 && (radix == 16 || radix == 10)) {
//        NSScanner *scanner = [[NSScanner alloc] initWithString:s];
//        uint64_t i;
//        if (radix == 16) {
//            [scanner scanHexInt:&i];
//        } else {
//            [scanner scanInt:&i];
//        }
//        return [BigInteger valueOf:i];
//    }

    int64_t i, digit;
    BOOL negative;
    int64_t *bytes = [BigInteger allocData:len];
    char ch = (char) [s characterAtIndex:0];
    if (ch == '-') {
        negative = YES;
        i = 1;
        for (int64_t i = 0; i < len - 1; i++)
            bytes[i] = 0;
    } else {
        negative = NO;
        i = 0;
        for (int64_t i = 0; i < len; i++)
            bytes[i] = 0;
    }
    int byte_len = 0;
    for (; i < len; i++) {
        ch = (char) [s characterAtIndex:i];
        digit = [BigInteger digit:ch radix:radix];
        if (digit < 0) {
            @throw [NSException exceptionWithName:@"NSException" reason:@"Number Format error" userInfo:nil];
        }
        bytes[byte_len++] = digit;
    }

    return [BigInteger valueOfArr:bytes len:byte_len negative:negative radix:radix];

}

+ (BigInteger *)valueOfArr:(int64_t *)arr len:(int)byte_len negative:(BOOL)negative radix:(int)radix {
    int chars_per_word = [MPN chars_per_word:radix];
    int64_t *words = [BigInteger allocData:byte_len / chars_per_word + 1];

    int64_t size = [MPN set_str:words str:arr strLen:byte_len base:radix];
    if (size == 0)
        return [[BigInteger alloc] initWith:0];
    if (((int32_t) words[size - 1]) < 0)
        words[size++] = 0;
    if (negative)
        [BigInteger negate:words src:words len:size];
    return [BigInteger make:words len:size];
}

+ (BigInteger *)make:(int64_t *)words len:(int64_t)len {
    if (words == nil)
        return [BigInteger valueOf:(long) len];
    len = [BigInteger wordsNeeded:words len:(int) len];
    if (len <= 1)
        return len == 0 ? [BigInteger valueOf:0] : [BigInteger valueOf:words[0]];
    BigInteger *num = [[BigInteger alloc] init];
    num.data = words;
    num.iVal = len;
    return num;
}

/** Calculate how many words are significant in words[0:len-1].
    * Returns the least value x such that x>0 && words[0:x-1]==words[0:len-1],
    * when words is viewed as a 2's complement integer.
    */
+ (int64_t)wordsNeeded:(int64_t *)words len:(int)len {
    int i = len;
    if (i > 0) {
        int64_t word = words[--i];
        if (word == -1) {
            while (i > 0 && (word = words[i - 1]) < 0) {
                i--;
                if (word != -1) break;
            }
        }
        else {
            while (word == 0 && i > 0 && (word = ((int32_t) words[i - 1])) >= 0) i--;
        }
    }
    return i + 1;
}


+ (BOOL)negate:(int64_t *)dest src:(int64_t *)src len:(int64_t)len {
    uint64_t carry = 1;
    BOOL negative = (int32_t) src[len - 1] < 0;
    for (int i = 0; i < len; i++) {
        carry += ((int64_t) (~src[i]) & 0xffffffffL);
        dest[i] = (int32_t) carry;
        carry >>= 32;
    }
    return (negative && (int32_t) dest[len - 1] < 0);
}


+ (int64_t)digit:(char)ch radix:(int64_t)radix {
    if (radix < 2 || radix > 48)
        return -1;
    switch (ch) {
        case '0':
            return 0;
        case '1':
            return 1;
        case '2':
            return 2;
        case '3':
            return 3;
        case '4':
            return 4;
        case '5':
            return 5;
        case '6':
            return 6;
        case '7':
            return 7;
        case '8':
            return 8;
        case '9':
            return 9;
        case 'a':
        case 'A':
            return 10;
        case 'b':
        case 'B':
            return 11;
        case 'c':
        case 'C':
            return 12;
        case 'd':
        case 'D':
            return 13;
        case 'e':
        case 'E':
            return 14;
        case 'f':
        case 'F':
            return 15;
        case 'g':
        case 'G':
            return 16;
        case 'h':
        case 'H':
            return 17;
        case 'i':
        case 'I':
            return 18;
        case 'j':
        case 'J':
            return 19;
        case 'k':
        case 'K':
            return 20;
        case 'l':
        case 'L':
            return 21;
        case 'm':
        case 'M':
            return 22;
        case 'n':
        case 'N':
            return 23;
        case 'o':
        case 'O':
            return 24;
        case 'p':
        case 'P':
            return 25;
        case 'q':
        case 'Q':
            return 26;
        case 'r':
        case 'R':
            return 27;
        case 's':
        case 'S':
            return 28;
        case 't':
        case 'T':
            return 29;
        case 'u':
        case 'U':
            return 30;
        case 'v':
        case 'V':
            return 31;
        case 'w':
        case 'W':
            return 32;
        case 'x':
        case 'X':
            return 33;
        case 'y':
        case 'Y':
            return 34;
        case 'z':
        case 'Z':
            return 35;
        case '#':
            return 36;
        case '+':
            return 37;
        case '-':
            return 38;
        case '?':
            return 39;
        case '!':
            return 40;
        case '$':
            return 41;
        case '%':
            return 42;
        case '&':
            return 43;
        case '/':
            return 44;
        case '(':
            return 45;
        case ')':
            return 46;
        case '=':
            return 47;

        default:
            return -1;


    }
}

+ (int)swappedOp:(int)op {
    return [@"\000\001\004\005\002\003\006\007\010\011\014\015\012\013\016\017" characterAtIndex:(NSUInteger) op];
}

- (BigInteger *)canonicalize {
    if (self.data != nil && (self.iVal = [BigInteger wordsNeeded:self.data len:(int) self.iVal]) <= 1) {
        if (self.iVal == 1)
            self.iVal = self.data[0];
        self.data = nil;
    }
//    if (self.isSimple && self.iVal >= MINFIXNUMS && self.iVal < MAXFIXNUMS)
//        return fixNum[self.iVal - MINFIXNUMS];
    return self;
}

/** Change words.length to nwords.
 * We allow words.length to be upto nwords+2 without reallocating.
 */
- (void)realloc:(int)nwords {
    if (nwords == 0) {
        if (self.data != nil) {
            if (self.iVal > 0)
                self.iVal = self.data[0];
            self.data = nil;
        }
    }
    else if (self.isSimple) {
        int64_t *new_words = [BigInteger allocData:nwords];
        if (self.isSimple) {
            new_words[0] = self.iVal;
            self.iVal = 1;
        } else {
            if (nwords < self.iVal)
                self.iVal = nwords;
            //System.arraycopy(words, 0, new_words, 0, ival);
            memcpy(new_words, self.data, (size_t) self.iVal * sizeof(int64_t));

        }
        //free(self.data);
        self.data = new_words;
    }
}


/**
* Bitwise Operations
*/
/** Do one the the 16 possible bit-wise operations of two BigIntegers. */
+ (BigInteger *)bitOp:(int)op x:(BigInteger *)x y:(BigInteger *)y {
    switch (op) {
        case 0:
            return [BigInteger valueOf:0];
        case 1:
            return [x and:y];
        case 3:
            return x;
        case 5:
            return y;
        case 15:
            return [[BigInteger alloc] initWith:-1];

    }
    BigInteger *result = [[BigInteger alloc] init];
    [BigInteger setBitOp:result op:(int64_t) op x:(BigInteger *) x y:(BigInteger *) y];
    return [result canonicalize];
}

/** Do one the the 16 possible bit-wise operations of two BigIntegers. */
+ (void)setBitOp:(BigInteger *)result op:(int)op x:(BigInteger *)x y:(BigInteger *)y {
    if ((y.data != nil) && (x.isSimple || x.iVal < y.iVal)) {
        BigInteger *temp = x;
        x = y;
        y = temp;
        op = (int) [BigInteger swappedOp:op];
    }
    int64_t xi;
    int64_t yi;
    int64_t xlen, ylen;
    if (y.isSimple) {
        yi = y.iVal;
        ylen = 1;
    }
    else {
        yi = y.data[0];
        ylen = y.iVal;
    }
    if (x.isSimple) {
        xi = x.iVal;
        xlen = 1;
    }
    else {
        xi = x.data[0];
        xlen = x.iVal;
    }
    if (xlen > 1)
        [result realloc:(int) xlen];
    int64_t *w = result.data;
    int64_t i = 0;
    // Code for how to handle the remainder of x.
    // 0:  Truncate to length of y.
    // 1:  Copy rest of x.
    // 2:  Invert rest of x.
    int64_t finish = 0;
    int64_t ni;
    switch (op) {
        case 0:  // clr
            ni = 0;
            break;
        case 1: // and
            for (; ;) {
                ni = xi & yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi < 0) finish = 1;
            break;
        case 2: // andc2
            for (; ;) {
                ni = xi & ~yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi >= 0) finish = 1;
            break;
        case 3:  // copy x
            ni = xi;
            finish = 1;  // Copy rest
            break;
        case 4: // andc1
            for (; ;) {
                ni = ~xi & yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi < 0) finish = 2;
            break;
        case 5: // copy y
            for (; ;) {
                ni = yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            break;
        case 6:  // xor
            for (; ;) {
                ni = xi ^ yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            finish = yi < 0 ? 2 : 1;
            break;
        case 7:  // ior
            for (; ;) {
                ni = xi | yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi >= 0) finish = 1;
            break;
        case 8:  // nor
            for (; ;) {
                ni = ~(xi | yi);
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi >= 0) finish = 2;
            break;
        case 9:  // eqv [exclusive nor]
            for (; ;) {
                ni = ~(xi ^ yi);
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            finish = yi >= 0 ? 2 : 1;
            break;
        case 10:  // c2
            for (; ;) {
                ni = ~yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            break;
        case 11:  // orc2
            for (; ;) {
                ni = xi | ~yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi < 0) finish = 1;
            break;
        case 12:  // c1
            ni = ~xi;
            finish = 2;
            break;
        case 13:  // orc1
            for (; ;) {
                ni = ~xi | yi;
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi >= 0) finish = 2;
            break;
        case 14:  // nand
            for (; ;) {
                ni = ~(xi & yi);
                if (i + 1 >= ylen) break;
                w[i++] = ni;
                xi = x.data[i];
                yi = y.data[i];
            }
            if (yi < 0) finish = 2;
            break;
        default:
        case 15:  // set
            ni = -1;
            break;
    }
    // Here i==ylen-1; w[0]..w[i-1] have the correct result;
    // and ni contains the correct result for w[i+1].
    if (i + 1 == xlen)
        finish = 0;
    switch (finish) {
        case 0:
            if (i == 0 && w == nil) {
                result.iVal = ni;
                return;
            }
            w[i++] = ni;
            break;
        case 1:
            w[i] = ni;
            while (++i < xlen) w[i] = x.data[i];
            break;
        case 2:
            w[i] = ni;
            while (++i < xlen) w[i] = ~x.data[i];
            break;
    }
    result.iVal = i;
}

- (BOOL)isNegative {
    return ((self.isSimple) ? self.iVal : self.data[self.iVal - 1]) < 0;
}

/** Return the logical (bit-wise) "and" of a BigInteger and an int64_t. */
+ (BigInteger *)and:(BigInteger *)x y:(int64_t)y {
    if (x.isSimple)
        return [BigInteger valueOf:x.iVal & y];
    if (y >= 0) {
        if (x.iVal == 0) {
            return [BigInteger valueOf:0];
        }
        return [BigInteger valueOf:x.data[0] & y];
    }
    int64_t len = x.iVal;
    int64_t *words = [BigInteger allocData:len];
    words[0] = x.data[0] & y;
    while (--len > 0)
        words[len] = x.data[len];
    return [BigInteger make:words len:x.iVal];
}

/** Return the logical (bit-wise) "and" of two BigIntegers. */
- (BigInteger *)and:(BigInteger *)y {
    if (y.isSimple)
        return [BigInteger and:self y:y.iVal];
    else if (self.isSimple)
        return [BigInteger and:y y:self.iVal];

    BigInteger *x = self;
    if (self.iVal < y.iVal) {
        BigInteger *temp = self;
        x = y;
        y = temp;
    }
    int64_t i;
    int64_t len = [y isNegative] ? x.iVal : y.iVal;

    int64_t *words = [BigInteger allocData:(int) y.iVal];
    for (i = 0; i < y.iVal; i++)
        words[i] = x.data[i] & y.data[i];
    for (; i < len; i++)
        words[i] = x.data[i];
    return [BigInteger make:words len:len];
}

/** Return the logical (bit-wise) "(inclusive) or" of two BigIntegers. */
- (BigInteger *)or:(BigInteger *)y {
    return [BigInteger bitOp:7 x:self y:y];
}

/** Return the logical (bit-wise) "exclusive or" of two BigIntegers. */
- (BigInteger *)xor:(BigInteger *)y {
    return [BigInteger bitOp:6 x:self y:y];
}

/** Return the logical (bit-wise) negation of a BigInteger. */
- (BigInteger *)not {
    return [BigInteger bitOp:12 x:self y:[BigInteger valueOf:0]];
}

- (BigInteger *)andNot:(BigInteger *)val {
    return [self and:[val not]];
}

- (BigInteger *)clearBit:(int64_t)n {
    if (n < 0) {
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"negative bit number?" userInfo:nil];
    }
    return [self and:[[[BigInteger valueOf:1] shiftLeft:n] not]];
}

- (BigInteger *)setBit:(int64_t)n {
    if (n < 0)
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"negative bit number" userInfo:nil];
    return [self or:[[BigInteger valueOf:1] shiftLeft:n]];
}

- (BOOL)testBit:(int64_t)n {
    if (n < 0)
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"negative bit number" userInfo:nil];
    return ![[self and:[[BigInteger valueOf:1] shiftLeft:n]] isZero];
}


- (BigInteger *)flipBit:(int64_t)n {
    if (n < 0)
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"negative bit number" userInfo:nil];
    return [self xor:[[BigInteger valueOf:1] shiftLeft:n]];
}


- (void)setShift:(BigInteger *)x count:(int64_t)count {
    if (count > 0)
        [self setShiftLeft:x count:count];
    else
        [self setShiftRight:x count:(int) -count];
}

+ (BigInteger *)shift:(BigInteger *)x count:(int64_t)count {
    if (x.isSimple) {
        if (count <= 0)
            return [BigInteger valueOf:(count > -32 ? x.iVal >> (-count) : x.iVal < 0 ? -1 : 0)];
        if (count < 32)
            return [BigInteger valueOf:((int64_t) x.iVal << count)];
    }
    if (count == 0)
        return x;
    BigInteger *result = [[BigInteger alloc] init];
    [result setShift:x count:count];
    return [result canonicalize];
}

- (BigInteger *)shiftLeft:(int64_t)n {
    return [BigInteger shift:self count:n];
}

- (BigInteger *)shiftRight:(int64_t)n {
    return [BigInteger shift:self count:-n];
}

- (void)set:(int64_t)y {
    int32_t i = (int32_t) y;
    if ((int64_t) i == y) {
        self.iVal = i;
        self.data = nil;
    }
    else {
        [self realloc:2];
        self.data[0] = (int32_t) i;
        self.data[1] = (int64_t) (y >> 32);
        self.iVal = 2;
    }
}

- (void)setShiftLeft:(BigInteger *)x count:(int)count {
    int64_t *xwords;
    int64_t xlen;
    if (x.isSimple) {
        if (count < 32) {
            [self set:((long) x.iVal << count)];
            return;
        }
        xwords = [BigInteger allocData:1];
        xwords[0] = x.iVal;
        xlen = 1;
    }
    else {
        xwords = x.data;
        xlen = x.iVal;
    }
    int word_count = count >> 5;
    count &= 31;
    int new_len = (int) (xlen + word_count);
    if (count == 0) {
        [self realloc:(int) new_len];
        for (int64_t i = xlen; --i >= 0;) {
            self.data[i + word_count] = xwords[i];

        }
    }
    else {
        new_len++;
        [self realloc:(int) new_len];
        int32_t shift_out = (int32_t) [MPN lshift:self.data d_offset:word_count x:xwords len:xlen count:count];
        count = 32 - count;
        self.data[new_len - 1] = (shift_out << count) >> count;  // sign-extend.
    }
    self.iVal = new_len;
    for (int i = word_count; --i >= 0;)
        self.data[i] = 0;
}

- (void)setShiftRight:(BigInteger *)x count:(int)count {
    if (x.isSimple)
        [self set:count < 32 ? x.iVal >> count : x.iVal < 0 ? -1 : 0];
    else if (count == 0) {
        self.data = x.data;
        self.iVal = x.iVal;
    } else {
        BOOL neg = [x isNegative];
        int word_count = count >> 5;
        count &= 31;
        int d_len = (int) (x.iVal - word_count);
        if (d_len <= 0)
            [self set:neg ? -1 : 0];
        else {
            if (self.isSimple || self.iVal < d_len)
                [self realloc:d_len];
            [MPN rshift0:self.data x:x.data x_start:(int) word_count len:(int) d_len count:count];
            self.iVal = d_len;
            if (neg) {
                int64_t o = self.data[d_len - 1];
                o |= -2 << (31 - count);
                self.data[d_len - 1] = o;

            }
        }
    }
}


- (int64_t)getLowestSetBit {
    if ([self isZero])
        return -1;

    if (self.isSimple)
        return [MPN findLowestBit:self.iVal];
    else
        return [MPN findLowestBitInArr:self.data];
}

- (BOOL)isZero {
    return (self.isSimple) && self.iVal == 0;
}

- (BOOL)isOne {
    return (self.isSimple) && self.iVal == 1;
}


+ (BigInteger *)randomProbablePrime:(int)bitLength primeProbability:(int)certainty useThreads:(int)threads {
    if (bitLength < 2)
        @throw [NSException exceptionWithName:@"Arithmeticexception" reason:@"bit length too short for prime" userInfo:nil];

    if (threads < 1) threads = 1;
    if (threads > 50) threads = 50;

    __block BigInteger *result = nil;
    __block BOOL running = YES;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_block_t block = (dispatch_block_t) ^{
        BigInteger *s = [BigInteger randomBigInt:bitLength];
        if ([s isNegative]) {
            s = [s negate];

        }
        BigInteger *r = nil;
        while (running) {
            r = [s setBit:bitLength - 1];
            s = [BigInteger bigIntegerWithBigInteger:r];

            if ([s isProbablePrime:certainty]) {
//                NSLog(@"found %@", s);

                running = NO;
                result = s;
                break;
            }
//            NSLog(@"new test");
            s = [BigInteger randomBigInt:bitLength];
        }
        dispatch_semaphore_signal(semaphore);

    };
    for (int64_t i = 0; i < threads; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), block);
    }

//    NSLog(@"Waiting...");
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//    NSLog(@"Returning");
    return result;
}

- (NSString *)description {
    return [self getHex];
}

- (NSString *)getHex {
    NSString *c[] = {@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F"};
    if ([self isZero]) {
        return c[0];
    }
    NSMutableString *ret = [[NSMutableString alloc] init];
    int64_t *arc = self.data;
    int64_t arcCnt = self.iVal;
    BOOL toFree = NO;
    if ([self isNegative]) {
        [ret appendString:@"-"];
        arc = [self negate].data;
    }
    if (arc == nil) {
        arc = [BigInteger allocData:1];
        if ([self isNegative]) {
            arc[0] = -self.iVal;
        } else {
            arc[0] = self.iVal;
        }
        toFree = YES;
        arcCnt = 1;
    }
    BOOL skip = YES;
    for (long i = arcCnt - 1; i >= 0; i--) {
//    for (long i = 0; i<[arc count]; i++) {
        int64_t value = arc[i];
        int64_t idx;
//        idx=value>>60&0x0000000f;
//        [ret appendString:c[idx]];
//        idx=value>>56&0x0000000f;
//        [ret appendString:c[idx]];
//
//        idx=value>>52&0x0000000f;
//        [ret appendString:c[idx]];
//        idx=value>>48&0x0000000f;
//        [ret appendString:c[idx]];
//
//        idx=value>>44&0x0000000f;
//        [ret appendString:c[idx]];
//        idx=value>>40&0x0000000f;
//        [ret appendString:c[idx]];
//
//        idx=value>>36&0x0000000f;
//        [ret appendString:c[idx]];
//        idx=value>>32&0x0000000f;
//        [ret appendString:c[idx]];

        idx = value >> 28 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value >> 24 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value >> 20 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value >> 16 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value >> 12 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value >> 8 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value >> 4 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = value & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

    }
    if (toFree) {
        //free(arc);
    }
    return ret;
}

@end
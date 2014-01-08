//
// Created by Stephan Bösebeck on 08.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import "SHA5.h"

@interface SHA5 ()
@property int64_t *W;
@property int64_t count;
@property int64_t AA;
@property int64_t BB;
@property int64_t CC;
@property int64_t DD;
@property int64_t EE;
@property int64_t FF;
@property int64_t GG;
@property int64_t HH;
@end

@implementation SHA5


static const int LENGTH = 64;
static const int64_t INITIAL_HASHES[] = {
        0x6a09e667f3bcc908L, 0xbb67ae8584caa73bL,
        0x3c6ef372fe94f82bL, 0xa54ff53a5f1d36f1L,
        0x510e527fade682d1L, 0x9b05688c2b3e6c1fL,
        0x1f83d9abfb41bd6bL, 0x5be0cd19137e2179L
};
static const int ITERATION = 80;
// Constants for each round/iteration
static const int64_t ROUND_CONSTS[] = {
        0x428A2F98D728AE22L, 0x7137449123EF65CDL, 0xB5C0FBCFEC4D3B2FL,
        0xE9B5DBA58189DBBCL, 0x3956C25BF348B538L, 0x59F111F1B605D019L,
        0x923F82A4AF194F9BL, 0xAB1C5ED5DA6D8118L, 0xD807AA98A3030242L,
        0x12835B0145706FBEL, 0x243185BE4EE4B28CL, 0x550C7DC3D5FFB4E2L,
        0x72BE5D74F27B896FL, 0x80DEB1FE3B1696B1L, 0x9BDC06A725C71235L,
        0xC19BF174CF692694L, 0xE49B69C19EF14AD2L, 0xEFBE4786384F25E3L,
        0x0FC19DC68B8CD5B5L, 0x240CA1CC77AC9C65L, 0x2DE92C6F592B0275L,
        0x4A7484AA6EA6E483L, 0x5CB0A9DCBD41FBD4L, 0x76F988DA831153B5L,
        0x983E5152EE66DFABL, 0xA831C66D2DB43210L, 0xB00327C898FB213FL,
        0xBF597FC7BEEF0EE4L, 0xC6E00BF33DA88FC2L, 0xD5A79147930AA725L,
        0x06CA6351E003826FL, 0x142929670A0E6E70L, 0x27B70A8546D22FFCL,
        0x2E1B21385C26C926L, 0x4D2C6DFC5AC42AEDL, 0x53380D139D95B3DFL,
        0x650A73548BAF63DEL, 0x766A0ABB3C77B2A8L, 0x81C2C92E47EDAEE6L,
        0x92722C851482353BL, 0xA2BFE8A14CF10364L, 0xA81A664BBC423001L,
        0xC24B8B70D0F89791L, 0xC76C51A30654BE30L, 0xD192E819D6EF5218L,
        0xD69906245565A910L, 0xF40E35855771202AL, 0x106AA07032BBD1B8L,
        0x19A4C116B8D2D0C8L, 0x1E376C085141AB53L, 0x2748774CDF8EEB99L,
        0x34B0BCB5E19B48A8L, 0x391C0CB3C5C95A63L, 0x4ED8AA4AE3418ACBL,
        0x5B9CCA4F7763E373L, 0x682E6FF3D6B2B8A3L, 0x748F82EE5DEFB2FCL,
        0x78A5636F43172F60L, 0x84C87814A1F0AB72L, 0x8CC702081A6439ECL,
        0x90BEFFFA23631E28L, 0xA4506CEBDE82BDE9L, 0xBEF9A3F7B2C67915L,
        0xC67178F2E372532BL, 0xCA273ECEEA26619CL, 0xD186B8C721C0C207L,
        0xEADA7DD6CDE0EB1EL, 0xF57D4F7FEE6ED178L, 0x06F067AA72176FBAL,
        0x0A637DC5A2C898A6L, 0x113F9804BEF90DAEL, 0x1B710B35131C471BL,
        0x28DB77F523047D84L, 0x32CAAB7B40C72493L, 0x3C9EBE0A15C9BEBCL,
        0x431D67C49C100D4CL, 0x4CC5D4BECB3E42B6L, 0x597F299CFC657E2AL,
        0x5FCB6FAB3AD6FAECL, 0x6C44198C4A475817L
};

const int64_t COUNT_MASK = 127; // block size - 1



/**
 * logical function ch(x,y,z) as defined in spec:
 *
 * @param x int64_t
 * @param y int64_t
 * @param z int64_t
 * @return (x and y) xor ((complement x) and z)
 */
+ (int64_t)lf_ch_x:(int64_t)x y:(int64_t)y z:(int64_t)z {
    return (x & y) ^ ((~x) & z);
}

/**
 * logical function maj(x,y,z) as defined in spec:
 *
 * @param x int64_t
 * @param y int64_t
 * @param z int64_t
 * @return (x and y) xor (x and z) xor (y and z)
 */
+ (int64_t)lf_maj_x:(int64_t)x y:(int64_t)y z:(int64_t)z {
    return (x & y) ^ (x & z) ^ (y & z);
}

/**
 * logical function R(x,s) - right shift
 *
 * @param x int64_t
 * @param s int
 * @return x right shift for s times
 */
+ (int64_t)lf_R_x:(int64_t)x s:(int)s {
    return (((uint64_t) x) >> s) & 0x7FFFFFFFFFFFFFFF;
}

/**
 * logical function S(x,s) - right rotation
 *
 * @param x int64_t
 * @param s int
 * @return x circular right shift for s times
 */
+ (int64_t)lfS_x:(int64_t)x s:(int)s {
    return ((((uint64_t) x) >> s) & 0x7FFFFFFFFFFFFFFF) | (((uint64_t) x) << (64 - s));
}

/**
 * logical function sigma0(x) - xor of results of right rotations
 *
 * @param x int64_t
 * @return S(x, 28) xor S(x,34) xor S(x,39)
 */
+ (int64_t)lf_sigma0:(int64_t)x {
    return [SHA5 lfS_x:x s:28] ^ [SHA5 lfS_x:x s:34] ^ [SHA5 lfS_x:x s:39];
}

/**
 * logical function sigma1(x) - xor of results of right rotations
 *
 * @param x int64_t
 * @return S(x, 14) xor S(x,18) xor S(x,41)
 */
+ (int64_t)lf_sigma1:(int64_t)x {
    return [SHA5 lfS_x:x s:14] ^ [SHA5 lfS_x:x s:18] ^ [SHA5 lfS_x:x s:41];
}

/**
 * logical function delta0(x) - xor of results of right shifts/rotations
 *
 * @param x int64_t
 * @return int64_t
 */
+ (int64_t)lf_delta0:(int64_t)x {
    return [SHA5 lfS_x:x s:1] ^ [SHA5 lfS_x:x s:8] ^ [SHA5 lf_R_x:x s:7];
}

/**
 * logical function delta1(x) - xor of results of right shifts/rotations
 *
 * @param x int64_t
 * @return int64_t
 */
+ (int64_t)lf_delta1:(int64_t)x {
    int64_t d1 = [SHA5 lfS_x:x s:19];
    return d1 ^ [SHA5 lfS_x:x s:61] ^ [SHA5 lf_R_x:x s:6];
}


/**
 * @return the length of the digest in bytes
 */
- (int)engineGetDigestLength {
    return (LENGTH);
}

/**
 * Update a byte.
 *
 * @param b the byte
 */
- (void)engineUpdate:(char)b {
    [self update:(int) b];
}

- (void)update:(int)b {
    int word;  // index inside this block, i.e. from 0 to 15.
    int offset; //offset of this byte inside the word

    /* compute word index within the block and bit offset within the word.
       block size is 128 bytes with word size is 8 bytes. offset is in
       terms of bits */
    word = (int) (((unsigned int) (self.count & COUNT_MASK)) >> 3) & 0x7FFFFFFF;
    offset = (int) (~self.count & 7) << 3;

    // clear the byte inside W[word] and then 'or' it with b's byte value
    self.W[word] = (self.W[word] & ~(0xffL << offset)) | ((b & 0xffL) << offset);
    self.count++;

    /* If this is the last byte of a block, compute the partial hash */
    if ((self.count & COUNT_MASK) == 0) {
        [self computeBlock];
    }
}

- (int64_t *)W {
    if (!_W) {
        _W = malloc(sizeof(int64_t) * ITERATION);
        for (int i = 0; i < ITERATION; i++) {
            _W[i] = 0;
        }
    }
    return _W;
}

/**
 * Update a buffer.
 *
 * @param b   the data to be updated.
 * @param off the start offset in the data
 * @param len the number of bytes to be updated.
 */

- (void)engineUpdate:(char *)b off:(int)off len:(int)len {
    int word;
    int offset;

    // Use single writes until integer aligned
    while ((len > 0) &&
            (self.count & 7) != 0) {
        [self engineUpdate:b[off]];
        off++;
        len--;
    }

    /* Assemble groups of 8 bytes to be inserted in int64_t array */
    while (len >= 8) {

        word = (int) (self.count & COUNT_MASK) >> 3;
        self.W[word] = ((b[off] & 0xffL) << 56) |
                ((b[off + 1] & 0xffL) << 48) |
                ((b[off + 2] & 0xffL) << 40) |
                ((b[off + 3] & 0xffL) << 32) |
                ((b[off + 4] & 0xffL) << 24) |
                ((b[off + 5] & 0xffL) << 16) |
                ((b[off + 6] & 0xffL) << 8) |
                ((b[off + 7] & 0xffL));
        self.count += 8;
        if ((self.count & COUNT_MASK) == 0) {
            [self computeBlock];
        }
        len -= 8;
        off += 8;
    }

    /* Use single writes for last few bytes */
    while (len > 0) {
        [self engineUpdate:b[off++]];
        len--;
    }
}

/**
 * Resets the buffers and hash value to start a new hash.
 */
- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setInitialHash:INITIAL_HASHES];
    for (int i = 0; i < ITERATION; i++)
        self.W[i] = 0;
    self.count = 0;
}

- (void)setInitialHash:(int64_t *)values {
    self.AA = values[0];
    self.BB = values[1];
    self.CC = values[2];
    self.DD = values[3];
    self.EE = values[4];
    self.FF = values[5];
    self.GG = values[6];
    self.HH = values[7];
}

- (void)dealloc {
    free(_W);
}


/**
 * Resets the buffers and hash value to start a new hash.
 */
- (void)engineReset {
    [self setup];
}

/**
 * Computes the const hash and returns the const value as a
 * byte array. The object is reset to be ready for further
 * use, as specified in java.security.MessageDigest javadoc
 * specification.
 */
- (char *)engineDigest {
    char *hashvalue = malloc(LENGTH);
    for (int i = 0; i < LENGTH; i++) {
        hashvalue[i] = 0;
    }
    int outLen = [self engineDigest:hashvalue off:0 len:LENGTH];

    return hashvalue;
}

/**
 * Computes the const hash and places the const value in the
 * specified array. The object is reset to be ready for further
 * use, as specified in java.security.MessageDigest javadoc
 * specification.
 *
 * @param hashvalue buffer to hold the digest
 * @param offset    offset for storing the digest
 * @param len       length of the buffer
 * @return length of the digest in bytes
 */
- (int)engineDigest:(char *)hashvalue off:(int)offset len:(int)len {

    if (len < LENGTH) {
        @throw [NSException exceptionWithName:@"IllegalArgumentException" reason:@"Wrong length" userInfo:nil];
    }

    [self performDigest:hashvalue off:offset len:LENGTH];
    return LENGTH;
}

- (void)performDigest:(char *)hashvalue off:(int)offset len:(int)resultLength {

    /* The input length in bits before padding occurs */
    int64_t inputLength = self.count << 3;

    [self update:0x80];

    /* Pad with zeros until overall length is a multiple of 896 */
    while ((int) (self.count & COUNT_MASK) != 112) {
        [self update:0];
    }

    self.W[14] = 0;
    self.W[15] = inputLength;
    self.count += 16;
    [self computeBlock];

    // Copy out the result
    switch (resultLength) {
        case 64:
            hashvalue[offset + 63] = (char) (((uint64_t) self.HH) >> 0);
            hashvalue[offset + 62] = (char) (((uint64_t) self.HH) >> 8);
            hashvalue[offset + 61] = (char) (((uint64_t) self.HH) >> 16);
            hashvalue[offset + 60] = (char) (((uint64_t) self.HH) >> 24);
            hashvalue[offset + 59] = (char) (((uint64_t) self.HH) >> 32);
            hashvalue[offset + 58] = (char) (((uint64_t) self.HH) >> 40);
            hashvalue[offset + 57] = (char) (((uint64_t) self.HH) >> 48);
            hashvalue[offset + 56] = (char) (((uint64_t) self.HH) >> 56);
            hashvalue[offset + 55] = (char) (((uint64_t) self.GG) >> 0);
            hashvalue[offset + 54] = (char) (((uint64_t) self.GG) >> 8);
            hashvalue[offset + 53] = (char) (((uint64_t) self.GG) >> 16);
            hashvalue[offset + 52] = (char) (((uint64_t) self.GG) >> 24);
            hashvalue[offset + 51] = (char) (((uint64_t) self.GG) >> 32);
            hashvalue[offset + 50] = (char) (((uint64_t) self.GG) >> 40);
            hashvalue[offset + 49] = (char) (((uint64_t) self.GG) >> 48);
            hashvalue[offset + 48] = (char) (((uint64_t) self.GG) >> 56);
        case 48:
            hashvalue[offset + 47] = (char) (((uint64_t) self.FF) >> 0);
            hashvalue[offset + 46] = (char) (((uint64_t) self.FF) >> 8);
            hashvalue[offset + 45] = (char) (((uint64_t) self.FF) >> 16);
            hashvalue[offset + 44] = (char) (((uint64_t) self.FF) >> 24);
            hashvalue[offset + 43] = (char) (((uint64_t) self.FF) >> 32);
            hashvalue[offset + 42] = (char) (((uint64_t) self.FF) >> 40);
            hashvalue[offset + 41] = (char) (((uint64_t) self.FF) >> 48);
            hashvalue[offset + 40] = (char) (((uint64_t) self.FF) >> 56);
            hashvalue[offset + 39] = (char) (((uint64_t) self.EE) >> 0);
            hashvalue[offset + 38] = (char) (((uint64_t) self.EE) >> 8);
            hashvalue[offset + 37] = (char) (((uint64_t) self.EE) >> 16);
            hashvalue[offset + 36] = (char) (((uint64_t) self.EE) >> 24);
            hashvalue[offset + 35] = (char) (((uint64_t) self.EE) >> 32);
            hashvalue[offset + 34] = (char) (((uint64_t) self.EE) >> 40);
            hashvalue[offset + 33] = (char) (((uint64_t) self.EE) >> 48);
            hashvalue[offset + 32] = (char) (((uint64_t) self.EE) >> 56);
        case 32:
            hashvalue[offset + 31] = (char) (((uint64_t) self.DD) >> 0);
            hashvalue[offset + 30] = (char) (((uint64_t) self.DD) >> 8);
            hashvalue[offset + 29] = (char) (((uint64_t) self.DD) >> 16);
            hashvalue[offset + 28] = (char) (((uint64_t) self.DD) >> 24);
            hashvalue[offset + 27] = (char) (((uint64_t) self.DD) >> 32);
            hashvalue[offset + 26] = (char) (((uint64_t) self.DD) >> 40);
            hashvalue[offset + 25] = (char) (((uint64_t) self.DD) >> 48);
            hashvalue[offset + 24] = (char) (((uint64_t) self.DD) >> 56);
            hashvalue[offset + 23] = (char) (((uint64_t) self.CC) >> 0);
            hashvalue[offset + 22] = (char) (((uint64_t) self.CC) >> 8);
            hashvalue[offset + 21] = (char) (((uint64_t) self.CC) >> 16);
            hashvalue[offset + 20] = (char) (((uint64_t) self.CC) >> 24);
            hashvalue[offset + 19] = (char) (((uint64_t) self.CC) >> 32);
            hashvalue[offset + 18] = (char) (((uint64_t) self.CC) >> 40);
            hashvalue[offset + 17] = (char) (((uint64_t) self.CC) >> 48);
            hashvalue[offset + 16] = (char) (((uint64_t) self.CC) >> 56);
            hashvalue[offset + 15] = (char) (((uint64_t) self.BB) >> 0);
            hashvalue[offset + 14] = (char) (((uint64_t) self.BB) >> 8);
            hashvalue[offset + 13] = (char) (((uint64_t) self.BB) >> 16);
            hashvalue[offset + 12] = (char) (((uint64_t) self.BB) >> 24);
            hashvalue[offset + 11] = (char) (((uint64_t) self.BB) >> 32);
            hashvalue[offset + 10] = (char) (((uint64_t) self.BB) >> 40);
            hashvalue[offset + 9] = (char) (((uint64_t) self.BB) >> 48);
            hashvalue[offset + 8] = (char) (((uint64_t) self.BB) >> 56);
            hashvalue[offset + 7] = (char) (((uint64_t) self.AA) >> 0);
            hashvalue[offset + 6] = (char) (((uint64_t) self.AA) >> 8);
            hashvalue[offset + 5] = (char) (((uint64_t) self.AA) >> 16);
            hashvalue[offset + 4] = (char) (((uint64_t) self.AA) >> 24);
            hashvalue[offset + 3] = (char) (((uint64_t) self.AA) >> 32);
            hashvalue[offset + 2] = (char) (((uint64_t) self.AA) >> 40);
            hashvalue[offset + 1] = (char) (((uint64_t) self.AA) >> 48);
            hashvalue[offset + 0] = (char) (((uint64_t) self.AA) >> 56);
            break;
        default:
            @throw [NSException exceptionWithName:@"Error" reason:@"Unsupported Digest length" userInfo:nil];
    }
    [self engineReset];
}

/**
 * Compute the hash for the current block.
 * <p/>
 * This is in the same vein as Peter Gutmann's algorithm listed in
 * the back of Applied Cryptography, Compact implementation of
 * "old" NIST Secure Hash Algorithm.
 */
- (void)computeBlock {
    int64_t T1, T2, a, b, c, d, e, f, g, h;

    // The first 16 int64_ts are from the byte stream, compute the rest of
    // the W[]'s
    for (int t = 16; t < ITERATION; t++) {
        int64_t d1 = [SHA5 lf_delta1:self.W[t - 2]];
        int64_t d2 = [SHA5 lf_delta0:self.W[t - 15]];
        self.W[t] = d1 + self.W[t - 7] + d2 + self.W[t - 16];
    }

    a = self.AA;
    b = self.BB;
    c = self.CC;
    d = self.DD;
    e = self.EE;
    f = self.FF;
    g = self.GG;
    h = self.HH;

    for (int i = 0; i < ITERATION; i++) {
        T1 = h + [SHA5 lf_sigma1:e] + [SHA5 lf_ch_x:e y:f z:g] + ROUND_CONSTS[i] + self.W[i];
        T2 = [SHA5 lf_sigma0:a] + [SHA5 lf_maj_x:a y:b z:c];
        h = g;
        g = f;
        f = e;
        e = d + T1;
        d = c;
        c = b;
        b = a;
        a = T1 + T2;
    }
    self.AA += a;
    self.BB += b;
    self.CC += c;
    self.DD += d;
    self.EE += e;
    self.FF += f;
    self.GG += g;
    self.HH += h;
}


+ (NSData *)hash:(NSData *)data {
    SHA5 *sha = [[SHA5 alloc] init];
    [sha setup];
    [sha engineUpdate:data.bytes off:0 len:data.length];
    char *dig = [sha engineDigest];
    NSData *ret = [[NSData alloc] initWithBytes:dig length:LENGTH];
    free(dig);
    return ret;
}
@end
//
// Created by Stephan Bösebeck on 07.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import "AES.h"

@interface AES ()
@property int *log;
@property int *alog;

@end

@implementation AES
static const int rcon[] = {
        0,
        1, 2, 4, 8, 16, 32,
        64, -128, 27, 54, 108, -40,
        -85, 77, -102, 47, 94, -68,
        99, -58, -105, 53, 106, -44,
        -77, 125, -6, -17, -59, -111};

static const int row_shift[] = {0, 1, 2, 3};

static const int S[] = {
        99, 124, 119, 123, -14, 107, 111, -59, 48, 1, 103, 43, -2, -41, -85, 118,
        -54, -126, -55, 125, -6, 89, 71, -16, -83, -44, -94, -81, -100, -92, 114, -64,
        -73, -3, -109, 38, 54, 63, -9, -52, 52, -91, -27, -15, 113, -40, 49, 21,
        4, -57, 35, -61, 24, -106, 5, -102, 7, 18, -128, -30, -21, 39, -78, 117,
        9, -125, 44, 26, 27, 110, 90, -96, 82, 59, -42, -77, 41, -29, 47, -124,
        83, -47, 0, -19, 32, -4, -79, 91, 106, -53, -66, 57, 74, 76, 88, -49,
        -48, -17, -86, -5, 67, 77, 51, -123, 69, -7, 2, 127, 80, 60, -97, -88,
        81, -93, 64, -113, -110, -99, 56, -11, -68, -74, -38, 33, 16, -1, -13, -46,
        -51, 12, 19, -20, 95, -105, 68, 23, -60, -89, 126, 61, 100, 93, 25, 115,
        96, -127, 79, -36, 34, 42, -112, -120, 70, -18, -72, 20, -34, 94, 11, -37,
        -32, 50, 58, 10, 73, 6, 36, 92, -62, -45, -84, 98, -111, -107, -28, 121,
        -25, -56, 55, 109, -115, -43, 78, -87, 108, 86, -12, -22, 101, 122, -82, 8,
        -70, 120, 37, 46, 28, -90, -76, -58, -24, -35, 116, 31, 75, -67, -117, -118,
        112, 62, -75, 102, 72, 3, -10, 14, 97, 53, 87, -71, -122, -63, 29, -98,
        -31, -8, -104, 17, 105, -39, -114, -108, -101, 30, -121, -23, -50, 85, 40, -33,
        -116, -95, -119, 13, -65, -26, 66, 104, 65, -103, 45, 15, -80, 84, -69, 22};

static const int Si[] = {
        82, 9, 106, -43, 48, 54, -91, 56, -65, 64, -93, -98, -127, -13, -41, -5,
        124, -29, 57, -126, -101, 47, -1, -121, 52, -114, 67, 68, -60, -34, -23, -53,
        84, 123, -108, 50, -90, -62, 35, 61, -18, 76, -107, 11, 66, -6, -61, 78,
        8, 46, -95, 102, 40, -39, 36, -78, 118, 91, -94, 73, 109, -117, -47, 37,
        114, -8, -10, 100, -122, 104, -104, 22, -44, -92, 92, -52, 93, 101, -74, -110,
        108, 112, 72, 80, -3, -19, -71, -38, 94, 21, 70, 87, -89, -115, -99, -124,
        -112, -40, -85, 0, -116, -68, -45, 10, -9, -28, 88, 5, -72, -77, 69, 6,
        -48, 44, 30, -113, -54, 63, 15, 2, -63, -81, -67, 3, 1, 19, -118, 107,
        58, -111, 17, 65, 79, 103, -36, -22, -105, -14, -49, -50, -16, -76, -26, 115,
        -106, -84, 116, 34, -25, -83, 53, -123, -30, -7, 55, -24, 28, 117, -33, 110,
        71, -15, 26, 113, 29, 41, -59, -119, 111, -73, 98, 14, -86, 24, -66, 27,
        -4, 86, 62, 75, -58, -46, 121, 32, -102, -37, -64, -2, 120, -51, 90, -12,
        31, -35, -88, 51, -120, 7, -57, 49, -79, 18, 16, 89, 39, -128, -20, 95,
        96, 81, 127, -87, 25, -75, 74, 13, 45, -27, 122, -97, -109, -55, -100, -17,
        -96, -32, 59, 77, -82, 42, -11, -80, -56, -21, -69, 60, -125, 83, -103, 97,
        23, 43, 4, 126, -70, 119, -42, 38, -31, 105, 20, 99, 85, 33, 12, 125};


/**
   * AES constants and variables.
   */
#define  BLOCK_SIZE  16


// Define key attributes for current AES instance
/**
 * number of rounds used given AES key set on this instance.
 */
int numRounds;
/**
 * encryption round keys derived from AES key set on this instance.
 */
char *Ke;
/**
 * decryption round keys derived from AES key set on this instance.
 */
char *Kd;

#define COL_SIZE  4
#define NUM_COLS  BLOCK_SIZE / COL_SIZE
#define ROOT  0x11B

/**
 * Internal AES constants and variables.
 */
//    public static final int
//            COL_SIZE = 4,                // depth of each column in AES state variable
//            NUM_COLS = BLOCK_SIZE / COL_SIZE,    // number of columns in AES state variable
//                        // generator polynomial used in GF(2^8)

/**
 * define ShiftRows transformation as shift amount for each row in state.
 */


//    /* alog table for field GF(2^m) used to speed up multiplications. */
//    static final int[] alog = new int[256];
//    /* log table for field GF(2^m) used to speed up multiplications. */
//    static final int[] log = new int[256];

/** static code to initialise the log and alog tables.
 *  Used to implement multiplication in GF(2^8).
 */

- (id)init {
    self = [super init];
    if (self) {
        self.alog;
    }

    return self;
}


/**
 * return number of rounds for a given AES key size.
 *
 * @param keySize size of the user key material in bytes.
 * @return number of rounds for a given AES key size.
 */
+ (int)getRounds:(int)keySize {
    switch (keySize) {
        case 16:    // 16 byte = 128 bit key
            return 10;
        case 24:    // 24 byte = 192 bit key
            return 12;
        default:    // 32 byte = 256 bit key
            return 14;
    }
}

//
//    /** diagnostic trace of static tables. */
//    public static void trace_static() {
//        int i,j;
//        System.out.print("AES Static Tablesn");
//        System.out.print("S[] = n"); for(i=0;i<16;i++) { for(j=0;j<16;j++) System.out.print(Utils.getHex(S[i*16+j])+", "); System.out.println();}
//        System.out.print("Si[] = n"); for(i=0;i<16;i++) { for(j=0;j<16;j++) System.out.print(Utils.getHex(Si[i*16+j])+", "); System.out.println();}
//        System.out.print("rcon[] = n"); for(i=0;i<5;i++) {for(j=0;j<6;j++) System.out.print(Utils.getHex(rcon[i*6+j])+", "); System.out.println();}
//        System.out.print("log[] = n"); for(i=0;i<32;i++) {for(j=0;j<8;j++) System.out.print(Utils.getHex(log[i*8+j])+", "); System.out.println();}
//        System.out.print("alog[] = n"); for(i=0;i<32;i++) {for(j=0;j<8;j++) System.out.print(Utils.getHex(alog[i*8+j])+", "); System.out.println();}
//    }

//......................................................................

/**
 * AES encrypt 128-bit plaintext using key previously set.
 * <p/>
 * <p>Follows cipher specification given in FIPS-197 section 5.1
 * See pseudo code in Fig 5, and details in this section.
 *
 * @param plain the 128-bit plaintext value to encrypt.
 * @return the encrypted 128-bit ciphertext value.
 */
- (char *)encryptBlock:(char *)plain {
    // define working variables
    char *a = malloc(BLOCK_SIZE);    // AES state variable
    char *ta = malloc(BLOCK_SIZE);    // AES temp state variable
    for (int i = 0; i < BLOCK_SIZE; i++) a[i] = ta[i] = 0;
    char *Ker;                // encrypt keys for current round
    int i, k, row, col;


    // check for bad arguments
    if (plain == nil)
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"Empty plain" userInfo:nil];


    // copy plaintext bytes into state and do initial AddRoundKey(state)
    Ker = Ke;
    for (i = 0; i < BLOCK_SIZE; i++) a[i] = (char) (plain[i] ^ Ker[i]);

    // for each round except last, apply round transforms
    for (int r = 1; r < numRounds; r++) {
        Ker = Ke + r * BLOCK_SIZE;            // get session keys for this round

        // SubBytes(state) into ta using S-Box S
        for (i = 0; i < BLOCK_SIZE; i++) ta[i] = (char) S[a[i] & 0xFF];

        // ShiftRows(state) into a
        for (i = 0; i < BLOCK_SIZE; i++) {
            row = i % COL_SIZE;
            k = (i + (row_shift[row] * COL_SIZE)) % BLOCK_SIZE;    // get shifted byte index
            a[i] = ta[k];
        }

        // MixColumns(state) into ta
        //   implemented by expanding matrix mult for each column
        //   see FIPS-197 section 5.1.3
        for (col = 0; col < NUM_COLS; col++) {
            i = col * COL_SIZE;        // start index for this col
            ta[i] = (char) ([self mul:2 b:a[i]] ^ [self mul:3 b:a[i + 1]] ^ a[i + 2] ^ a[i + 3]);
            ta[i + 1] = (char) (a[i] ^ [self mul:2 b:a[i + 1]] ^ [self mul:3 b:a[i + 2]] ^ a[i + 3]);
            ta[i + 2] = (char) (a[i] ^ a[i + 1] ^ [self mul:2 b:a[i + 2]] ^ [self mul:3 b:a[i + 3]]);
            ta[i + 3] = (char) ([self mul:3 b:a[i]] ^ a[i + 1] ^ a[i + 2] ^ [self mul:2 b:a[i + 3]]);
        }

        // AddRoundKey(state) into a
        for (i = 0; i < BLOCK_SIZE; i++) a[i] = (char) (ta[i] ^ Ker[i]);
    }

    // last round is special - only has SubBytes, ShiftRows and AddRoundKey
    Ker = Ke + numRounds * BLOCK_SIZE;            // get session keys for final round

    // SubBytes(state) into a using S-Box S
    for (i = 0; i < BLOCK_SIZE; i++) a[i] = S[a[i] & 0xFF];

    // ShiftRows(state) into ta
    for (i = 0; i < BLOCK_SIZE; i++) {
        row = i % COL_SIZE;
        k = (i + (row_shift[row] * COL_SIZE)) % BLOCK_SIZE;    // get shifted byte index
        ta[i] = a[k];
    }

    // AddRoundKey(state) into a
    for (i = 0; i < BLOCK_SIZE; i++) a[i] = (char) (ta[i] ^ Ker[i]);
    free(ta);

    return a;
}


/**
 * multiply two elements of GF(2^8).
 * <p>Using pre-computed log and alog tables for speed.
 *
 * @param a 1st value to multiply
 * @param b 2nd value to multiply
 * @return product of a * b module its generator polynomial
 */

- (int)mul:(int)a b:(int)b {
    return (a != 0 && b != 0) ?
            self.alog[(self.log[a & 0xFF] + self.log[b & 0xFF]) % 255] :
            0;
}
//......................................................................

/**
 * AES decrypt 128-bit ciphertext using key previously set.
 * <p/>
 * <p>Follows cipher specification given in FIPS-197 section 5.3
 * See pseudo code in Fig 5, and details in this section.
 *
 * @param cipher the 128-bit ciphertext value to decrypt.
 * @return the decrypted 128-bit plaintext value.
 */
- (char *)decryptBlock:(char *)cipher {
    // define working variables
    char *a = malloc(BLOCK_SIZE);    // AES state variable
    char *ta = malloc(BLOCK_SIZE);    // AES temp state variable
    for (int i = 0; i < BLOCK_SIZE; i++) ta[i] = a[i] = 0;

    char *Kdr;                // encrypt keys for current round
    int i, j, k, row, col;


    // check for bad arguments
    if (cipher == nil)
        @throw [NSException exceptionWithName:@"IllegalArgumentExeption" reason:@"Empty cypher" userInfo:nil];


    // copy ciphertext bytes into state and do initial AddRoundKey(state)
    Kdr = Kd;
    for (i = 0; i < BLOCK_SIZE; i++) a[i] = (char) (cipher[i] ^ Kdr[i]);

    // for each round except last, apply round transforms
    for (int r = 1; r < numRounds; r++) {
        Kdr = Kd + (r * BLOCK_SIZE);            // get session keys for this round

        // InvShiftRows(state) into ta (nb. same shift as encrypt but subtract)
        for (i = 0; i < BLOCK_SIZE; i++) {
            row = i % COL_SIZE;
            // get shifted byte index
            k = (i + BLOCK_SIZE - (row_shift[row] * COL_SIZE)) % BLOCK_SIZE;
            ta[i] = a[k];
        }

        // InvSubBytes(state) into a using inverse S-box Si
        for (i = 0; i < BLOCK_SIZE; i++) a[i] = (char) Si[ta[i] & 0xFF];

        // AddRoundKey(state) into ta
        for (i = 0; i < BLOCK_SIZE; i++) ta[i] = (char) (a[i] ^ Kdr[i]);

        // InvMixColumns(state) into a
        //   implemented by expanding matrix mult for each column
        //   see FIPS-197 section 5.3.3
        for (col = 0; col < NUM_COLS; col++) {
            i = col * COL_SIZE;        // start index for this col
            a[i] = (char) ([self mul:0x0e b:ta[i]] ^ [self mul:0x0b b:ta[i + 1]] ^ [self mul:0x0d b:ta[i + 2]] ^ [self mul:0x09 b:ta[i + 3]]);
            a[i + 1] = (char) ([self mul:0x09 b:ta[i]] ^ [self mul:0x0e b:ta[i + 1]] ^ [self mul:0x0b b:ta[i + 2]] ^ [self mul:0x0d b:ta[i + 3]]);
            a[i + 2] = (char) ([self mul:0x0d b:ta[i]] ^ [self mul:0x09 b:ta[i + 1]] ^ [self mul:0x0e b:ta[i + 2]] ^ [self mul:0x0b b:ta[i + 3]]);
            a[i + 3] = (char) ([self mul:0x0b b:ta[i]] ^ [self mul:0x0d b:ta[i + 1]] ^ [self mul:0x09 b:ta[i + 2]] ^ [self mul:0x0e b:ta[i + 3]]);
        }
    }

    // last round is special - only has InvShiftRows, InvSubBytes and AddRoundKey
    Kdr = Kd + (numRounds * BLOCK_SIZE);            // get session keys for final round

    // InvShiftRows(state) into ta
    for (i = 0; i < BLOCK_SIZE; i++) {
        row = i % COL_SIZE;
        // get shifted byte index
        k = (i + BLOCK_SIZE - (row_shift[row] * COL_SIZE)) % BLOCK_SIZE;
        ta[i] = a[k];
    }

    // InvSubBytes(state) into ta using inverse S-box Si
    for (i = 0; i < BLOCK_SIZE; i++) ta[i] = Si[ta[i] & 0xFF];

    // AddRoundKey(state) into a
    for (i = 0; i < BLOCK_SIZE; i++) a[i] = (char) (ta[i] ^ Kdr[i]);
    free(ta);
    return a;
}

- (void)dealloc {
    free(Ke);
    free(Kd);
}

//......................................................................

/**
 * Expand a user-supplied key material into a session key.
 * <p>See FIPS-197 Section 5.3 Fig 11 for details of the key expansion.
 * <p>Session keys will be saved in Ke and Kd instance variables,
 * along with numRounds being the number of rounds for this sized key.
 *
 * @param key The 128/192/256-bit AES key to use.
 */
- (void)setEncryptionKey:(NSData *)key {
    // assorted internal constants
    int BC = BLOCK_SIZE / 4;
    int Klen = key.length;
    int Nk = Klen / 4;

    int i, j, r;

    // check for bad arguments
    // check for bad arguments
    if (key == nil)
        @throw [NSException exceptionWithName:@"IllegalArgumentExeption" reason:@"Empty key" userInfo:nil];
    if (!(key.length == 16 || key.length == 24 || key.length == 32))
        @throw [NSException exceptionWithName:@"IllegalArgumentExeption" reason:@"wrong keylength" userInfo:nil];

    // set master number of rounds given size of this key
    numRounds = [AES getRounds:Klen];
    int ROUND_KEY_COUNT = (numRounds + 1) * BC;

    // allocate 4 arrays of bytes to hold the session key values
    // each array holds 1 of the 4 bytes [b0 b1 b2 b3] in each word w
    char *w0 = malloc((size_t) ROUND_KEY_COUNT);
    char *w1 = malloc((size_t) ROUND_KEY_COUNT);
    char *w2 = malloc((size_t) ROUND_KEY_COUNT);
    char *w3 = malloc((size_t) ROUND_KEY_COUNT);
    for (int i = 0; i < ROUND_KEY_COUNT; i++) w0[i] = w1[i] = w2[i] = w3[i] = 0;

    // allocate arrays to hold en/decrypt session keys (by byte rather than word)
    Ke = malloc((size_t) ((numRounds + 1) * BLOCK_SIZE)); // encryption round keys
    Kd = malloc((size_t) ((numRounds + 1) * BLOCK_SIZE)); // decryption round keys
    for (int i = 0; i < ((numRounds + 1) * BLOCK_SIZE); i++) Ke[i] = Kd[i] = 0;

    // copy key into start of session array (by word, each byte in own array)
    char *keyDat = key.bytes;
    for (i = 0, j = 0; i < Nk; i++) {
        w0[i] = keyDat[j++];
        w1[i] = keyDat[j++];
        w2[i] = keyDat[j++];
        w3[i] = keyDat[j++];
    }

    // implement key expansion algorithm
    char t0, t1, t2, t3, old0;        // temp byte values for each word
    for (i = Nk; i < ROUND_KEY_COUNT; i++) {
        t0 = w0[i - 1];
        t1 = w1[i - 1];
        t2 = w2[i - 1];
        t3 = w3[i - 1];    // temp = w[i-1]
        if (i % Nk == 0) {
            // temp = SubWord(RotWord(temp)) ^ Rcon[i/Nk]
            old0 = t0;            // save old 1st byte value for t3 calc
            t0 = (char) (S[t1 & 0xFF] ^ rcon[i / Nk]);    // nb. constant XOR 1st byte only
            t1 = (char) (S[t2 & 0xFF]);
            t2 = (char) (S[t3 & 0xFF]);    // nb. RotWord done by reordering bytes used
            t3 = (char) (S[old0 & 0xFF]);
        } else if ((Nk > 6) && (i % Nk == 4)) {
            // temp = SubWord(temp)
            t0 = (char) S[t0 & 0xFF];
            t1 = (char) S[t1 & 0xFF];
            t2 = (char) S[t2 & 0xFF];
            t3 = (char) S[t3 & 0xFF];
        }
        // w[i] = w[i-Nk] ^ temp
        w0[i] = (char) (w0[i - Nk] ^ t0);
        w1[i] = (char) (w1[i - Nk] ^ t1);
        w2[i] = (char) (w2[i - Nk] ^ t2);
        w3[i] = (char) (w3[i - Nk] ^ t3);
    }

    // now copy values into en/decrypt session arrays by round & byte in round
    for (r = 0, i = 0; r < numRounds + 1; r++) {    // for each round
        for (j = 0; j < BC; j++) {        // for each word in round
            Ke[r * BLOCK_SIZE + 4 * j] = w0[i];
            Ke[r * BLOCK_SIZE + 4 * j + 1] = w1[i];
            Ke[r * BLOCK_SIZE + 4 * j + 2] = w2[i];
            Ke[r * BLOCK_SIZE + 4 * j + 3] = w3[i];
            Kd[(numRounds - r) * BLOCK_SIZE + 4 * j] = w0[i];
            Kd[(numRounds - r) * BLOCK_SIZE + 4 * j + 1] = w1[i];
            Kd[(numRounds - r) * BLOCK_SIZE + 4 * j + 2] = w2[i];
            Kd[(numRounds - r) * BLOCK_SIZE + 4 * j + 3] = w3[i];


            i++;
        }
    }
//    NSLog(@"WL0: %@", [[[NSData alloc] initWithBytes:w0 length:ROUND_KEY_COUNT] hexDump:NO]);
//    NSLog(@"WL1: %@", [[[NSData alloc] initWithBytes:w1 length:ROUND_KEY_COUNT] hexDump:NO]);
//    NSLog(@"WL2: %@", [[[NSData alloc] initWithBytes:w2 length:ROUND_KEY_COUNT] hexDump:NO]);
//    NSLog(@"WL3: %@", [[[NSData alloc] initWithBytes:w3 length:ROUND_KEY_COUNT] hexDump:NO]);
    free(w0);
    free(w1);
    free(w2);
    free(w3);
}


/**
 * self-test routine for AES cipher
 */
//
//    public String _cryptAll(String data, int mode) {
//        AES aes = this;
//        if (data.length() / 16 > ((int) data.length() / 16)) {
//            int rest = data.length() - ((int) data.length() / 16) * 16;
//            for (int i = 0; i < rest; i++)
//                data += " ";
//        }
//        int nParts = (int) data.length() / 16;
//        byte[] res = new byte[data.length()];
//        String partStr = "";
//        byte[] partByte = new byte[16];
//        for (int p = 0; p < nParts; p++) {
//            partStr = data.substring(p * 16, p * 16 + 16);
//            partByte = static_stringToByteArray(partStr);
//            if (mode == 1) partByte = aes.encrypt(partByte);
//            if (mode == 2) partByte = aes.decrypt(partByte);
//            for (int b = 0; b < 16; b++)
//                res[p * 16 + b] = partByte[b];
//        }
//        return static_byteArrayToString(res);
//    }
- (NSData *)encrypt:(NSData *)data {
//    NSLog(@"Data: %@",[data hexDump:NO]);
//    NSLog(@"Encrypted length: ");
    NSMutableData *ret = [[NSMutableData alloc] init];
    NSUInteger newLen = data.length + 4;
    char *r = malloc(newLen);
    for (int i = 0; i < newLen; i++) r[i] = 0;
    [AES fillInteger:data.length into:r atPos:0];
    char *dat = data.bytes;
    memcpy(r + 4, dat, data.length);
    char *block = malloc(BLOCK_SIZE);
    for (int i = 0; i < newLen; i += BLOCK_SIZE) {
        for (int j = 0; j < BLOCK_SIZE; j++) block[j] = 0;

        int l = BLOCK_SIZE;
        if (i + BLOCK_SIZE > newLen) {
            l = newLen - i;
        }
        memcpy(block, r + i, l);
        char *part = [self encryptBlock:block];
        [ret appendBytes:part length:BLOCK_SIZE];
//        NSLog(@"Clear: %@", [[[NSData alloc] initWithBytes:block length:BLOCK_SIZE] hexDump:NO]);
//        NSLog(@"part : %@", [[[NSData alloc] initWithBytes:part length:BLOCK_SIZE] hexDump:NO]);
//        char *dec = [self decryptBlock:part];
//        NSLog(@"dec  : %@", [[[NSData alloc] initWithBytes:dec length:BLOCK_SIZE] hexDump:NO]);
//        NSLog(@"\n");
        free(part);
    }
    free(r);
    free(block);
    return ret;
}


+ (int)getIntFrom:(NSData *)dat atIndex:(int)idx {
    unsigned char const *buffer = dat.bytes;
    int v = 0;
    v |= buffer[idx + 0] << 24;
    v |= buffer[idx + 1] << 16;
    v |= buffer[idx + 2] << 8;
    v |= buffer[idx + 3];
    return v;

}


+ (void)fillInteger:(int64_t)v into:(char *)buffer atPos:(int64_t)position {
    buffer[0 + position] = (char) ((((uint32_t) v) >> 24) & 0xff);
    buffer[1 + position] = (char) ((((uint32_t) v) >> 16) & 0xff);
    buffer[2 + position] = (char) ((((uint32_t) v) >> 8) & 0xff);
    buffer[3 + position] = (char) ((((uint32_t) v)) & 0xff);
}

- (NSData *)decrypt:(NSData *)data {
    NSMutableData *ret = [[NSMutableData alloc] init];
    char *block = malloc(BLOCK_SIZE);
    for (int i = 0; i < data.length; i += BLOCK_SIZE) {
        for (int j = 0; j < BLOCK_SIZE; j++) block[j] = 0;
        [data getBytes:block range:NSMakeRange(i, BLOCK_SIZE)];
        char *part = [self decryptBlock:block];
        [ret appendBytes:part length:BLOCK_SIZE];
        free(part);
    }
    int len = (int) [AES getIntFrom:ret atIndex:0];
    char *result = malloc(len);
    [ret getBytes:result range:NSMakeRange(4, len)];
    NSData *toRet = [[NSData alloc] initWithBytes:result length:len];
    free(result);
    free(block);

    return toRet;
}

+ (void)initialize {
    [super initialize];

}

/**
  * AES encryption S-box.
  * <p>See FIPS-197 section 5.1.1 or Stallings section 5.2.
  * Note that hex values have been converted to decimal for easy table
  * specification in Java.
  */



- (int *)alog {
    if (!_alog) {
        self.log;
    }
    return _alog;
}

- (int *)log {
    if (!_log) {
        _log = malloc(sizeof(int) * 256);
        _alog = malloc(sizeof(int) * 256);
        for (int i = 0; i < 256; i++) {
            _log[i] = _alog[i] = 0;
        }

        int i, j;
        // produce log and alog tables, needed for multiplying in the field GF(2^8)
        _alog[0] = 1;
        for (i = 1; i < 256; i++) {
            j = (_alog[i - 1] << 1) ^ _alog[i - 1];
            if ((j & 0x100) != 0) j ^= ROOT;
            _alog[i] = j;
        }
        for (i = 1; i < 255; i++) _log[_alog[i]] = i;

    }
    return _log;
}


@end
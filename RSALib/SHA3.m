//
// Created by Stephan Bösebeck on 08.01.14.
// Copyright (c) 2014 Stephan Bösebeck. All rights reserved.
//

#import "SHA3.h"

@interface SHA3 ()
@property(nonatomic) int length;
@end

@implementation SHA3

static const int64_t INITIAL_HASHES[] = {
        0xcbbb9d5dc1059ed8L, 0x629a292a367cd507L,
        0x9159015a3070dd17L, 0x152fecd8f70e5939L,
        0x67332667ffc00b31L, 0x8eb44a8768581511L,
        0xdb0c2e0d64f98fa7L, 0x47b5481dbefa4fa4L
};

- (id)init {
    self = [super init];
    if (self) {
        self.length = 48;
    }

    return self;
}

- (instancetype)initWithLength:(int)length {
    self = [super init];
    if (self) {
        self.length = length;
    }

    return self;
}


- (void)setup {
    [super setup];
    [super setInitialHash:INITIAL_HASHES];
}


/**
 * Computes the final hash and returns the final value as a
 * byte[48] array. The object is reset to be ready for further
 * use, as specified in the JavaSecurity MessageDigest
 * specification.
 */
- (char *)engineDigest {
    char *sha5hashvalue = [super engineDigest];
    char *hashvalue = malloc((size_t) self.length);
    memcpy(hashvalue, sha5hashvalue, self.length);
//    System.arraycopy(sha5hashvalue, 0, hashvalue, 0, length);
    free(sha5hashvalue);
    return hashvalue;
}

/**
 * Resets the buffers and hash value to start a new hash.
 */
- (void)engineReset {
    [self setup];
}

/**
 * Computes the final hash and returns the final value as a
 * byte[48] array. The object is reset to be ready for further
 * use, as specified in the JavaSecurity MessageDigest
 * specification.
 *
 * @param hashvalue buffer to hold the digest
 * @param offset    offset for storing the digest
 * @param len       length of the buffer
 * @return length of the digest in bytes
 */
- (int)engineDigest:(char *)hashvalue off:(int)offset len:(int)len {
    if (len < self.length)
        @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"partial digests not returned" userInfo:nil];
    [super performDigest:hashvalue off:offset len:self.length];
    return self.length;
}

+ (NSData *)createHashOf:(NSData *)data length:(int)l {
    SHA3 *sha = [[SHA3 alloc] initWithLength:l];
    [sha setup];
    [sha engineUpdate:data.bytes off:0 len:data.length];
    char *dig = [sha engineDigest];
    NSData *ret = [[NSData alloc] initWithBytes:dig length:l];
    free(dig);
    return ret;
}


@end
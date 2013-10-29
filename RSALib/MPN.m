//
// Created by Stephan Bösebeck on 22.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "MPN.h"


@implementation MPN

+ (int64_t)add_1:(int64_t *)dest x:(int64_t *)x size:(int)size y:(int64_t)y {
    int64_t carry = (int32_t) y & 0xffffffffL;
    for (int64_t i = 0; i < size; i++) {
        carry += (x[i] & 0xffffffffL);
        dest[i] = carry;
        carry >>= 32;
    }
    return (int32_t) carry;
}

+ (int64_t)add_n:(int64_t *)dest x:(int64_t *)x y:(int64_t *)y len:(int)len {
    int64_t carry = 0;
    for (int64_t i = 0; i < len; i++) {
        carry += (x[i] & 0xffffffffL)
                + (y[i] & 0xffffffffL);
        dest[i] = (int32_t) carry;
        carry >>= 32;
    }
    return (int32_t) carry;
}

+ (int64_t)sub_n:(int64_t *)dest x:(int64_t *)X y:(int64_t *)Y size:(int)size {
    int64_t cy = 0;
    for (int64_t i = 0; i < size; i++) {
        int64_t y = Y[i];
        int64_t x = X[i];
        y += cy;  /* add previous carry to subtrahend */
        // Invert the high-order bit, because: (unsigned) X > (unsigned) Y
        // iff: (int64_t) (X^0x80000000) > (int64_t) (Y^0x80000000).
        cy = (((uint64_t) y) ^ 0x80000000) < ((int64_t) ((uint64_t) cy) ^ 0x80000000) ? 1 : 0;
        y = x - y;
        int64_t t1 = ((int64_t) ((uint64_t) y) ^ 0x80000000);
        int64_t t2 = ((int64_t) ((uint64_t) x) ^ 0x80000000);
        cy += t1 > t2 ? 1 : 0;
//        cy += ((int64_t)((uint64_t)y)^0x80000000) > ((int64_t)((uint64_t)x)^0x80000000) ? 1 : 0;
        dest[i] = y;
    }
    return cy;
}

/** Multiply x[0:len-1] by y, and write the len least
 * significant words of the product to dest[0:len-1].
 * Return the most significant word of the product.
 * All values are treated as if they were unsigned
 * (i.e. masked with 0xffffffffL).
 * OK if dest==x (not sure if this is guaranteed for mpn_mul_1).
 * This function is basically the same as gmp's mpn_mul_1.
 */

+ (int64_t)mul_1:(int64_t *)dest x:(int64_t *)x len:(int64_t)len y:(int64_t)y {
    uint64_t yword = (uint64_t) y & 0xffffffffL;
    uint64_t carry = 0;
    for (int64_t j = 0; j < len; j++) {
        carry += (x[j] & 0xffffffffL) * yword;

        dest[j] = ((int32_t) (carry&0xffffffff))&0xffffffff;
        carry >>= 32;
    }
    return (int64_t) carry;
}

/**
 * Multiply x[0:xlen-1] and y[0:ylen-1], and
 * write the result to dest[0:xlen+ylen-1].
 * The destination has to have space for xlen+ylen words,
 * even if the result might be one limb smaller.
 * This function requires that xlen >= ylen.
 * The destination must be distinct from either input operands.
 * All operands are unsigned.
 * This function is basically the same gmp's mpn_mul. */

+ (void)mul:(int64_t *)dest x:(int64_t *)x xlen:(int64_t)xlen   y:(int64_t *)y ylen:(int64_t)ylen {
    dest[xlen] = [MPN mul_1:dest x:x len:xlen y:y[0]];

    for (int64_t i = 1; i < ylen; i++) {
        uint64_t yword = (uint64_t) y[i] & 0xffffffffL;
        uint64_t carry = 0;
        for (int64_t j = 0; j < xlen; j++) {
            carry += ((int32_t) x[j] & 0xffffffffL) * yword
                    + ((int32_t) dest[i + j] & 0xffffffffL);
            dest[i + j] = ((int32_t) (carry&0xffffffff))&0xffffffff;
            carry >>= 32;
        }
        dest[i + xlen] = ((int32_t) (carry&0xffffffff))&0xffffffff;
    }
}

/* Divide (uint64_t) N by (uint64_t) D.
 * Returns (remainder << 32)+(uint64_t)(quotient).
 * Assumes (uint64_t)(N>>32) < (uint64_t)D.
 * Code transcribed from gmp-2.0's mpn_udiv_w_sdiv function.
 */
+ (uint64_t)udiv_qrnnd:(uint64_t)N D:(int32_t)D {
    uint64_t q = 0, r = 0;
    uint64_t a1 = N >> 32;
    uint64_t a0 = N & 0xffffffffL;
    if (D >= 0) {
        if (a1 < ((D - a1 - (a0 >> 31)) & 0xffffffffL)) {
            /* dividend, divisor, and quotient are nonnegative */
            q = N / D;
            r = N % D;
        }
        else {
            /* Compute c1*2^32 + c0 = a1*2^32 + a0 - 2^31*d */
            int64_t c = N - ((uint64_t) D << 31);
            /* Divide (c1*2^32 + c0) by d */
            q = c / D;
            r = c % D;
            /* Add 2^31 to quotient */
            q += 1 << 31;
        }
    }
    else {
        uint64_t b1 = ((uint32_t) D) >> 1;  /* d/2, between 2^30 and 2^31 - 1 */
        //int64_t c1 = (a1 >> 1); /* A/2 */
        //int64_t c0 = (a1 << 31) + (a0 >> 1);
        uint64_t c = (N) >> 1;
        if (a1 < b1 || (a1 >> 1) < b1) {
            if (a1 < b1) {
                q = c / b1;
                r = c % b1;
            }
            else /* c1 < b1, so 2^31 <= (A/2)/b1 < 2^32 */
            {
                c = ~(c - (b1 << 32));
                q = c / b1;  /* (A/2) / (d/2) */
                r = c % b1;
                q = (~q) & 0xffffffffL;    /* (A/2)/b1 */
                r = (b1 - 1) - r; /* r < b1 => new r >= 0 */
            }
            r = 2 * r + (a0 & 1);
            if ((D & 1) != 0) {
                if (r >= q) {
                    r = r - q;
                } else if (q - r <= ((uint32_t) D & 0xffffffffL)) {
                    r = r - q + D;
                    q -= 1;
                } else {
                    r = r - q + D + D;
                    q -= 2;
                }
            }
        }
        else        /* Implies c1 = b1 */
        {        /* Hence a1 = d - 1 = 2*b1 - 1 */
            if (a0 >= ((uint32_t) (-D) & 0xffffffffL)) {
                q = (uint64_t) -1;
                r = a0 + D;
            }
            else {
                q = (uint64_t) -2;
                r = a0 + D + D;
            }
        }
    }

    return ((r << 32) | (q & 0xFFFFFFFFl));
}

/** Divide divident[0:len-1] by (uint64_t)divisor.
 * Write result __int64_to quotient[0:len-1.
 * Return the one-word (unsigned) remainder.
 * OK for quotient==dividend.
 */

+ (int64_t)divmod_1:(int64_t *)quotient divident:(int64_t *)dividend  len:(int64_t)len divisor:(int64_t)divisor {
    int64_t i = len - 1;
    uint64_t r = dividend[i];
    if ((r & 0xffffffffL) >= ((int64_t) divisor & 0xffffffffL))
        r = 0;
    else {
        quotient[i--] = 0;
        r <<= 32;
    }

    for (; i >= 0; i--) {
        int64_t n0 = (int32_t) dividend[i];
        r = (r & (~((int64_t) 0xffffffffL))) | (n0 & 0xffffffffL);
        r = [MPN udiv_qrnnd:r D:divisor];
        quotient[i] = (int32_t) r;
    }
    return (int64_t) (r >> 32);
}

/* Subtract x[0:len-1]*y from dest[offset:offset+len-1].
 * All values are treated as if unsigned.
 * @return the most significant word of
 * the product, minus borrow-out from the subtraction.
 */
+ (int32_t)submul_1:(int64_t *)dest offset:(int64_t)offset x:(int64_t *)x len:(int64_t)len y:(int64_t)y {
    int64_t yl = (int64_t) y & 0xffffffffL;
    int32_t carry = 0;
    int j = 0;
    do {
        int64_t prod = (x[j] & 0xffffffffffffffffL) * yl;
        int64_t prod_low = (int32_t) prod;
        int64_t prod_high = (int32_t) (prod >> 32);
        prod_low += carry;
        // Invert the high-order bit, because: (unsigned) X > (unsigned) Y
        // iff: (int64_t) (X^0x80000000) > (int64_t) (Y^0x80000000).
        carry = (int32_t) (((int32_t) (prod_low ^ ((int32_t) 0x80000000)) < (carry ^ ((int32_t) 0x80000000)) ? 1 : 0)
                + prod_high);
        int32_t x_j = (int32_t) dest[offset + j];
        prod_low = (int32_t) x_j - (int32_t) prod_low;
        if ((prod_low ^ ((int32_t) 0x80000000)) > (x_j ^ ((int32_t) 0x80000000)))
            carry++;
        dest[offset + j] = ((int32_t) prod_low) & 0xffffffff;
    }
    while (++j < len);
    return carry;
}

/** Divide zds[0:nx] by y[0:ny-1].
 * The remainder ends up in zds[0:ny-1].
 * The quotient ends up in zds[ny:nx].
 * Assumes:  nx>ny.
 * (int64_t)y[ny-1] < 0  (i.e. most significant bit set)
 */

+ (void)divide:(int64_t *)zds nx:(int)nx y:(int64_t *)y ny:(int)ny {
    // This is basically Knuth's formulation of the classical algorithm,
    // but translated from in scm_divbigbig in Jaffar's SCM implementation.

    // Correspondance with Knuth's notation:
    // Knuth's u[0:m+n] == zds[nx:0].
    // Knuth's v[1:n] == y[ny-1:0]
    // Knuth's n == ny.
    // Knuth's m == nx-ny.
    // Our nx == Knuth's m+n.

    // Could be re-implemented using gmp's mpn_divrem:
    // zds[nx] = mpn_divrem (&zds[ny], 0, zds, nx, y, ny).

    int j = nx;
    do {                          // loop over digits of quotient
        // Knuth's j == our nx-j.
        // Knuth's u[j:j+n] == our zds[j:j-ny].
        int64_t qhat = 0;  // treated as unsigned
        if (zds[j] == y[ny - 1]) {
            qhat = -1;
        }  // 0xffffffff
        else {
            int64_t w = (((int64_t) ((int32_t) zds[j])) << 32) + (((int64_t) zds[j - 1]) & 0xffffffffL);
            qhat = (int32_t) ([MPN udiv_qrnnd:w D:(int32_t) y[ny - 1]] & 0xffffffff);
        }
        if (qhat != 0) {
            int32_t borrow = [MPN submul_1:zds offset:j - ny x:y len:ny y:qhat];
            int32_t save = (int32_t) zds[j];
            int64_t num = ((int64_t) save & 0xffffffffL) - ((int64_t) borrow & 0xffffffffL);
            while (num != 0) {
                qhat--;
                uint64_t carry = 0;
                for (int i = 0; i < ny; i++) {
                    carry += ((int64_t) zds[j - ny + i] & 0xffffffffL)
                            + ((int64_t) y[i] & 0xffffffffL);
                    zds[j - ny + i] = ((carry&0xffffffff));
                    carry >>= 32;
                }
                zds[j] = ((zds[j] + carry) & 0xffffffff);
                if (zds[j]<0) {
                    NSLog(@"Alarm");
                }
                num = carry - 1;
            }
        }
        zds[j] = (qhat & 0xffffffff);
    } while (--j >= ny);
}

/** Number of digits in the conversion base that always fits in a word.
 * For example, for base 10 this is 9, since 10**9 is the
 * largest number that fits __int64_to a words (assuming 32-bit words).
 * This is the same as gmp's __mp_bases[radix].chars_per_limb.
 * @param radix the base
 * @return number of digits */
+ (int)chars_per_word:(int64_t)radix {
    if (radix < 10) {
        if (radix < 8) {
            if (radix <= 2)
                return 32;
            else if (radix == 3)
                return 20;
            else if (radix == 4)
                return 16;
            else
                return (int) (18 - radix);
        }
        else
            return 10;
    }
    else if (radix < 12)
        return 9;
    else if (radix <= 16)
        return 8;
    else if (radix <= 23)
        return 7;
    else if (radix <= 40)
        return 6;
            // The following are conservative, but we don't care.
    else if (radix <= 256)
        return 4;
    else
        return 1;
}

/** Count the number of leading zero bits in an int64_t. */
+ (int)count_leading_zeros:(int64_t)i {
    if (i == 0)
        return 32;
    int count = 0;
    for (int64_t k = 16; k > 0; k = k >> 1) {
        int64_t j = (int64_t) (i >> k);
        if (j == 0)
            count += k;
        else
            i = j;
    }
    return count;
}

+ (int64_t)set_str:(int64_t *)dest str:(int64_t *)str strLen:(int)str_len base:(int64_t)base {
    int64_t size = 0;
    if ((base & (base - 1)) == 0) {
        // The base is a power of 2.  Read the input string from
        // least to most significant character/digit.  */

        int64_t next_bitpos = 0;
        int64_t bits_per_indigit = 0;
        for (int64_t i = base; (i >>= 1) != 0;) bits_per_indigit++;
        int64_t res_digit = 0;

        for (int64_t i = str_len; --i >= 0;) {
            int64_t inp_digit = str[i];
            res_digit |= inp_digit << next_bitpos;
            next_bitpos += bits_per_indigit;
            if (next_bitpos >= 32) {
                dest[size++] = res_digit;
                next_bitpos -= 32;
                res_digit = ((int64_t) inp_digit) >> (bits_per_indigit - next_bitpos);
            }
        }

        if (res_digit != 0)
            dest[size++] = res_digit;
    }
    else {
        // General case.  The base is not a power of 2.
        int64_t indigits_per_limb = [MPN chars_per_word:base];
        int64_t str_pos = 0;

        while (str_pos < str_len) {
            int64_t chunk = str_len - str_pos;
            if (chunk > indigits_per_limb)
                chunk = indigits_per_limb;
            int64_t res_digit = str[str_pos++];
            int64_t big_base = base;

            while (--chunk > 0) {
                res_digit = res_digit * base + str[str_pos++];
                big_base *= base;
            }

            int64_t cy_limb;
            if (size == 0)
                cy_limb = res_digit;
            else {
                cy_limb = [MPN mul_1:dest x:dest len:size y:big_base];
                cy_limb += [MPN add_1:dest x:dest size:(int) size y:res_digit];
            }
            if (cy_limb != 0)
                dest[size++] = cy_limb;
        }
    }
    return size;
}

/** Compare x[0:size-1] with y[0:size-1], treating them as __uint64_tegers.
 * @result -1, 0, or 1 depending on if x&lt;y, x==y, or x&gt;y.
 * This is basically the same as gmp's mpn_cmp function.
 */
+ (int)cmp:(int64_t *)x y:(int64_t *)y size:(int64_t)size {
    while (--size >= 0) {
        int64_t x_word = x[size];
        int64_t y_word = y[size];
        if (x_word != y_word) {
            // Invert the high-order bit, because:
            // (unsigned) X > (unsigned) Y iff
            // (int64_t) (X^0x80000000) > (int64_t) (Y^0x80000000).
            int32_t vx = (int32_t) ((int64_t) x_word) ^ 0x80000000;
            int32_t vy = (int32_t) ((int64_t) y_word) ^ 0x80000000;
            return vx > vy ? 1 : -1;
        }
    }
    return 0;
}

/**
 * Compare x[0:xlen-1] with y[0:ylen-1], treating them as __uint64_tegers.
 *
 * @return -1, 0, or 1 depending on if x&lt;y, x==y, or x&gt;y.
 */
+ (int)cmp:(int64_t *)x xlen:(int64_t)xlen y:(int64_t *)y ylen:(int64_t)ylen {
    return xlen > ylen ? 1 : xlen < ylen ? -1 : [MPN cmp:x y:y size:xlen];
}


/**
    * Shift x[x_start:x_start+len-1] count bits to the "right"
    * (i.e. divide by 2**count).
    * Store the len least significant words of the result at dest.
    * The bits shifted out to the right are returned.
    * OK if dest==x.
    * Assumes: 0 &lt; count &lt; 32
    */
+ (int64_t)rshift:(int64_t *)dest x:(int64_t *)x x_start:(int)x_start len:(int)len count:(int)count {
    int64_t count_2 = 32 - count;
    int64_t low_word = (int32_t) x[x_start];
    int32_t retval = (int32_t) (low_word << count_2);
    int64_t i = 1;
    for (; i < len; i++) {
        int64_t high_word = (int32_t) x[x_start + i];
        dest[i - 1] = (int32_t) (((uint32_t) low_word) >> count | (((uint32_t) high_word) << count_2)) & 0xffffffff;
        low_word = high_word;
    }

    dest[i - 1] = (int64_t) (((uint32_t) low_word) >> count) & 0xffffffff;
    return retval;
}

/**
 * Shift x[x_start:x_start+len-1] count bits to the "right"
 * (i.e. divide by 2**count).
 * Store the len least significant words of the result at dest.
 * OK if dest==x.
 * Assumes: 0 &lt;= count &lt; 32
 * Same as rshift, but handles count==0 (and has no return value).
 */
+ (void)rshift0:(int64_t *)dest x:(int64_t *)x x_start:(int)x_start len:(int)len count:(int)count {
    if (count > 0)
        [MPN rshift:dest x:x x_start:x_start len:len count:count];
    else
        for (int i = 0; i < len; i++) {
            dest[i] = x[i + x_start];
        }
}

/** Return the int64_t-truncated value of right shifting.
* @param x a two's-complement "bignum"
* @param len the number of significant words in x
* @param count the shift count
* @return (int64_t)(x[0..len-1] &gt;&gt; count).
*/
+ (int64_t)rshift_long:(int64_t *)x len:(int)len count:(int)count {
    int wordno = count >> 5;
    count &= 31;
    int64_t sign = x[len - 1] < 0 ? -1 : 0;
    int64_t w0 = wordno >= len ? sign : x[wordno];
    wordno++;
    int64_t w1 = wordno >= len ? sign : x[wordno];
    if (count != 0) {
        wordno++;
        int64_t w2 = wordno >= len ? sign : x[wordno];
        w0 = (w0 >> count) | (w1 << (32 - count));
        w1 = (w1 >> count) | (w2 << (32 - count));
    }
    return ((int32_t) w1 << 32) | ((int32_t) w0 & 0xffffffffL);
}


/* Shift x[0:len-1] left by count bits, and store the len least
    * significant words of the result in dest[d_offset:d_offset+len-1].
    * Return the bits shifted out from the most significant digit.
    * Assumes 0 &lt; count &lt; 32.
    * OK if dest==x.
    */

+ (int64_t)lshift:(int64_t *)dest d_offset:(int64_t)d_offset x:(int64_t *)x len:(int64_t)len count:(int64_t)count {
    int count_2 = (int) (32 - count);
    int i = (int) (len - 1);
    int64_t high_word = x[i];
    int64_t retval = (int32_t) (((uint32_t) high_word) >> count_2);
    d_offset++;
    while (--i >= 0) {
        int64_t low_word = x[i];
        dest[d_offset + i] = (int32_t) ((((uint32_t) high_word) << count) | (((uint32_t) low_word) >> count_2)) & 0xffffffff;
        high_word = low_word;
    }
    dest[d_offset + i] = (((int32_t) high_word) << count) & 0xffffffff;
    return retval;
}

/** Return least i such that word &amp; (1&lt;&lt;i). Assumes word!=0. */

+ (int)findLowestBit:(int64_t)word {
    int i = 0;
    while ((word & 0xF) == 0) {
        word >>= 4;
        i += 4;
    }
    if ((word & 3) == 0) {
        word >>= 2;
        i += 2;
    }
    if ((word & 1) == 0)
        i += 1;
    return i;
}

/** Return least i such that words &amp; (1&lt;&lt;i). Assumes there is such an i. */

+ (int)findLowestBitInArr:(int64_t *)words {
    for (int i = 0; ; i++) {
        if (words[i] != 0)
            return 32 * i + [MPN findLowestBit:words[i]];
    }
    return 0;
}

/** Calculate Greatest Common Divisior of x[0:len-1] and y[0:len-1].
  * Assumes both arguments are non-zero.
  * Leaves result in x, and returns len of result.
  * Also destroys y (actually sets it to a copy of the result). */

+ (int64_t)gcd:(int64_t *)x y:(int64_t *)y len:(int)len {
    int i;
    int64_t word = 0;
    // Find sh such that both x and y are divisible by 2**sh.
    for (i = 0; ; i++) {
        word = x[i] | y[i];
        if (word != 0) {
            // Must terminate, since x and y are non-zero.
            break;
        }
    }
    int initShiftWords = i;
    int initShiftBits = [MPN findLowestBit:word];
    // Logically: sh = initShiftWords * 32 + initShiftBits

    // Temporarily devide both x and y by 2**sh.
    len -= initShiftWords;
    [MPN rshift0:x x:x x_start:initShiftWords len:len count:initShiftBits];
    [MPN rshift0:y x:y x_start:initShiftWords len:len count:initShiftBits];

    int64_t *odd_arg; /* One of x or y which is odd. */
    int64_t *other_arg; /* The other one can be even or odd. */
    if ((x[0] & 1) != 0) {
        odd_arg = x;
        other_arg = y;
    }
    else {
        odd_arg = y;
        other_arg = x;
    }

    for (; ;) {
        // Shift other_arg until it is odd; this doesn't
        // affect the gcd, since we divide by 2**k, which does not
        // divide odd_arg.
        for (i = 0; other_arg[i] == 0;) i++;
        if (i > 0) {
            int64_t j;
            for (j = 0; j < len - i; j++)
                other_arg[j] = other_arg[j + i];
            for (; j < len; j++)
                other_arg[j] = 0;
        }
        i = [MPN findLowestBit:other_arg[0]];
        if (i > 0)
            [MPN rshift:other_arg x:other_arg x_start:0 len:len count:i];

        // Now both odd_arg and other_arg are odd.

        // Subtract the smaller from the larger.
        // This does not change the result, since gcd(a-b,b)==gcd(a,b).
        i = [MPN cmp:odd_arg y:other_arg size:len];
        if (i == 0)
            break;
        if (i > 0) { // odd_arg > other_arg
            [MPN sub_n:odd_arg x:odd_arg y:other_arg size:len];
            // Now odd_arg is even, so swap with other_arg;
            int64_t *tmp = odd_arg;
            odd_arg = other_arg;
            other_arg = tmp;
        }
        else { // other_arg > odd_arg
            [MPN sub_n:other_arg x:other_arg y:odd_arg size:len];
        }
        while (odd_arg[len - 1] == 0 && other_arg[len - 1] == 0)
            len--;
    }
    if (initShiftWords + initShiftBits > 0) {
        if (initShiftBits > 0) {
            int64_t sh_out = [MPN lshift:x d_offset:initShiftWords x:x len:len count:initShiftBits];
            if (sh_out != 0)
                x[(len++) + initShiftWords] = sh_out;
        } else {
            for (i = len; --i >= 0;)
                x[i + initShiftWords] = x[i];
        }
        for (i = initShiftWords; --i >= 0;)
            x[i] = 0;
        len += initShiftWords;
    }
    return len;
}

+ (int)intLength:(int64_t)i {
    return 32 - [MPN count_leading_zeros:i < 0 ? ~i : i];
}

/** Calcaulte the Common Lisp "__int64_teger-length" function.
 * Assumes input is canonicalized:  len==Big__int64_teger.wordsNeeded(words,len) */
+ (int)intLength:(int64_t *)words len:(int64_t)len {
    len--;
//    while (words[len] == 0) len--;
    return (int) ([MPN intLength:words[len]] + 32 * len);
}

@end
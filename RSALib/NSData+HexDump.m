//
// Created by Stephan Bösebeck on 30.09.13.
// Copyright (c) 2013 Stephan Bösebeck. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSData+HexDump.h"


@implementation NSData (HexDump)

- (NSString *)hexDump:(BOOL)skip {
    NSString *c[] = {@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"A", @"B", @"C", @"D", @"E", @"F"};
    if (self.length == 0) {
        return c[0];
    }
    NSMutableString *ret = [[NSMutableString alloc] init];
    char *arc = self.bytes;
    for (long i = 0; i < self.length; i++) {
        char v = arc[i];
        int idx = v >> 4 & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

        idx = v & 0x0000000f;
        skip = (idx == 0) && skip;
        if (!skip)
            [ret appendString:c[idx]];

    }
    return ret;
}
@end
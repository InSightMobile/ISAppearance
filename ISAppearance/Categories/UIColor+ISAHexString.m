//
// 



#import "UIColor+ISAHexString.h"


@implementation UIColor (ISAHexString)

+ (UIColor *)colorWithHexString:(NSString *)hex {
    NSString *cString =
            [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return nil;
    }

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }

    if ([cString length] != 6) {
        return nil;
    }

    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    BOOL ok = YES;
    ok &= [[NSScanner scannerWithString:rString] scanHexInt:&r];
    ok &= [[NSScanner scannerWithString:gString] scanHexInt:&g];
    ok &= [[NSScanner scannerWithString:bString] scanHexInt:&b];

    if (!ok) {
        return nil;
    }

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

- (NSString *)hexString {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString = [NSString stringWithFormat:@"%02X%02X%02X", (int) (r * 255), (int) (g * 255), (int) (b * 255)];
    return hexString;
}

- (NSString *)hexStringWithAlpha {
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString = [NSString stringWithFormat:@"%02X%02X%02X%02X", (int) (r * 255), (int) (g * 255), (int) (b * 255), (int) (b * 255)];
    return hexString;
}

@end
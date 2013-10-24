//
// 



#import "UIColor+ISAObjectCreation.h"
#import "ISAppearance.h"


@implementation UIColor (ISAObjectCreation)

+ (UIColor *)colorWithHexString:(NSString *)hex
{
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


+ (id)colorWithString:(NSString *)node
{
    // try named colors
    SEL colorNameSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color", node]);

    if ([UIColor respondsToSelector:colorNameSelector]) {

        return [UIColor performSelector:colorNameSelector];
    }
    UIColor *cl = [self colorWithHexString:node];

    if (!cl) {
        UIImage *image = [[ISAppearance sharedInstance] loadImageNamed:node];
        if (image) {
            return [UIColor colorWithPatternImage:image];
        }
    }
    if (!cl) {
            cl = [UIColor whiteColor];
    }
    return cl;
}

+ (id)objectWithISANode:(id)node
{
    if ([node isKindOfClass:[NSString class]]) {

        UIColor *cl = [self colorWithString:node];
        if (cl) {
                    return cl;
        }
    }
    else if ([node isKindOfClass:[NSArray class]]) {

        float mod = 1;
        unsigned offset = 0;

        if ([node count] > 1) {
            if ([node[0] isKindOfClass:[NSString class]] && [node[0] isEqualToString:@"i"]) {
                mod = 1.0 / 255.0;
                offset = 1;
            }

            int count = [node count] - offset;

            if (count >= 4) {
                return [UIColor colorWithRed:[[node objectAtIndex:0 + offset] floatValue] * mod
                                       green:[[node objectAtIndex:1 + offset] floatValue] * mod
                                        blue:[[node objectAtIndex:2 + offset] floatValue] * mod
                                       alpha:[[node objectAtIndex:3 + offset] floatValue] * mod];
            }
            else if (count >= 3) {
                return [UIColor colorWithRed:[[node objectAtIndex:0 + offset] floatValue] * mod
                                       green:[[node objectAtIndex:1 + offset] floatValue] * mod
                                        blue:[[node objectAtIndex:2 + offset] floatValue] * mod
                                       alpha:1];
            }
            else if (count >= 2) {
                if ([node[0] isKindOfClass:[NSString class]]) {
                    UIColor *cl = [self colorWithString:node[0 + offset]];
                    if (cl) {
                        return [cl colorWithAlphaComponent:[node[1 + offset] floatValue] * mod];
                    }
                    else {
                        return [UIColor colorWithWhite:[[node objectAtIndex:0 + offset] floatValue] * mod
                                                 alpha:[[node objectAtIndex:1 + offset] floatValue] * mod];
                    }
                }
            }
        }
        else {
            [self colorWithString:node[0]];
        }
    }
    else if ([node isKindOfClass:[NSDictionary class]]) {
        NSDictionary *components = node;
        float alpha = 1.0f;
        if (components[@"alpha"]) {
            alpha = [components[@"alpha"] floatValue];
        }
        id hue = components[@"hue"];
        id saturation = components[@"saturation"];
        id brightness = components[@"brightness"];

        if (hue && saturation && brightness) {
            return [UIColor colorWithHue:[hue floatValue]
                              saturation:[saturation floatValue]
                              brightness:[brightness floatValue]
                                   alpha:alpha];
        }
    }
    return [UIColor whiteColor];
}


@end
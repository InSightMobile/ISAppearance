//
// 

#import "UIColorValueConverter.h"
#import "YKTag.h"

@interface UIColorValueConverter () <YKTagDelegate>
@end

@implementation UIColorValueConverter

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) return nil;

    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];

    if ([cString length] != 6) return  nil;

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
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


- (id)colorWithString:(NSString *)node
{
    // try named colors
    SEL colorNameSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color", node]);

    if ([UIColor respondsToSelector:colorNameSelector]) {

        return [UIColor performSelector:colorNameSelector];
    }

    return [self colorWithHexString:node];
}

- (id)createFromNode:(id)node
{
    if ([node isKindOfClass:[NSString class]]) {

        UIColor *cl = [self colorWithString:node];
        if (cl) return cl;
    }
    else if ([node isKindOfClass:[NSArray class]]) {
        if([node count] >= 4) {
            return [UIColor colorWithRed:[[node objectAtIndex:0] floatValue]
                                   green:[[node objectAtIndex:1] floatValue]
                                    blue:[[node objectAtIndex:2] floatValue]
                                   alpha:[[node objectAtIndex:3] floatValue]];
        }
        else if([node count] >= 3) {
            return [UIColor colorWithRed:[[node objectAtIndex:0] floatValue]
                                   green:[[node objectAtIndex:1] floatValue]
                                    blue:[[node objectAtIndex:2] floatValue]
                                   alpha:1];
        }
        if([node count] >= 2) {
            if ([node[0] isKindOfClass:[NSString class]]) {
                UIColor *cl = [self colorWithString:node];
                if (cl)
                    return [cl colorWithAlphaComponent:[node[1] floatValue]];
            }
        }
    }
    else if ([node isKindOfClass:[NSDictionary class]]) {


    }
    return [UIColor whiteColor];
}


@end
#import "NSString+YAMLKit.h"

@implementation NSString (YAMLKit)

- (NSInteger)intValueFromBase:(UInt8)base
{
    NSString *strippedString = [self stringByReplacingOccurrencesOfString:@"_" withString:@""];
    return ((NSInteger) strtol([[strippedString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] bytes],
            NULL, base));
}

@end

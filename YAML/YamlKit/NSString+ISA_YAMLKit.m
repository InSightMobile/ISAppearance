#import "NSString+ISA_YAMLKit.h"

@implementation NSString (ISA_YAMLKit)

- (NSInteger)isa_intValueFromBase:(UInt8)base
{
    NSString *strippedString = [self stringByReplacingOccurrencesOfString:@"_" withString:@""];
    return ((NSInteger) strtol([[strippedString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] bytes],
            NULL, base));
}

@end

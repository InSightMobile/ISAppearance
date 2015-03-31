#import "NSString+ISYAML.h"

@implementation NSString (ISYAML)

- (NSInteger)isyaml_intValueFromBase:(UInt8)base {
    NSString *strippedString = [self stringByReplacingOccurrencesOfString:@"_" withString:@""];
    return ((NSInteger) strtol([[strippedString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] bytes],
            NULL, base));
}

@end

//
// 

#import "UIFont+ISAObjectCreation.h"

@implementation UIFont (ISAObjectCreation)

+ (id)objectWithISANode:(id)param
{
    if([param isKindOfClass:[NSNumber class]]) {
        return [UIFont systemFontOfSize:[param floatValue]];
    }
    else if([param isKindOfClass:[NSString class]]) {
        CGFloat size = [param floatValue];
        if (size) {
            return [UIFont systemFontOfSize:size];
        }
    }
    if([param isKindOfClass:[NSArray class]]) {
        if([param count] < 2) return nil;
        NSString* name = [param objectAtIndex:0];
        NSNumber* size = [param objectAtIndex:1];

        if([name isEqualToString:@"system"])return [UIFont systemFontOfSize:[size floatValue]];
        else if([name isEqualToString:@"bold"])return [UIFont boldSystemFontOfSize:[size floatValue]];
        else return [UIFont fontWithName:name size:[size floatValue]];

    }
    return nil;
}


@end
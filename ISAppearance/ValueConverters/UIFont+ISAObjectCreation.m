//
// 

#import "UIFont+ISAObjectCreation.h"
#if ISA_CODE_GENERATION
#import "ISACode.h"
#endif

@implementation UIFont (ISAObjectCreation)

#if ISA_CODE_GENERATION
+ (id)codeWithISANode:(id)param
{
    if ([param isKindOfClass:[NSNumber class]]) {
        return [ISACode codeWithClass:[UIFont class] format:@"[UIFont systemFontOfSize:%@]",param];
    }
    else if ([param isKindOfClass:[NSString class]]) {
        CGFloat size = [param floatValue];
        if (size) {
            return [ISACode codeWithClass:[UIFont class] format:@"[UIFont systemFontOfSize:%@]",param];
        }
    }
    if ([param isKindOfClass:[NSArray class]]) {
        if ([param count] < 2) {
            return nil;
        }
        NSString *name = [param objectAtIndex:0];
        NSNumber *size = [param objectAtIndex:1];

        if ([name isEqualToString:@"system"]) {
            return [ISACode codeWithClass:[UIFont class] format:@"[UIFont systemFontOfSize:%@]",size];
        }
        else if ([name isEqualToString:@"bold"]) {
            return [ISACode codeWithClass:[UIFont class] format:@"[UIFont boldSystemFontOfSize:%@]",size];
        }
        else {
            return [ISACode codeWithClass:[UIFont class] format:@"[UIFont fontWithName:%@ size:%@]", [ISACode codeForString:name], size];
        }
    }
    return [ISACode codeForNil];
}
#endif

+ (id)objectWithISANode:(id)param
{
    if ([param isKindOfClass:[NSNumber class]]) {
        return [UIFont systemFontOfSize:[param floatValue]];
    }
    else if ([param isKindOfClass:[NSString class]]) {
        CGFloat size = [param floatValue];
        if (size) {
            return [UIFont systemFontOfSize:size];
        }
    }
    if ([param isKindOfClass:[NSArray class]]) {
        if ([param count] < 2) {
            return nil;
        }
        NSString *name = [param objectAtIndex:0];
        NSNumber *size = [param objectAtIndex:1];

        if ([name isEqualToString:@"system"]) {
            return [UIFont systemFontOfSize:[size floatValue]];
        }
        else if ([name isEqualToString:@"bold"]) {
            return [UIFont boldSystemFontOfSize:[size floatValue]];
        }
        else {
            return [UIFont fontWithName:name size:[size floatValue]];
        }

    }
    return nil;
}


@end
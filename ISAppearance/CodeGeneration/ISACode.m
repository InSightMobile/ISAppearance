//
//

#import "ISACode.h"


@interface ISACode ()
@end

@implementation ISACode
{

}
+ (instancetype)codeWithFormat:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);

    NSString* codeString =  [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);
    
    return [[self alloc] initWithCodeString:codeString];
}

- (instancetype)initWithCodeString:(NSString *)codeString
{
    self = [super init];
    if (self) {
        self.codeString = codeString;
    }

    return self;
}

+ (id)codeWithInvokation:(NSInvocation *)invocation keyPath:(NSString *)path selector:(SEL)sel arguments:(NSArray *)arguments
{
    NSMutableArray *argumentsCode = [NSMutableArray new];
    // decode arguments
    for (id argument in arguments) {
        [argumentsCode addObject:[self codeStringForObject:argument]];
    }

    NSArray *selectorComponents = [NSStringFromSelector(sel) componentsSeparatedByString:@":"];

    NSMutableArray *methodCode = [NSMutableArray new];

    for (int i = 0; i < argumentsCode.count; ++i) {

        [methodCode addObject:[NSString stringWithFormat:@"%@:",selectorComponents[i]]];
        [methodCode addObject:argumentsCode[i]];
    }

    return [self codeWithFormat:@"[object %@]",[methodCode componentsJoinedByString:@" "]];
}

+ (id)codeStringForObject:(id)argument
{
    if([argument isKindOfClass:[ISACode class]]) {
        return [(ISACode *) argument codeString] ?: @"[? EMPTY]";
    }
    if([argument isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@\"%@\"",argument];
    }
    if([argument isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",argument];
    }
    return [NSString stringWithFormat:@"[? %@]",argument];
}


- (NSString *)description
{
    return self.codeString ?: @"[? EMPTY]";
}


@end
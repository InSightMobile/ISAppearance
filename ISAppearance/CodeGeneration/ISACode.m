//
//

#import <objc/runtime.h>
#import "ISACode.h"
#import "ISAValueConverting.h"
#import "ISACodeManager.h"
#import "ISAStyleEntry.h"
#import "ISACodeEntry.h"


@interface ISACode ()
@property(nonatomic, copy) NSString *typeName;
@property(nonatomic, weak) ISACodeEntry *entry;
@end

@implementation ISACode
{

}

+ (instancetype)codeWithClass:(Class)codeClass format:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);

    NSString *codeString = [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);

    return [[self alloc] initWithClass:codeClass codeString:codeString];
}

+ (instancetype)codeWithClass:(Class)codeClass flags:(ISACodeFlags)flags format:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);

    NSString *codeString = [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);

    return [[self alloc] initWithClass:codeClass typeName:nil flags:flags codeString:codeString];
}

+ (instancetype)codeWithTypeName:(NSString *)typeName format:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);

    NSString *codeString = [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);

    return [[self alloc] initWithTypeName:typeName codeString:codeString];
}

+ (instancetype)codeWithFormat:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);

    NSString *codeString = [[NSString alloc] initWithFormat:format arguments:arguments];

    va_end(arguments);

    return [[self alloc] initWithCodeString:codeString];
}

- (NSString *)codeString
{
    return self.entry ? [NSString stringWithFormat:@"<?%@?>", self.entry.name] : self.sourceString;
}

- (void)setCodeClass:(Class)codeClass
{
    _codeClass = codeClass;
    [self registerCode];
}

- (instancetype)initWithTypeName:(NSString *)typeName codeString:(NSString *)codeString
{
    return [self initWithClass:nil typeName:typeName flags:0 codeString:codeString];
}

- (instancetype)initWithClass:(Class)cl typeName:(NSString *)typeName flags:(ISACodeFlags)flags codeString:(NSString *)codeString
{
    self = [super init];
    if (self) {
        _sourceString = codeString;
        _codeClass = cl;
        _typeName = typeName ?: (cl ?NSStringFromClass(cl) : nil);
        _flags = flags;

        [self registerCode];
    }
    return self;
}

- (instancetype)initWithClass:(Class)cl codeString:(NSString *)codeString
{
    return [self initWithClass:cl typeName:nil flags:0 codeString:codeString];
}

- (void)registerCode
{
    if(self.sourceString.length > 0 && !self.entry) {
        self.entry = [[ISACodeManager instance] registerCode:self];
    }
}

- (instancetype)initWithCodeString:(NSString *)codeString
{
    return [self initWithClass:nil codeString:codeString];
}

+ (NSString *)codeStringForObject:(id)argument
{
    if ([argument isKindOfClass:[ISACode class]]) {
        return [(ISACode *) argument sourceString] ?: @"[? EMPTY]";
    }
    if ([argument isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"@\"%@\"", argument];
    }
    if ([argument isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", argument];
    }
    return [NSString stringWithFormat:@"[? %@]", argument];
}


- (NSString *)description
{
    return self.codeString ?: @"[? EMPTY]";
}

- (NSString *)debugDescription
{
    return self.sourceString;
}


+ (ISACode *)codeForString:(NSString *)string
{
    return [[self alloc] initWithClass:[NSString class] codeString:[NSString stringWithFormat:@"@\"%@\"", string]];
}


+ (ISACode *)fixCodeForClass:(Class)pClass value:(id)value
{
    ISACode *baseCode = nil;

    if ([value isKindOfClass:[ISACode class]]) {

        baseCode = value;
    }
    else {
        return [[ISACode alloc] initWithClass:pClass codeString:[ISACode codeStringForObject:value]];
    }

    if (!baseCode.codeClass) {
        baseCode.codeClass = pClass;
    }
    return baseCode;
}

+ (id)fixCodeForTypeName:(NSString *)name value:(id)value
{
    ISACode *baseCode = nil;

    if ([value isKindOfClass:[ISACode class]]) {
        baseCode = value;
    }
    else {
        return [[ISACode alloc] initWithTypeName:name codeString:[ISACode codeStringForObject:value]];
    }

    if (!baseCode.typeName) {
        baseCode.typeName = name;
    }
    return baseCode;
}


+ (ISACode *)codeForBoxedObject:(id)argument
{
    ISACode *code = [self codeForObject:argument];

    if (code.codeClass == [NSNumber class]) {
        code = [ISACode codeWithFormat:@"@(%@)", code];
    }

    if (!code.codeClass && code.typeName.length > 0) {

        id <ISAValueConverting> converter = [ISAValueConverter converterNamed:code.typeName];

        ISACode *boxedCode = [converter boxedCodeWithISANode:code];
        if (boxedCode) {
            code = boxedCode;
        }
    }


    return code;
}

+ (ISACode *)codeForObject:(id)argument
{
    if ([argument isKindOfClass:[ISACode class]]) {
        return argument;
    }
    else if ([argument isKindOfClass:[NSString class]]) {
        return [ISACode codeForString:argument];
    }
    else if ([argument isKindOfClass:[NSNumber class]]) {
        return [ISACode codeForNumber:argument];
    }
    else if ([argument isKindOfClass:[NSArray class]]) {
        return [ISACode codeForArray:argument];
    }
    else if ([argument isKindOfClass:[NSDictionary class]]) {
        return [ISACode codeForDictionary:argument];
    }
    return [[ISACode alloc] initWithClass:[argument class] codeString:[ISACode codeStringForObject:argument]];
}

+ (ISACode *)codeForDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *code = [NSMutableArray new];

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [code addObject:[ISACode codeWithFormat:@"%@: %@", [ISACode codeForBoxedObject:key], [ISACode codeForBoxedObject:obj]].sourceString];
    }];

    return [ISACode codeWithClass:[NSDictionary class] format:@"@{%@}", [code componentsJoinedByString:@","]];
}

+ (ISACode *)codeForArray:(NSArray *)array
{
    NSMutableArray *code = [NSMutableArray new];

    for (id object in array) {
        [code addObject:[ISACode codeForBoxedObject:object].sourceString];
    }

    return [ISACode codeWithClass:[NSArray class] format:@"@[%@]", [code componentsJoinedByString:@","]];
}

+ (ISACode *)codeForNumber:(NSNumber *)argument
{
    return [[self alloc] initWithClass:[NSNumber class] codeString:argument.stringValue];
}


+ (id)codeForNil
{
    return [ISACode codeWithFormat:@"nil"];
}

+ (ISACode *)codeWithInvokation:(NSInvocation *)invocation target:(id)target keyPath:(NSString *)path selector:(SEL)sel arguments:(NSArray *)arguments
{
    ISACode *targetCode = nil;

    if (class_isMetaClass(object_getClass(target))) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-security"
        targetCode = [ISACode codeWithFormat:NSStringFromClass(target)];
#pragma clang diagnostic pop
    }
    else {
        targetCode = [ISACode codeForObject:target];
    }

    if (path) {
        targetCode = [ISACode codeWithFormat:@"%@.%@", targetCode, path];
    }


    NSMutableArray *argumentsCode = [NSMutableArray new];
    // decode arguments
    for (id argument in arguments) {
        [argumentsCode addObject:[self codeForObject:argument]];
    }

    NSArray *selectorComponents = [NSStringFromSelector(sel) componentsSeparatedByString:@":"];

    NSMutableArray *methodCode = [NSMutableArray new];

    for (int i = 0; i < argumentsCode.count; ++i) {

        ISACode *argument = argumentsCode[i];

        [methodCode addObject:[NSString stringWithFormat:@"%@:", selectorComponents[i]]];
        [methodCode addObject:argument.codeString];
    }

    return [self codeWithFormat:@"[%@ %@]", targetCode, [methodCode componentsJoinedByString:@" "]];
}

+ (id)codeWithInvokation:(NSInvocation *)invocation keyPath:(NSString *)path selector:(SEL)sel arguments:(NSArray *)arguments
{
    return [self codeWithInvokation:invocation target:[ISACode codeWithFormat:@"object"] keyPath:path selector:sel arguments:arguments];
}


+ (NSObject *)codeWithTypeName:(NSString *)string object:(id)object
{
    return [self codeForObject:object];
}


@end
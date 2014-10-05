//
// 



#import "ISAValueConverting.h"
#import "ISANSObjectValueConverter.h"
#import "ISAStyleEntry.h"
#import "ISAEnumValueConverter.h"
#import "ISAEnumClassValueConverter.h"
#import "ISAppearance+CodeGeneration.h"

@interface ISAValueConverter () <ISYAMLTagDelegate>

@property(nonatomic, copy) NSString *className;
@end

@implementation ISAValueConverter
{

}

+ (id<ISAValueConverting>)converterNamed:(NSString *)className
{
    NSMutableDictionary *convertersByName = [self convertersByName];
    ISAValueConverter* converter = convertersByName[className];
    if (converter) {
        return converter;
    }

    Class converterClass = [self converterClassForTypeName:className];
    if (converterClass) {
        converter = (ISAValueConverter*) [[converterClass alloc] init];
    }
    if (!converter) {
        NSString *enumerationClassName = [NSString stringWithFormat:@"%@Enum", className];
        Class enumClass = NSClassFromString(enumerationClassName);
        if (enumClass) {
            converter = [[ISAEnumClassValueConverter alloc] initWithObjectClass:enumClass];
        }
    }
    if (!converter) {
        Class cl = NSClassFromString(className);
        if (cl) {
            converter = [[ISANSObjectValueConverter alloc] initWithObjectClass:cl];
        }
        else if ([className isEqualToString:@"id"]) {
            converter = [[ISANSObjectValueConverter alloc] initWithObjectClass:[NSObject class]];
        }
    }

    if (converter) {
        converter.className = className;
        convertersByName[className] = converter;
    }

    return converter;
}

+ (Class)converterClassForTypeName:(NSString *)className
{
    NSString *converterClassName = [NSString stringWithFormat:@"ISA%@ValueConverter", className];
    Class converterClass = NSClassFromString(converterClassName);
    return converterClass;
}

- (id)tag:(ISYAMLTag *)tag processNode:(id)node extraInfo:(NSDictionary *)extraInfo
{
    if(ISA_IS_CODE_GENERATION_MODE) {
        return [ISACode fixCodeForTypeName:self.className value:[self codeWithISANode:node]];
    }
    return [self objectWithISANode:node];
}

- (id)tag:(ISYAMLTag *)tag castValue:(id)value fromTag:(ISYAMLTag *)castingTag
{
    if(ISA_IS_CODE_GENERATION_MODE) {
        id r = [ISACode fixCodeForTypeName:self.className value:[self codeWithISANode:value]];

        return r;
    }
    return [self objectWithISANode:value];
}

- (id)objectWithISANode:(id)node
{
    return nil;
}

- (id)codeWithISANode:(id)node
{
    return [self objectWithISANode:node];
}

- (id)boxedCodeWithISANode:(id)node
{
    return nil;
}


- (ISYAMLTag *)parsingTagForURI:(NSString *)uri
{
    return [[ISYAMLTag alloc] initWithURI:uri delegate:self];
}

+ (NSMutableDictionary *)convertersByName
{
    static NSMutableDictionary *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[NSMutableDictionary alloc] init];
    });
    return _instance;
}

+ (id)codeOfClass:(Class)pClass withISANode:(id)node
{
    id result = nil;
    if ([node isKindOfClass:[NSArray class]]) {
        if ([node count] > 0) {
            if ([node[0] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:0 selectorParams:nil];
                result = [entry codeWithTarget:pClass];
            }
            else if ([node count] > 1 && [node[1] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:1 selectorParams:nil];
                result = [entry codeWithTarget:node[0]];
            }
        }
    }
    if(result) {
        return [ISACode fixCodeForClass:pClass value:result];
    }
    return nil;
}

+ (id)objectOfClass:(Class)pClass withISANode:(id)node
{
    id result = nil;
    if ([node isKindOfClass:[NSArray class]]) {
        if ([node count] > 0) {
            if ([node[0] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:0 selectorParams:nil];
                result = [entry invokeWithTarget:pClass];
            }
            else if ([node count] > 1 && [node[1] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:1 selectorParams:nil];
                result = [entry invokeWithTarget:node[0]];
            }
        }
    }
    return result;
}


@end
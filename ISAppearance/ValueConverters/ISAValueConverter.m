//
// 



#import "ISAValueConverter.h"
#import "ISANSObjectValueConverter.h"
#import "ISAStyleEntry.h"

@interface ISAValueConverter () <YKTagDelegate>

@end

@implementation ISAValueConverter
{

}

+ (ISAValueConverter *)converterNamed:(NSString *)className
{
    NSMutableDictionary *convertersByName = [self convertersByName];
    ISAValueConverter *converter = convertersByName[className];
    if (converter) {
            return converter;
    }

    NSString *converterClassName = [NSString stringWithFormat:@"ISA%@ValueConverter", className];
    Class converterClass = NSClassFromString(converterClassName);
    if (converterClass) {
        converter = [[converterClass alloc] init];
    }
    else {
        Class cl = NSClassFromString(className);
        if (cl) {
            converter = [[ISANSObjectValueConverter alloc] initWithObjectClass:cl];
        }
        else if([className isEqualToString:@"id"]) {
            converter = [[ISANSObjectValueConverter alloc] initWithObjectClass:[NSObject class]];
        }
    }

    if (converter) {
        convertersByName[className] = converter;
    }

    return converter;
}

- (id)tag:(YKTag *)tag processNode:(id)node extraInfo:(NSDictionary *)extraInfo
{
    return [self objectWithISANode:node];
}

- (id)tag:(YKTag *)tag castValue:(id)value fromTag:(YKTag *)castingTag
{
    return [self objectWithISANode:value];
}

- (id)objectWithISANode:(id)node
{
    return nil;
}


- (YKTag *)parsingTagForURI:(NSString *)uri
{
    return [[YKTag alloc] initWithURI:uri delegate:self];
}

+ (NSMutableDictionary *)convertersByName
{
    static NSMutableDictionary *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^
    {
        _instance = [[NSMutableDictionary alloc] init];
    });
    return _instance;
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
            else if ([node[1] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:1 selectorParams:nil];
                result = [entry invokeWithTarget:node[0]];
            }
        }
    }
    return result;
}


@end
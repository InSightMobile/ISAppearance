//
// 



#import "ISAValueConverter.h"

@interface ISAValueConverter () <YKTagDelegate>

@end

@implementation ISAValueConverter
{

}

+ (ISAValueConverter *)converterNamed:(NSString *)className
{
    NSMutableDictionary *convertersByName = [self convertersByName];
    ISAValueConverter *converter = convertersByName[className];
    if (converter)return converter;

    className = [NSString stringWithFormat:@"ISA%@ValueConverter", className];
    Class cl = NSClassFromString(className);
    if (cl) {
        converter = [[cl alloc] init];
        convertersByName[className] = converter;
    }
    return converter;
}

- (id)tag:(YKTag *)tag castValue:(id)value fromTag:(YKTag *)castingTag
{
    return [self createFromNode:value];
}

- (id)createFromNode:(id)node
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
    dispatch_once(&pred, ^{
    _instance = [[NSMutableDictionary alloc] init];
});
    return _instance;
}


@end
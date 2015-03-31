//
// 



#import <objc/runtime.h>
#import "ISABaseEnum.h"

@interface ISABaseEnum ()

@end

@implementation ISABaseEnum
{

}

static void *valuesVar = 0;
static void *namesVar = 0;

+ (void)initialize
{
    if(self == [ISABaseEnum class]) {
        return;
    }

    NSDictionary *values = [self nameToValueMapping];
    NSMutableDictionary *names = [NSMutableDictionary dictionaryWithCapacity:values.count];
    [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        names[obj] = key;
    }];

    objc_setAssociatedObject(self, &valuesVar, values, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &namesVar, names, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSInteger)valueWithName:(NSString *)name
{
    NSDictionary *values = objc_getAssociatedObject(self, &valuesVar);

    NSNumber *value = values[name];
    return value ? value.integerValue : [self unknownValue];
}

+ (NSNumber *)numberWithName:(NSString *)name
{
    NSDictionary *values = objc_getAssociatedObject(self, &valuesVar);

    NSNumber *value = values[name];
    return value ? value : @([self unknownValue]);
}

+ (NSString *)nameWithValue:(NSInteger)value
{
    NSDictionary *names = objc_getAssociatedObject(self, &namesVar);

    return names[@(value)];
}

+ (NSInteger)unknownValue
{
    return 0;
}

+ (NSDictionary *)nameToValueMapping
{
    return @{};
}

@end
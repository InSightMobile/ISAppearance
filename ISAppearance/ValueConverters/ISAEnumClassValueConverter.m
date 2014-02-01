//
// 



#import "ISAEnumClassValueConverter.h"
#import "ISABaseEnum.h"


@interface ISAEnumClassValueConverter ()
@property(nonatomic, strong) Class objectClass;
@end

@implementation ISAEnumClassValueConverter
{

}

- (id)initWithObjectClass:(Class)objectClass
{
    self = [super init];
    if (self) {
        if ([objectClass respondsToSelector:@selector(numberWithName:)]) {
            self.objectClass = objectClass;
        }
        else {
            return nil;
        }
    }
    return self;
}

- (NSInteger)valueFromString:(NSString *)string
{
    NSUInteger result = 0;

    NSArray *values = [string componentsSeparatedByString:@"|"];

    for (NSString *strValue in values) {

        NSNumber *value = [self.objectClass numberWithName:strValue];

        if (value) {
            result |= value.intValue;
        }
        else {
            result |= string.integerValue;
        }
    }
    return result;
}

- (id)objectWithISANode:(id)node
{
    NSInteger result = [self getIntegerFromNode:node];
    return [NSNumber numberWithInt:result];
}

- (NSInteger)getIntegerFromNode:(id)node
{
    NSInteger result = 0;

    if ([node isKindOfClass:[NSString class]]) {
        result = [self valueFromString:node];
    }
    if ([node isKindOfClass:[NSNumber class]]) {
        result = [node integerValue];
    }
    else if ([node isKindOfClass:[NSArray class]]) {
        for (id obj in node) {
            result |= [self getIntegerFromNode:obj];
        }
    }
    return result;
}

@end
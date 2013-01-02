//
// 



#import "ISConverter.h"
#import "YKTag.h"

@interface ISConverter() <YKTagDelegate>

@end

@implementation ISConverter
{

}

+ (id)instance
{
    return nil;
}


- (id)tag:(YKTag *)tag castValue:(id)value fromTag:(YKTag *)castingTag
{
    return [self createFromNode:value];
}

- (id)createFromNode:(id)node
{
    return nil;
}


+ (YKTag *)parsingTagForURI:(NSString *)uri
{
    return [[YKTag alloc] initWithURI:uri delegate:[self instance]];
}

@end
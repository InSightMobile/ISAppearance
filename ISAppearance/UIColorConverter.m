//
// 

#import "UIColorConverter.h"
#import "YKTag.h"

@interface UIColorConverter () <YKTagDelegate>
@end

@implementation UIColorConverter
{

}

+ (UIColorConverter *)instance
{
    static UIColorConverter *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
    _instance = [[self alloc] init];
});
    return _instance;
}

- (id)createFromNode:(id)node
{
    if ([node isKindOfClass:[NSString class]]) {

        // try named colors
        SEL colorNameSelector = NSSelectorFromString([NSString stringWithFormat:@"%@Color",node]);

        if ([UIColor respondsToSelector:colorNameSelector]) {

            return [UIColor performSelector:colorNameSelector];
        }

    }
    else if ([node isKindOfClass:[NSArray class]]) {


    }
    else if ([node isKindOfClass:[NSDictionary class]]) {


    }
    return [UIColor whiteColor];
}


@end
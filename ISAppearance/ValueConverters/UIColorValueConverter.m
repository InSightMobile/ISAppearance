//
// 

#import "UIColorValueConverter.h"
#import "YKTag.h"

@interface UIColorValueConverter () <YKTagDelegate>
@end

@implementation UIColorValueConverter


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
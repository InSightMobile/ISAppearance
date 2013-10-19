//
// 


#import "ISAClassValueConverter.h"


@implementation ISAClassValueConverter
{

}

- (id)objectWithISANode:(id)node
{
    if([node isKindOfClass:[NSString class] ]) {
        return NSClassFromString(node);
    }
    return nil;
}

@end
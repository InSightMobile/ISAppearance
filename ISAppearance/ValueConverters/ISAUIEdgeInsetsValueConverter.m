//
// 



#import "ISAUIEdgeInsetsValueConverter.h"


@implementation ISAUIEdgeInsetsValueConverter
{

}

- (id)objectWithISANode:(id)node
{
    UIEdgeInsets insets = UIEdgeInsetsZero;

    if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 4) {
            insets =  UIEdgeInsetsMake([[node objectAtIndex:0] floatValue],
                                   [[node objectAtIndex:1] floatValue],
                                    [[node objectAtIndex:2] floatValue],
                                   [[node objectAtIndex:3] floatValue]);
        }
    }
    return [NSValue value:&insets withObjCType:@encode(UIEdgeInsets)];
}

@end
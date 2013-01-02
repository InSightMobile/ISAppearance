//
// 

#import "UIBarMetricsValueConverter.h"

@implementation UIBarMetricsValueConverter

- (id)createFromNode:(id)node
{
    UIBarMetrics value = UIBarMetricsDefault;
    if ([node isKindOfClass:[NSString class]]) {

        if ([node isEqualToString:@"UIBarMetricsDefault"])
            value = UIBarMetricsDefault;
        else if ([node isEqualToString:@"UIBarMetricsLandscapePhone"])
            value = UIBarMetricsLandscapePhone;
        else
            return nil;

        return [NSValue value:&value withObjCType:@encode(UIBarMetrics)];
    }
    return nil;
}


@end
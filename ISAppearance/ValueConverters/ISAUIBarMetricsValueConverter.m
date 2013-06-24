//
// 

#import "ISAUIBarMetricsValueConverter.h"

@implementation ISAUIBarMetricsValueConverter

- (id)init
{
    self = [super init];
    if (self) {
        self.mapping = @{
                @"UIBarMetricsDefault":@(UIBarMetricsDefault),
                @"UIBarMetricsLandscapePhone":@(UIBarMetricsLandscapePhone),

                @"default":@(UIBarMetricsDefault),
                @"landscapePhone":@(UIBarMetricsLandscapePhone),
                @"landscape":@(UIBarMetricsLandscapePhone),
        };
    }
    return self;
}


@end
//
// 

#import "ISAUIBarMetricsValueConverter.h"

@implementation ISAUIBarMetricsValueConverter

- (id)init {
    self = [super init];
    if (self) {
        self.mapping = @{
                @"UIBarMetricsDefault" : @(UIBarMetricsDefault),
                @"UIBarMetricsCompact" : @(UIBarMetricsCompact),

                @"default" : @(UIBarMetricsDefault),
                @"landscapePhone" : @(UIBarMetricsLandscapePhone),
                @"landscape" : @(UIBarMetricsLandscapePhone),

                @"Default" : @(UIBarMetricsDefault),
                @"Compact" : @(UIBarMetricsCompact),
                @"DefaultPrompt" : @(UIBarMetricsDefaultPrompt),
                @"CompactPrompt" : @(UIBarMetricsCompactPrompt),
        };
    }
    return self;
}


@end
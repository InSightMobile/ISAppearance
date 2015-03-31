//
// 

#import "ISAUIBarPositionValueConverter.h"

@implementation ISAUIBarPositionValueConverter

- (id)init {
    self = [super init];
    if (self) {
        self.mapping = @{

                @"UIBarPositionAny" : @(UIBarPositionAny),
                @"UIBarPositionBottom" : @(UIBarPositionBottom),
                @"UIBarPositionTop" : @(UIBarPositionTop),
                @"UIBarPositionTopAttached" : @(UIBarPositionTopAttached),

                @"any" : @(UIBarPositionAny),
                @"bottom" : @(UIBarPositionBottom),
                @"top" : @(UIBarPositionTop),
                @"topAttached" : @(UIBarPositionTopAttached),
        };
    }
    return self;
}


@end
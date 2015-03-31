//
//  ISAUIControlStateValueConverter.m
//  ISAppearance
//
//

#import "ISAUIControlStateValueConverter.h"

@interface ISAUIControlStateValueConverter ()

@end

@implementation ISAUIControlStateValueConverter

- (id)init {
    self = [super init];
    if (self) {
        self.mapping = @{
                @"UIControlStateNormal" : @(UIControlStateNormal),
                @"UIControlStateHighlighted" : @(UIControlStateHighlighted),
                @"UIControlStateSelected" : @(UIControlStateSelected),
                @"UIControlStateDisabled" : @(UIControlStateDisabled),

                @"normal" : @(UIControlStateNormal),
                @"highlighted" : @(UIControlStateHighlighted),
                @"selected" : @(UIControlStateSelected),
                @"disabled" : @(UIControlStateDisabled),
        };
    }
    return self;
}


@end

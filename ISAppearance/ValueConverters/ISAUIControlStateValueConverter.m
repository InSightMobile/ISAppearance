//
//  ISAUIControlStateValueConverter.m
//  ISAppearanceDemo
//
//  Created by yar on 19.01.13.
//  Copyright (c) 2013 infoshell. All rights reserved.
//

#import "ISAUIControlStateValueConverter.h"

@interface ISAUIControlStateValueConverter ()

@end

@implementation ISAUIControlStateValueConverter

- (id)init
{
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

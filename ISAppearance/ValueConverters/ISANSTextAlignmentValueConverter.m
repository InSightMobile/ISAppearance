//
// Created by Ярослав on 10.01.14.
// Copyright (c) 2014 yarryp. All rights reserved.
//

#import "ISANSTextAlignmentValueConverter.h"


@implementation ISANSTextAlignmentValueConverter
{

}

- (id)init
{
    self = [super init];
    if (self) {
        self.mapping = @{
                @"NSTextAlignmentLeft" : @(NSTextAlignmentLeft),
                @"NSTextAlignmentCenter" : @(NSTextAlignmentCenter),
                @"NSTextAlignmentRight" : @(NSTextAlignmentRight),
                @"NSTextAlignmentJustified" : @(NSTextAlignmentJustified),
                @"NSTextAlignmentNatural" : @(NSTextAlignmentNatural),

                @"default" : @(UIBarMetricsDefault),
                @"landscapePhone" : @(UIBarMetricsLandscapePhone),
                @"landscape" : @(UIBarMetricsLandscapePhone),

                @"left" : @(NSTextAlignmentLeft),
                @"center" : @(NSTextAlignmentCenter),
                @"right" : @(NSTextAlignmentRight),
                @"justified" : @(NSTextAlignmentJustified),
                @"natural" : @(NSTextAlignmentNatural),
        };
    }
    return self;
}

@end
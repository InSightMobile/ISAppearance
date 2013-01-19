//
//  ISAUIControlStateValueConverter.m
//  ISAppearanceDemo
//
//  Created by yar on 19.01.13.
//  Copyright (c) 2013 infoshell. All rights reserved.
//

#import "ISAUIControlStateValueConverter.h"

@implementation ISAUIControlStateValueConverter

- (id)createFromNode:(id)node
{
    UIControlState result = UIControlStateNormal;
    if ([node isKindOfClass:[NSString class]]) {

        NSArray *values = [node componentsSeparatedByString:@"|"];

        for (NSString *value in values) {

            if ([value isEqualToString:@"UIControlStateHighlighted"])
                result |= UIControlStateHighlighted;
            else if ([value isEqualToString:@"UIControlStateSelected"])
                result |= UIControlStateSelected;
            else if ([value isEqualToString:@"UIControlStateDisabled"])
                result |= UIControlStateDisabled;
                    // support common values
            else if ([value isEqualToString:@"highlighted"])
                result |= UIControlStateHighlighted;
            else if ([value isEqualToString:@"selected"])
                result |= UIControlStateSelected;
            else if ([value isEqualToString:@"disabled"])
                result |= UIControlStateDisabled;
        }
    }
    return [NSValue value:&result withObjCType:@encode(UIControlState)];
}


@end

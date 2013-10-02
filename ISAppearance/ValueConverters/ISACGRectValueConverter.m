//
// Created by Ярослав on 02.10.13.
// Copyright (c) 2013 yarryp. All rights reserved.
//


#import "ISACGRectValueConverter.h"


@implementation ISACGRectValueConverter
{

}

- (id)objectWithISANode:(id)node
{
    CGRect rect = CGRectZero;

    if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 4) {
            rect = CGRectMake([[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:1] floatValue],
                    [[node objectAtIndex:2] floatValue],
                    [[node objectAtIndex:3] floatValue]);
        }
        if ([node count] == 2) {
            rect = CGRectMake(0,
                    0,
                    [[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:1] floatValue]);
        }
        else if ([node count] == 1) {
            rect = CGRectMake(0,
                    0,
                    [[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:0] floatValue]);
        }
    }
    else if ([node isKindOfClass:[NSNumber class]]) {
        rect = CGRectMake(0,
                0,
                [node floatValue],
                [node floatValue]);
    }
    else if ([node isKindOfClass:[NSString class]]) {
        rect = CGRectMake(0,
                0,
                [node floatValue],
                [node floatValue]);
    }

    return [NSValue value:&rect withObjCType:@encode(CGRect)];
}

@end
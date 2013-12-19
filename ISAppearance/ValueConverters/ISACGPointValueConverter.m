//
//  ISACGSizeValueConverter.m
//  socials
//
//  Created by yar on 18.03.13.
//  Copyright (c) 2013 Ярослав. All rights reserved.
//

#import "ISACGPointValueConverter.h"

@implementation ISACGPointValueConverter

- (id)objectWithISANode:(id)node
{
    CGPoint point = CGPointZero;

    if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 2) {
            point = CGPointMake([[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:1] floatValue]);
        }
        else if ([node count] == 1) {
            point = CGPointMake([[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:0] floatValue]);
        }
    }
    else if ([node isKindOfClass:[NSNumber class]]) {
        point = CGPointMake([node floatValue],
                [node floatValue]);
    }
    else if ([node isKindOfClass:[NSString class]]) {
        point = CGPointMake([node floatValue],
                [node floatValue]);
    }

    return [NSValue value:&point withObjCType:@encode(CGPoint)];
}

@end

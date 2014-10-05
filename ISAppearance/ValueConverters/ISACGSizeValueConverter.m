//
//  ISACGSizeValueConverter.m
//  socials
//
//  Created by yar on 18.03.13.
//  Copyright (c) 2013 Ярослав. All rights reserved.
//

#import "ISACGSizeValueConverter.h"

@implementation ISACGSizeValueConverter

- (id)objectWithISANode:(id)node
{
    CGSize size = CGSizeZero;

    if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 2) {
            size = CGSizeMake([[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:1] floatValue]);
        }
        else if ([node count] == 1) {
            size = CGSizeMake([[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:0] floatValue]);
        }
    }
    else if ([node isKindOfClass:[NSNumber class]]) {
        size = CGSizeMake([node floatValue],
                [node floatValue]);
    }
    else if ([node isKindOfClass:[NSString class]]) {
        size = CGSizeMake([node floatValue],
                [node floatValue]);
    }

    return [NSValue value:&size withObjCType:@encode(CGSize)];
}

- (id)codeWithISANode:(id)node
{
    CGSize size = [[self objectWithISANode:node] CGSizeValue];
    return [ISACode codeWithFormat:@"CGSizeMake(%f,%f)", size.width, size.height];
}

@end

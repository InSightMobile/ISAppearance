//
//  ISAUIOffsetValueConverter.m
//  socials
//
//  Created by yar on 05.03.13.
//  Copyright (c) 2013 Ярослав. All rights reserved.
//

#import "ISAUIOffsetValueConverter.h"

#if ISA_CODE_GENERATION
#import "ISAValueConverter+CodeGeneration.h"
#endif

@implementation ISAUIOffsetValueConverter

- (id)objectWithISANode:(id)node {
    UIOffset insets = UIOffsetZero;

    if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 2) {
            insets = UIOffsetMake([[node objectAtIndex:0] floatValue],
                    [[node objectAtIndex:1] floatValue]);
        }
        else if ([node count] == 1) {
            insets = UIOffsetMake(0,
                    [[node objectAtIndex:0] floatValue]);
        }
    }
    else if ([node isKindOfClass:[NSNumber class]]) {
        insets = UIOffsetMake(0,
                [node floatValue]);
    }
    else if ([node isKindOfClass:[NSString class]]) {
        insets = UIOffsetMake(0,
                [node floatValue]);
    }

    return [NSValue value:&insets withObjCType:@encode(UIOffset)];
}

#if ISA_CODE_GENERATION
- (id)codeWithISANode:(id)node
{
    UIOffset offset = [[self objectWithISANode:node] UIOffsetValue];
    return [ISACode codeWithTypeName:@"UIOffset" format:@"UIOffsetMake(%f,%f)",offset.horizontal,offset.vertical];
}

- (id)boxedCodeWithISANode:(id)node
{
    return [ISACode codeWithFormat:@"[NSValue valueWithUIOffset:%@]",[ISACode codeWithTypeName:@"UIOffset" object:node]];
}
#endif

@end

//
//  ISACGColorValueConverter.m
//  socials
//
//  Created by yar on 19.01.13.
//  Copyright (c) 2013 Ярослав. All rights reserved.
//

#import "ISACGColorValueConverter.h"
#import "UIColor+ISAObjectCreation.h"


@implementation ISACGColorValueConverter
{

}

- (id)objectWithISANode:(id)node
{
    UIColor *color = [UIColor objectWithISANode:node];

    NSInvocation *invocation =
            [NSInvocation invocationWithMethodSignature:[color methodSignatureForSelector:@selector(CGColor)]];

    invocation.target = color;
    invocation.selector = @selector(CGColor);
    [invocation retainArguments];

    return invocation;
}

@end

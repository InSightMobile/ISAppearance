//
//  ISACGColorValueConverter.m
//  socials
//
//  Created by yar on 19.01.13.
//  Copyright (c) 2013 Ярослав. All rights reserved.
//

#import "ISACGColorValueConverter.h"
#import "ISAUIColorValueConverter.h"

@implementation ISACGColorValueConverter
{
    ISAUIColorValueConverter *_colorConverter;
}


- (id)init
{
    self = [super init];
    if (self) {
        _colorConverter = [ISAUIColorValueConverter new];
    }

    return self;
}

- (id)createFromNode:(id)node
{
    UIColor* color = [_colorConverter createFromNode:node];
    
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[color methodSignatureForSelector:@selector(CGColor)]];
       
    invocation.target = color;
    invocation.selector = @selector(CGColor);
    [invocation retainArguments];
    
    return invocation;
}

@end

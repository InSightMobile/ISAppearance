//
//

#import "ISACGColorValueConverter.h"
#import "UIColor+ISAObjectCreation.h"

#if ISA_CODE_GENERATION
#import "ISAValueConverter+CodeGeneration.h"
#endif


@implementation ISACGColorValueConverter {

}

- (id)objectWithISANode:(id)node {
    UIColor *color = [UIColor objectWithISANode:node];

    NSInvocation *invocation =
            [NSInvocation invocationWithMethodSignature:[color methodSignatureForSelector:@selector(CGColor)]];

    invocation.target = color;
    invocation.selector = @selector(CGColor);
    [invocation retainArguments];

    return invocation;
}

#if ISA_CODE_GENERATION
- (id)codeWithISANode:(id)node
{
    return [ISACode codeWithFormat:@"[%@ CGColor]", [UIColor codeWithISANode:node]];
}
#endif

@end

//
//

#import "ISACGColorValueConverter.h"
#import "UIColor+ISAObjectCreation.h"
#import "ISAppearance.h"
#import "NSObject+ISAppearance.h"



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

#ifdef ISA_CODE_GENERATION
- (id)codeWithISANode:(id)node
{
    return [ISACode codeWithFormat:@"[%@ CGColor]", [UIColor codeWithISANode:node]];
}
#endif

@end

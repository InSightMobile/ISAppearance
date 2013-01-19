//
// 

#import "UIButton+ISAppearance.h"
#import "UIImage+ISAppearance.h"

@implementation UIButton (ISAppearance)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    [self setBackgroundImage:[UIImage imageWithColor:color] forState:state];
}

@end
//
// 

#import <QuartzCore/QuartzCore.h>
#import "UIView+ISAppearance.h"

@implementation UIView (ISAppearance)

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius
{
    [self.layer setBorderColor: color.CGColor];
    [self.layer setBorderWidth: width];
    [self.layer setCornerRadius: radius];
    [self.layer setMasksToBounds: YES];
}

@end
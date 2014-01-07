//
//

#import "UIView+ISAppearance.h"
#import "UIView+isa_Injection.h"
#import "ISAppearance.h"


@implementation UIView (ISAppearance)

@dynamic isaClass;

- (void)isa_applyAppearance
{
    [self isa_setAppearanceApplied:@([[ISAppearance sharedInstance] applyAppearanceTo:self usingClasses:self.isaClass])];
}

- (void)isa_applyAppearanceWithSubviews:(BOOL)subviews
{
    [self isa_applyAppearance];
    if (subviews) {
        for (UIView *subview in self.subviews) {
            [subview isa_applyAppearanceWithSubviews:YES];
        }
    }
}


@end
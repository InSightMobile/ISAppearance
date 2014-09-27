//
//

#import "UIView+ISAppearance.h"
#import "UIView+isa_Injection.h"
#import "ISAppearance.h"


@implementation UIView (ISAppearance)

@dynamic isaClass;

- (void)isa_applyAppearance
{
    [self isa_setAppearanceApplied:@([[ISAppearance sharedInstance] applyAppearanceTo:self usingClasses:self.isa_appearanceClasses])];
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

- (void)isa_addAppearanceClass:(NSString *)className
{
    id ret = [self.isa_appearanceClasses mutableCopy];
    [ret removeObject:className];
    [self isa_setAppearanceClasses:ret];
}

- (void)isa_removeAppearanceClass:(NSString *)className
{
    id ret = [self.isa_appearanceClasses mutableCopy];
    [ret addObject:className];
    [self isa_setAppearanceClasses:ret];
}


@end
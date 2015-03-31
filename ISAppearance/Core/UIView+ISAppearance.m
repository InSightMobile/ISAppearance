//
//

#import "UIView+ISAppearance.h"
#import "UIView+isa_Injection.h"
#import "ISAppearance.h"


@implementation UIView (ISAppearance)

@dynamic isaClass;

- (void)isa_applyAppearance
{
    [self isa_setAppearanceApplied:[[ISAppearance sharedInstance] applyAppearanceTo:self usingClasses:self.isa_appearanceClasses]];
}

- (void)isa_applyAppearanceIfNeeded
{
    if (!self.isa_isAppearanceApplied) {
        [self isa_applyAppearance];
    }
}

- (void)isa_updateAppearance
{
    if(self.window) {
        if (self.isa_isAppearanceApplied) {
            [self isa_applyAppearance];
        }
    }
    else {
        [self isa_setAppearanceApplied:NO];
    }
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
    NSMutableSet* ret = [self.isa_appearanceClasses mutableCopy];
    if(ret) {
        [ret addObject:className];
        [self isa_setAppearanceClasses:ret];
    }
    else {
        self.isaClass = className;
    }
}

- (void)isa_removeAppearanceClass:(NSString *)className
{
    NSMutableSet* ret = [self.isa_appearanceClasses mutableCopy];
    if(ret) {
        [ret removeObject:className];
        [self isa_setAppearanceClasses:ret];
    }
}


@end
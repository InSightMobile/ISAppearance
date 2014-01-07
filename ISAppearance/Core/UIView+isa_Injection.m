#import <objc/runtime.h>
#import "UIView+isa_Injection.h"
#import "ISAppearance.h"
#import "NSObject+isa_Swizzle.h"

@implementation UIView (isa_Injection)

- (void)isaOverride_didMoveToWindow
{
    if (!self.isa_isAppearanceApplied) {
        [self isa_applyAppearance];
    }

    [self isaOverride_didMoveToWindow];
}

+ (void)isa_swizzleClass
{

    [self isa_swizzle:[UIView class]
                 from:@selector(didMoveToWindow)
                   to:@selector(isaOverride_didMoveToWindow)];

}


static void *isaClass = 0;
static void *isaIsApplied = 0;

- (void)setIsaClass:(NSString *)value
{
    objc_setAssociatedObject(self, &isaClass, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.isa_isAppearanceApplied) {
        [self isa_applyAppearance];
    }
}

- (NSString *)isaClass
{
    return objc_getAssociatedObject(self, &isaClass);
}

- (void)isa_setAppearanceApplied:(NSNumber *)value
{
    objc_setAssociatedObject(self, &isaIsApplied, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isa_isAppearanceApplied
{
    return objc_getAssociatedObject(self, &isaIsApplied);
}


@end
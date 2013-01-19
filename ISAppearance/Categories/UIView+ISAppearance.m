//
//

#import <objc/runtime.h>
#import "UIView+ISAppearance.h"
#import "ISAppearance.h"


@implementation UIView (ISAppearance)

- (void)isaOverride_didMoveToWindow
{
    if (!self.isaIsApplied) {
        [self applyISAppearance];
    }

    [self isaOverride_didMoveToWindow];
}

- (void)applyISAppearance
{
    self.isaIsApplied = @YES;
    [[ISAppearance sharedInstance] applyAppearanceTo:self usingClasses:self.isaClass];
}

static void* isaClass = 0;
static void* isaIsApplied = 0;

- (void)setIsaClass:(NSString *)value
{
    objc_setAssociatedObject(self, &isaClass, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)isaClass
{
    return objc_getAssociatedObject(self, &isaClass);
}

- (void)setIsaIsApplied:(NSNumber *)value
{
    objc_setAssociatedObject(self, &isaIsApplied, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isaIsApplied
{
    return objc_getAssociatedObject(self, &isaIsApplied);
}


@end
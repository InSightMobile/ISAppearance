#import <objc/runtime.h>
#import "UIView+isa_Injection.h"
#import "ISAppearance.h"
#import "NSObject+isa_Swizzle.h"

@implementation UIView (isa_Injection)

- (void)isaOverride_didMoveToWindow {
    if (!self.isa_isAppearanceApplied) {
        [self isa_applyAppearance];
    }

    [self isaOverride_didMoveToWindow];
}

+ (void)isa_swizzleClass {
    [self isa_swizzle:[UIView class]
                 from:@selector(didMoveToWindow)
                   to:@selector(isaOverride_didMoveToWindow)];
}


static void *isaClass = 0;
static void *isaClasses = 0;
static void *isaIsApplied = 0;

- (void)setIsaClass:(NSString *)value {
    objc_setAssociatedObject(self, &isaClass, value, OBJC_ASSOCIATION_COPY_NONATOMIC);

    NSSet *classes = [NSSet setWithArray:[value componentsSeparatedByString:@":"]];
    [self isa_setAppearanceClasses:classes];
}

- (NSSet *)isa_appearanceClasses {
    return objc_getAssociatedObject(self, &isaClasses);
}

- (void)isa_setAppearanceClasses:(NSSet *)value {
    NSSet *currentClass = objc_getAssociatedObject(self, &isaClasses);
    if (currentClass == value || (currentClass && value && [currentClass isEqualToSet:value])) {
        return;
    }
    objc_setAssociatedObject(self, &isaClasses, value, OBJC_ASSOCIATION_COPY_NONATOMIC);

    [self isa_updateAppearance];
}

- (NSString *)isaClass {
    return objc_getAssociatedObject(self, &isaClass);
}

- (void)isa_setAppearanceApplied:(BOOL)value {
    objc_setAssociatedObject(self, &isaIsApplied, @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isa_isAppearanceApplied {
    return [objc_getAssociatedObject(self, &isaIsApplied) boolValue];
}


@end
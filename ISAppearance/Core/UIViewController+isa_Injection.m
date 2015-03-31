//
// 



#import <objc/runtime.h>
#import "NSObject+isa_Swizzle.h"
#import "UIViewController+isa_Injection.h"
#import "ISAppearance.h"


@implementation UIViewController (isa_Injection)

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"

- (void)isaOverride_awakeFromNib {
    [self isa_applyAppearance];
    [self isaOverride_awakeFromNib];
}

- (void)isaOverride_viewDidLoad {
    if (self.isaClass) {
        [[ISAppearance sharedInstance] applyAppearanceTo:self usingClassesString:[@"OnLoad:" stringByAppendingString:self.isaClass]];
    }
    else {
        [[ISAppearance sharedInstance] applyAppearanceTo:self usingClassesString:@"OnLoad"];
    }

    [self isaOverride_viewDidLoad];
}

#pragma clang diagnostic pop


+ (void)isa_swizzleClass {

    [self isa_swizzle:[UIViewController class]
                 from:@selector(awakeFromNib)
                   to:@selector(isaOverride_awakeFromNib)];

    [self isa_swizzle:[UIViewController class]
                 from:@selector(viewDidLoad)
                   to:@selector(isaOverride_viewDidLoad)];

}


- (void)isa_applyAppearance {
    self.isaIsApplied = @([[ISAppearance sharedInstance] applyAppearanceTo:self usingClassesString:self.isaClass]);
}

- (void)isa_applyAppearanceWithSubviews:(BOOL)subviews {
    [self isa_applyAppearance];
    if (self.isViewLoaded) {
        [self.view isa_applyAppearanceWithSubviews:YES];
    }
}


static void *isaClass = 0;
static void *isaIsApplied = 0;

- (void)setIsaClass:(NSString *)value {
    objc_setAssociatedObject(self, &isaClass, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.isaIsApplied) {
        [self isa_applyAppearance];
    }
}

- (NSString *)isaClass {
    return objc_getAssociatedObject(self, &isaClass);
}

- (void)setIsaIsApplied:(NSNumber *)value {
    objc_setAssociatedObject(self, &isaIsApplied, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isaIsApplied {
    return objc_getAssociatedObject(self, &isaIsApplied);
}


@end
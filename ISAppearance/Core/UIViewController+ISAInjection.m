//
// 



#import <objc/runtime.h>
#import "NSObject+ISA_Swizzle.h"
#import "UIViewController+ISAInjection.h"
#import "ISAppearance.h"


@implementation UIViewController (ISAInjection)

#pragma clang diagnostic push
#pragma ide diagnostic ignored "InfiniteRecursion"

- (id)isaOverride_init
{
    id controller = [self isaOverride_init];
    [controller applyISAppearance];
    return controller;
}

- (id)isaOverride_initWithCoder:(NSCoder *)aDecoder;
{
    id controller = [self isaOverride_initWithCoder:aDecoder];
    [controller applyISAppearance];
    return controller;
}

- (void)isaOverride_awakeFromNib
{
    [self applyISAppearance];
    [self isaOverride_awakeFromNib];
}
#pragma clang diagnostic pop


+ (void)ISA_swizzleClass {

    [self ISA_swizzle:[UIViewController class]
                 from:@selector(awakeFromNib)
                   to:@selector(isaOverride_awakeFromNib)];

    /*
    [self ISA_swizzle:[UIViewController class]
             from:@selector(init)
               to:@selector(isaOverride_init)];


    [self ISA_swizzle:[UIViewController class]
                 from:@selector(initWithCoder:)
                   to:@selector(isaOverride_initWithCoder:)];
    */
}


- (void)applyISAppearance
{
    self.isaIsApplied = @([[ISAppearance sharedInstance] applyAppearanceTo:self usingClasses:self.isaClass]);
}

- (void)applyISAppearanceWithSubviews:(BOOL)subviews
{
    [self applyISAppearance];
    if(self.isViewLoaded) {
        [self.view applyISAppearanceWithSubviews:YES];
    }
}


static void* isaClass = 0;
static void* isaIsApplied = 0;

- (void)setIsaClass:(NSString *)value
{
    objc_setAssociatedObject(self, &isaClass, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.isaIsApplied) {
        [self applyISAppearance];
    }
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
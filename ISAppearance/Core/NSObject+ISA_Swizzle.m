//
// 



#import <objc/runtime.h>
#import "NSObject+ISA_Swizzle.h"


@implementation NSObject (ISA_Swizzle)


+ (void)ISA_swizzle:(Class)class from:(SEL)original to:(SEL)new
{
    Method originalMethod = class_getInstanceMethod(class, original);
    Method newMethod = class_getInstanceMethod(class, new);
    if (class_addMethod(class, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)ISA_swizzleFrom:(SEL)original to:(SEL)new
{
    [self ISA_swizzle:[self class] from:original to:new];
}


@end
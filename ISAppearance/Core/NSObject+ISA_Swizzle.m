//
// 



#import <objc/runtime.h>
#import "NSObject+isa_Swizzle.h"


@implementation NSObject (isa_Swizzle)


+ (void)isa_swizzle:(Class)class from:(SEL)original to:(SEL)new {
    Method originalMethod = class_getInstanceMethod(class, original);
    Method newMethod = class_getInstanceMethod(class, new);
    if (class_addMethod(class, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}


@end
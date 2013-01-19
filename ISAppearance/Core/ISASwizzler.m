//
// 



#import <objc/runtime.h>
#import "ISASwizzler.h"


@implementation ISASwizzler
{

    NSMutableSet *_swizzled;
}


- (id)init
{
    self = [super init];
    if (self) {
        _swizzled = [NSMutableSet set];
    }

    return self;
}

+ (ISASwizzler *)instance
{
    static ISASwizzler *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
    _instance = [[self alloc] init];
});
    return _instance;
}


- (void)swizzleAwakeFromNib:(Class)class
{
    [self swizzle:class methodName:@"awakeFromNib"];
}

- (void)swizzleDidMoveToWindow:(Class)class
{
    [self swizzle:class methodName:@"didMoveToWindow"];
}

- (BOOL)swizzle:(Class)class
{
    if ([_swizzled containsObject:class]) {
        return YES;
    }
    [_swizzled addObject:class];

    [self swizzleDidMoveToWindow:class];
    return YES;
}

- (void)swizzle:(Class)class methodName:(NSString *)methodName
{
    SEL originalMethod = NSSelectorFromString(methodName);
    SEL newMethod = NSSelectorFromString([NSString stringWithFormat:@"%@%@", @"isaOverride_", methodName]);
    [self swizzle:class from:originalMethod to:newMethod];
}

- (void)swizzle:(Class)class from:(SEL)original to:(SEL)new
{
    Method originalMethod = class_getInstanceMethod(class, original);
    Method newMethod = class_getInstanceMethod(class, new);
    if (class_addMethod(class, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end
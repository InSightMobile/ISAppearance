//
// 



#import <objc/runtime.h>
#import "ISAProxy.h"
#import "ISAppearance+Private.h"
#import "ISAStyleEntry.h"

@interface ISAProxy ()

@end

@implementation ISAProxy {

    Class _targetClass;
    NSString *_targetSelector;
}
+ (ISAProxy *)proxyForClass:(Class)pClass {
    return [self proxyForClass:pClass andSelector:nil];
}

+ (ISAProxy *)proxyForClass:(Class)pClass andSelector:(NSString *)selector {
    ISAProxy *proxy = [ISAProxy alloc];
    proxy->_targetClass = pClass;
    proxy->_targetSelector = selector;
    [[ISAppearance sharedInstance] registerProxy:proxy];
    return proxy;
}

- (void)dealloc {
    [[ISAppearance sharedInstance] unregisterProxy:self];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    Method method = class_getInstanceMethod(_targetClass, aSelector);
    return [NSMethodSignature signatureWithObjCTypes:method_getDescription(method)->types];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    ISAStyleEntry *entry = [ISAStyleEntry entryWithInvocation:invocation];
    [[ISAppearance sharedInstance] addStyleEntry:entry forClass:_targetClass andSelector:_targetSelector];
}


@end
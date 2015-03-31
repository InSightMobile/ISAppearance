//
// 



#import "NSObject+ISAppearance.h"
#import "ISAppearance.h"
#import "ISAStyleEntry.h"
#import "ISAProxy.h"
#import "ISAppearance+Private.h"


@implementation NSObject (ISAppearance)

+ (void)isa_appearanceWithBlock:(void (^)(id object))block {
    [self isa_appearanceForSelector:nil withBlock:block];
}

+ (void)isa_appearanceForSelector:(NSString *)selectors withBlock:(void (^)(id object))block {
    ISAStyleEntry *entry = [ISAStyleEntry entryWithBlock:block];
    [[ISAppearance sharedInstance] addStyleEntry:entry forClass:[self class] andSelector:selectors];
}

+ (instancetype)isa_appearance {
    return (id) [ISAProxy proxyForClass:self];
}

+ (instancetype)isa_appearanceForSelector:(NSString *)selector {
    return (id) [ISAProxy proxyForClass:self andSelector:selector];
}

- (void)isa_willApplyAppearance {

}

- (void)isa_didApplyAppearance {

}


@end
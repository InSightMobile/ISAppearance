//
// 



#import <Foundation/Foundation.h>

@interface NSObject (ISAppearance)

+ (void)isa_appearanceWithBlock:(void (^)(id object))block;

+ (void)isa_appearanceForSelector:(NSString *)class withBlock:(void (^)(id object))block;

+ (instancetype)isa_appearance;

+ (instancetype)isa_appearanceForSelector:(NSString *)selector;

- (void)isa_willApplyAppearance;
- (void)isa_didApplyAppearance;

@end
//
// 


#import <Foundation/Foundation.h>

@interface UIView (isa_Injection)

+ (void)isa_swizzleClass;


- (NSSet *)isa_appearanceClasses;

- (void)isa_setAppearanceClasses:(NSSet *)value;

- (void)isa_setAppearanceApplied:(NSNumber *)value;

- (NSNumber *)isa_isAppearanceApplied;

@end
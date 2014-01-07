//
// 


#import <Foundation/Foundation.h>

@interface UIView (isa_Injection)

+ (void)isa_swizzleClass;


- (void)isa_setAppearanceApplied:(NSNumber *)value;

- (NSNumber *)isa_isAppearanceApplied;

@end
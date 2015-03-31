//
// 



#import <Foundation/Foundation.h>

@interface NSObject (isa_Swizzle)
+ (void)isa_swizzle:(Class)class

from: (SEL)
original to:
(SEL)new;

@end
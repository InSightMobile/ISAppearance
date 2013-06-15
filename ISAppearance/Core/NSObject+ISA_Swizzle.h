//
// 



#import <Foundation/Foundation.h>

@interface NSObject (ISA_Swizzle)
+ (void)ISA_swizzle:(Class)class from:(SEL)original to:(SEL)new;

+ (void)ISA_swizzleFrom:(SEL)original to:(SEL)new;

+ (void)ISA_swizzleClass;
@end
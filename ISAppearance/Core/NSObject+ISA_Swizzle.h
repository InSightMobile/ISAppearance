//
// 



#import <Foundation/Foundation.h>

@interface NSObject (ISA_Swizzle)
+ (void)ISA_swizzle:(Class)class from:(SEL)original to:(SEL)new;

@end
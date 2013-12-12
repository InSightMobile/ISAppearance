//
// 


#import <Foundation/Foundation.h>

@interface UIView (ISAInjection)

+ (void)ISA_swizzleClass;


- (void)setIsaIsApplied:(NSNumber *)value;
- (NSNumber *)isaIsApplied;

@end
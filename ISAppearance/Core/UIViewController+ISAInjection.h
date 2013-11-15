//
// 



#import <Foundation/Foundation.h>

@interface UIViewController (ISAInjection)

@property(copy, nonatomic) NSString *isaClass;

+ (void)ISA_swizzleClass;

- (void)applyISAppearance;

- (void)applyISAppearanceWithSubviews:(BOOL)subviews;

@end
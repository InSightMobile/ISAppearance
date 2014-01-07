//
// 



#import <Foundation/Foundation.h>

@interface UIViewController (isa_Injection)

@property(copy, nonatomic) NSString *isaClass;

+ (void)isa_swizzleClass;

- (void)isa_applyAppearance;

- (void)isa_applyAppearanceWithSubviews:(BOOL)subviews;

@end
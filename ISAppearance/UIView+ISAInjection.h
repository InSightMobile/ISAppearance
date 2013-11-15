//
// 


#import <Foundation/Foundation.h>

@interface UIView (ISAInjection)

@property(copy, nonatomic) NSString *isaClass;

+ (void)ISA_swizzleClass;

- (void)applyISAppearance;

- (void)applyISAppearanceWithSubviews:(BOOL)subviews;

@end
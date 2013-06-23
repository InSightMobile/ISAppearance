//
// 


#import <Foundation/Foundation.h>

@interface UIView (ISAInjection)

@property(copy, nonatomic) NSString *isaClass;

- (void)applyISAppearance;

- (void)applyISAppearanceWithSubviews:(BOOL)subviews;

@end
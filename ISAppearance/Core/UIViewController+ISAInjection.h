//
// 



#import <Foundation/Foundation.h>

@interface UIViewController (ISAInjection)

@property(copy, nonatomic) NSString *isaClass;

- (void)applyISAppearance;

- (void)applyISAppearanceWithSubviews:(BOOL)subviews;

@end
//
//

#import <Foundation/Foundation.h>

@interface UIView (ISAppearance)

- (void)isa_applyAppearance;

- (void)isa_applyAppearanceWithSubviews:(BOOL)subviews;

@property(copy, nonatomic) NSString *isaClass;

@end
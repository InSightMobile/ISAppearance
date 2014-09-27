//
//

#import <Foundation/Foundation.h>

@interface UIView (ISAppearance)

- (void)isa_applyAppearance;

- (void)isa_applyAppearanceWithSubviews:(BOOL)subviews;

- (void)isa_addAppearanceClass:(NSString *)className;

- (void)isa_removeAppearanceClass:(NSString *)className;

@property(copy, nonatomic) NSString *isaClass;

@end
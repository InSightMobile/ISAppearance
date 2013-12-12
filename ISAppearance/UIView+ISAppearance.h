//
//

#import <Foundation/Foundation.h>

@interface UIView (ISAppearance)

- (void)setRotationAngle:(CGFloat)angle;

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius;

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius;

- (void)setShadowColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)setLayerImage:(UIImage *)image;

- (void)applyISAppearance;

- (void)applyISAppearanceWithSubviews:(BOOL)subviews;

@property(copy, nonatomic) NSString *isaClass;

@end
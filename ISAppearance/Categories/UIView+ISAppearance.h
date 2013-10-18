//
//

#import <Foundation/Foundation.h>

@interface UIView (ISAppearance)

- (void)setRetotionAngle:(CGFloat)angle;

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius;

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius;

- (void)setShadowColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)setLayerImage:(UIImage *)image;

@end
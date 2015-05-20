//
// 



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (ISABorders)
- (void)setRotationAngle:(CGFloat)angle;

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius;

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset radius:(CGFloat)radius;

- (void)setShadowColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

- (void)setLayerImage:(UIImage *)image;

- (void)setSeparatorImage:(UIImage *)image;
@end
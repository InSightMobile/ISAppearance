//
// 



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (ISAColor)
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

@end
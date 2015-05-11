//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (ISAColor)
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth borderRadius:(CGFloat)borderRadius;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderRadius:(CGFloat)borderRadius insets:(UIEdgeInsets)insets;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor underlineColor:(UIColor *)underlineColor underlineHeight:(CGFloat)underlineHeight insets:(UIEdgeInsets)insets;

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor frameColor:(UIColor *)frameColor underlineColor:(UIColor *)underlineColor underlineHeight:(CGFloat)underlineHeight insets:(UIEdgeInsets)insets;

+ (UIImage *)imageWithColor:(UIColor *)fillColor mask:(UIImage *)mask;
@end
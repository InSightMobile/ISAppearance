//
// 



#import "UIImage+ISAColor.h"
#import "UIDevice+isa_SystemInfo.h"

@implementation UIImage (ISAColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor
{
    CGFloat scale = [UIDevice isa_isRetina] ? 2 : 1;
    CGRect rect = CGRectMake(0, 0, 1+2, 1+2);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    [fillColor setFill];
    UIRectFill(rect);
    [borderColor setFill];
    UIRectFrame(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:1 topCapHeight:1];
}

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth
{
    NSInteger borderSpace = (NSInteger) ceil(borderWidth);

    CGFloat scale = [UIDevice isa_isRetina] ? 2 : 1;
    CGRect rect = CGRectMake(0, 0, 1+borderSpace*2, 1+borderSpace*2);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();;

    [fillColor setFill];
    [borderColor setStroke];
    UIRectFill(rect);

    CGContextStrokeRectWithWidth(context, rect, borderWidth);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:borderSpace topCapHeight:borderSpace];
}


@end
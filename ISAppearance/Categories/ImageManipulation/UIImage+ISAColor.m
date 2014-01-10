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

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
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

+ (UIImage *)stretchableImageWithFillColor:(UIColor *)fillColor borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth borderRadius:(CGFloat)borderRadius
{
    NSInteger borderSpace = (NSInteger) ceil(borderWidth);

    CGFloat scale = [UIDevice isa_isRetina] ? 2 : 1;
    CGRect rect = CGRectMake(0, 0, 1+borderSpace*2+borderRadius*2, 1+borderSpace*2+borderRadius*2);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();;

    [fillColor setFill];
    [borderColor setStroke];
    CGContextSetLineWidth(context, borderWidth);

    CGRect pathRect = CGRectInset(rect, borderWidth/2, borderWidth/2);

    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:pathRect cornerRadius:borderRadius];
    path.lineWidth = borderWidth;
    [path fill];
    [path stroke];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image stretchableImageWithLeftCapWidth:ceil(rect.size.width/2) topCapHeight:ceil(rect.size.height/2)];

}


@end
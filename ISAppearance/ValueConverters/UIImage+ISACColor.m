//
// 



#import "UIImage+ISACColor.h"
#import "UIDevice+isa_SystemInfo.h"

@implementation UIImage (ISACColor)

+ (UIImage *)isa_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
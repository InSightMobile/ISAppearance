//
// 

#import "UIImage+Gradient.h"

@implementation UIImage (Gradient)

+ (UIImage *)imageWithVerticalGradient:(NSArray *)colors height:(CGFloat)height {

    CGSize size = CGSizeMake(1, height);
    CGFloat scale = 1;

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextTranslateCTM(context, 0, size.height);
    //CGContextScaleCTM(context, 1.0, -1.0);

    // Create gradient
    NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];

    for (UIColor* color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();

    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)cgColors, NULL);


    // Apply gradient
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0, height), 0);

    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);

    return gradientImage;
}

@end
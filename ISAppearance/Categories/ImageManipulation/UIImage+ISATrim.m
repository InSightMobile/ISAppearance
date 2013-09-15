//
// 



#import "UIImage+ISATrim.h"


@implementation UIImage (ISATrim)

- (UIImage *)imageCroppedByRect:(CGRect)cropRect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)imageHorizontalStipFrom:(CGFloat)from height:(CGFloat)height
{
    return [self imageCroppedByRect:CGRectMake(0, from, self.size.width, height)];
}


@end
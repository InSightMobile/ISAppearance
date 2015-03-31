//
// 



#import "UIImage+ISATrim.h"


@implementation UIImage (ISATrim)

- (UIImage *)imageCroppedByRect:(CGRect)cropRect {
    CGFloat scale = self.scale;

    CGRect rect = cropRect;
    rect.origin.x *= scale;
    rect.origin.y *= scale;
    rect.size.width *= scale;
    rect.size.height *= scale;

    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}

- (UIImage *)imageHorizontalStipFrom:(CGFloat)from height:(CGFloat)height {
    return [self imageCroppedByRect:CGRectMake(0, from, self.size.width, height)];
}


@end
//
// 



#import "UIImage+ISAResize.h"


@implementation UIImage (ISAResize)

- (UIImage *)imageResizeToSize:(CGSize)size mode:(UIViewContentMode)mode quality:(CGInterpolationQuality)quality
{
    if(size.width == 0 || size.height == 0) {
        return [UIImage new];
    }

    CGFloat srcScale = self.scale;
    UIGraphicsBeginImageContextWithOptions(size,NO, 0);

    CGSize imageSize = self.size;


    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGRect srcRect;
    CGRect dstRect;

    CGFloat srcAspect = imageSize.width / imageSize.height;
    CGFloat dstAspect = size.width / size.height;

    UIImageOrientation orientation = self.imageOrientation;

    switch (mode) {
        case UIViewContentModeScaleAspectFill:

            if (srcAspect < dstAspect) {
                CGFloat height = imageSize.height * srcAspect / dstAspect;
                srcRect = CGRectMake(0, (imageSize.height - height) / 2, imageSize.width, height);
            }
            else {
                CGFloat width = imageSize.width * (dstAspect / srcAspect);
                srcRect = CGRectMake((imageSize.width - width) / 2, 0, width, imageSize.height);
            }
            dstRect = CGRectMake(0, 0, size.width, size.height);

            break;
        case UIViewContentModeScaleAspectFit:
            if (srcAspect > dstAspect) {
                CGFloat diff = (size.height - size.height * dstAspect / srcAspect);
                dstRect = CGRectMake(0, diff / 2, size.width, size.height - diff);
            }
            else {
                CGFloat diff = (size.width - size.width * srcAspect / dstAspect);
                dstRect = CGRectMake(diff / 2, 0, size.width - diff, size.height);
            }
            srcRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
            break;
        case UIViewContentModeScaleToFill:
        default:
            srcRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
            dstRect = CGRectMake(0, 0, size.width, size.height);
            break;
    }


    CGContextSetInterpolationQuality(context, quality);

    CGSize moveSize = size;
    CGPoint origin = CGPointMake(moveSize.width / 2, moveSize.height / 2);

    CGContextTranslateCTM(context, origin.x, origin.y);

    if (orientation == UIImageOrientationRight) {
        CGContextRotateCTM(context, -M_PI_2);
        // rotate rectangle
        srcRect = CGRectMake(srcRect.origin.y, srcRect.origin.x, srcRect.size.height, srcRect.size.width);
    } else if (orientation == UIImageOrientationLeft) {
        CGContextRotateCTM(context, M_PI_2);
        // rotate rectangle
        srcRect = CGRectMake(srcRect.origin.y, srcRect.origin.x, srcRect.size.height, srcRect.size.width);
    } else if (orientation == UIImageOrientationDown) {
        CGContextRotateCTM(context, M_PI);
    } else if (orientation == UIImageOrientationUp) {
        // no rotation
    }

    CGContextTranslateCTM(context, -origin.x, -origin.y);

    srcRect.origin.x *= srcScale;
    srcRect.origin.y *= srcScale;
    srcRect.size.width *= srcScale;
    srcRect.size.height *= srcScale;

    CGImageRef drawImage = CGImageCreateWithImageInRect([self CGImage], srcRect);
    CGContextDrawImage(context, dstRect, drawImage);
    CFRelease(drawImage);

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();


    NSLog(@"scaledImage = %f %f", scaledImage.size.width, scaledImage.scale);

    return scaledImage;
}


@end
//
// 



#import "UIImage+ISAResize.h"


@implementation UIImage (ISAResize)

- (UIImage *)imageResizeToSize:(CGSize)size mode:(UIViewContentMode)mode quality:(CGInterpolationQuality)quality
{
    UIGraphicsBeginImageContext(size);

    CGSize imageSize = self.size;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    CGRect srcRect;
    CGRect dstRect;

    CGFloat srcAspect = imageSize.width/imageSize.height;
    CGFloat dstAspect = size.width/size.height;

    switch (mode) {
        case UIViewContentModeScaleAspectFill:

            if(srcAspect < dstAspect) {
                CGFloat height = imageSize.height*srcAspect/dstAspect;
                srcRect = CGRectMake(0, (imageSize.height - height)/2, imageSize.width, height);
            }
            else {
                CGFloat width = imageSize.width*(dstAspect/srcAspect);
                srcRect = CGRectMake((imageSize.width - width)/2, 0, width, imageSize.height);
            }
            dstRect = CGRectMake(0, 0, size.width, size.height);

            break;
        case UIViewContentModeScaleAspectFit:
            if(srcAspect > dstAspect) {
                CGFloat diff = (size.height - size.height*dstAspect/srcAspect);
                dstRect = CGRectMake(0, diff/2, size.width, size.height-diff);
            }
            else {
                CGFloat diff = (size.width - size.width*srcAspect/dstAspect);
                dstRect = CGRectMake(diff/2, 0, size.width-diff, size.height);
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

    CGImageRef drawImage = CGImageCreateWithImageInRect([self CGImage], srcRect);
    CGContextDrawImage(context, dstRect, drawImage);
    CFRelease(drawImage);

    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return scaledImage;
}


@end
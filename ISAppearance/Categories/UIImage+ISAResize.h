//
// 



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (ISAResize)


- (UIImage *)imageResizeToSize:(CGSize)size mode:(UIViewContentMode)mode quality:(CGInterpolationQuality)quality;
@end
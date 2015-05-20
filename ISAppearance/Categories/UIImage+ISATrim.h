//
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (ISATrim)

- (UIImage *)imageCroppedByRect:(CGRect)cropRect;

- (UIImage *)imageHorizontalStipFrom:(CGFloat)from height:(CGFloat)height;

@end
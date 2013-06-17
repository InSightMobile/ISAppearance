//
// 

#import <QuartzCore/QuartzCore.h>
#import "UIView+ISAppearance.h"

@implementation UIView (ISAppearance)

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius
{
    [self.layer setBorderColor: color.CGColor];
    [self.layer setBorderWidth: width];
    [self.layer setCornerRadius: radius];
    [self.layer setMasksToBounds: YES];
}

- (void)setLayerImage:(UIImage *)image
{
    self.layer.contents = (id)image.CGImage;
}

- (void)setBackgroundViewImage:(UIImage *)image forKeyPath:(NSString *)keyPath;
{
    UIView *currentView = [self valueForKeyPath:keyPath];

    if([currentView isKindOfClass:[UIImageView class]]) {
        [(UIImageView*)currentView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self setValue:view forKeyPath:keyPath];
    }
}

- (void)setImageView:(UIImage *)image forKeyPath:(NSString *)keyPath;
{
    UIView *currentView = [self valueForKeyPath:keyPath];

    if([currentView isKindOfClass:[UIImageView class]]) {
        [(UIImageView*)currentView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        [self setValue:view forKeyPath:keyPath];
    }
}


@end
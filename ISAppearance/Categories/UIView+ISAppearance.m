//
//

#import "UIView+ISAppearance.h"

static NSString *const ISACellSeparatorLayerName = @"ISACellSeparatorLayer";
static NSString *const ISACellBackgroundLayerName = @"ISACellBackgroundLayer";
static NSString *const ISACellVerticalSeparatorLayerName = @"ISACellVerticalSeparatorLayer";


@implementation UIView (ISAppearance)

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width radius:(CGFloat)radius
{
    [self.layer setBorderColor:color.CGColor];
    [self.layer setBorderWidth:width];
    [self.layer setCornerRadius:radius];
    [self.layer setMasksToBounds:YES];
}

- (void)setLayerImage:(UIImage *)image
{
    self.layer.contents = (id) image.CGImage;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.contentsCenter = CGRectMake(
            image.capInsets.left / image.size.width,
            image.capInsets.top / image.size.height, (
                    image.size.width - image.capInsets.right - image.capInsets.left) /
                    image.size.width, (image.size.height - image.capInsets.bottom -
                    image.capInsets.top) / image.size.height);
}

- (void)setSeparatorImage:(UIImage *)image
{
    UIImageView *imageView = nil;

    for (UIView *subview in self.subviews) {

        if ([subview.layer.name isEqualToString:ISACellSeparatorLayerName]) {
            imageView = (UIImageView *) subview;
        }

    }
    if (!imageView) {
        CGRect frame = self.bounds;
        //frame.size.height += 1;
        imageView = [[UIImageView alloc] initWithFrame:frame];

        imageView.contentMode = UIViewContentModeBottom;

        imageView.frame = frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.layer.name = ISACellSeparatorLayerName;

        [self addSubview:imageView];
    }
    imageView.image = image;
}

- (void)setVerticalSeparatorImage:(UIImage *)image
{
    UIImageView *imageView = nil;

    for (UIView *subview in self.subviews) {

        if ([subview.layer.name isEqualToString:ISACellVerticalSeparatorLayerName]) {
            imageView = (UIImageView *) subview;
        }

    }
    if (!imageView) {
        CGRect frame = self.bounds;
        //frame.size.height += 1;
        imageView = [[UIImageView alloc] initWithFrame:frame];

        imageView.contentMode = UIViewContentModeRight;

        imageView.frame = frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.layer.name = ISACellVerticalSeparatorLayerName;

        [self addSubview:imageView];
    }
    imageView.image = image;
}

- (void)setBackgroundImage:(UIImage *)image
{
    UIImageView *imageView = nil;

    for (UIView *subview in self.subviews) {

        if ([subview.layer.name isEqualToString:ISACellBackgroundLayerName]) {
            imageView = (UIImageView *) subview;
        }
    }
    if (!imageView) {
        CGRect frame = self.bounds;
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.layer.name = ISACellBackgroundLayerName;

        [self addSubview:imageView];
        [self sendSubviewToBack:imageView];
    }
    imageView.image = image;
}

- (void)setBackgroundViewImage:(UIImage *)image forKeyPath:(NSString *)keyPath;
{
    UIView *currentView = [self valueForKeyPath:keyPath];

    if ([currentView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *) currentView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setValue:view forKeyPath:keyPath];
    }
}

- (void)setImageView:(UIImage *)image forKeyPath:(NSString *)keyPath;
{
    UIView *currentView = [self valueForKeyPath:keyPath];

    if ([currentView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *) currentView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        [self setValue:view forKeyPath:keyPath];
    }
}


@end
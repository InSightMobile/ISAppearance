//
// 

#import "UITableViewCell+ISAppearance.h"
#import "UIImage+ISAppearance.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const ISACellSeparatorLayerName = @"ISACellSeparatorLayer";

@implementation UITableViewCell (ISAppearance)

- (void)setBackgroundViewImage:(UIImage *)image
{
    if([self.backgroundView isKindOfClass:[UIImageView class]]) {
        [(UIImageView*)self.backgroundView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self setBackgroundView:view];
    }
}

- (void)setSelectedBackgroundViewImage:(UIImage *)image
{
    if([self.selectedBackgroundView isKindOfClass:[UIImageView class]]) {
        [(UIImageView*)self.selectedBackgroundView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self setSelectedBackgroundView:view];
    }
}

- (void)setBackgroundViewColor:(UIColor *)color
{
    [self setBackgroundViewImage:[UIImage imageWithColor:color]];
}

- (void)setSelectedBackgroundViewColor:(UIColor *)color
{
    [self setSelectedBackgroundViewImage:[UIImage imageWithColor:color]];
}

- (void)setSeparatorImage:(UIImage *)image
{
    UIImageView* imageView = nil;

    for (UIView * subview in self.subviews) {

        if([subview.layer.name isEqualToString:ISACellSeparatorLayerName]) {
            imageView = (UIImageView *) subview;
        }

    }
    if(!imageView) {
        CGRect frame = self.bounds;
        //frame.size.height += 1;
        imageView = [[UIImageView alloc] initWithFrame:frame];

        imageView.contentMode = UIViewContentModeBottom;

        imageView.frame = frame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        imageView.layer.name = ISACellSeparatorLayerName;

        [self addSubview:imageView];
    }
    imageView.image = image;
}

@end
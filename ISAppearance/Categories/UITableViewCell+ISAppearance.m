//
// 

#import "UITableViewCell+ISAppearance.h"
#import "UIImage+ISAColor.h"


@implementation UITableViewCell (ISAppearance)

- (void)setBackgroundViewImage:(UIImage *)image
{
    if ([self.backgroundView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *) self.backgroundView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setBackgroundView:view];
    }
}

- (void)setSelectedBackgroundViewImage:(UIImage *)image
{
    if ([self.selectedBackgroundView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *) self.selectedBackgroundView setImage:image];
    }
    else {
        UIImageView *view = [[UIImageView alloc] initWithImage:image];
        view.frame = self.bounds;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

@end
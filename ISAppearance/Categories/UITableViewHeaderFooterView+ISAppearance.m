//
// Created by Ярослав on 03.02.14.
// Copyright (c) 2014 yarryp. All rights reserved.
//

#import "UITableViewHeaderFooterView+ISAppearance.h"
#import "UIImage+ISAColor.h"


@implementation UITableViewHeaderFooterView (ISAppearance)

- (void)setBackgroundViewImage:(UIImage *)image {
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

- (void)setBackgroundViewColor:(UIColor *)color {
    [self setBackgroundViewImage:[UIImage imageWithColor:color]];
}


@end
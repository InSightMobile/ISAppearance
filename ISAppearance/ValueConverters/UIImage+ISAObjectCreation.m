//
// 

#import "UIImage+ISAObjectCreation.h"
#import "UIImage+ISAColor.h"
#import "ISAppearance+Private.h"
#import "ISAValueConverter.h"


@implementation UIImage (ISAObjectCreation)

+ (UIImage *)isaImageNamed:(NSString *)name
{
    return [[ISAppearance sharedInstance] loadImageNamed:name];
}

+ (id)objectWithISANode:(id)node
{
    UIImage *image = nil;
    if ([node isKindOfClass:[NSString class]]) {

        image = [self isaImageNamed:node];
        if (!image) {
            return [[UIImage alloc] init];
        }
        return image;
    }
    else if ([node isKindOfClass:[NSArray class]]) {

        image = [ISAValueConverter objectOfClass:self.class withISANode:node];
        if (image) {
            return image;
        }

        if ([node count] == 0) {
            return [UIImage new];
        }

        id firstParam = [node objectAtIndex:0];

        if ([firstParam isKindOfClass:[UIColor class]]) {
            image = [UIImage imageWithColor:firstParam];
        }
        else if ([firstParam isKindOfClass:[NSString class]]) {
            image = [self isaImageNamed:firstParam];
        }

        if ([node count] == 2) {

            id mode = [node objectAtIndex:1];
            if ([mode isKindOfClass:[NSValue class]]) {

                UIEdgeInsets insets;
                [mode getValue:&insets];
                image = [image resizableImageWithCapInsets:insets];
            }
        }
        else if ([node count] == 3) {

            image =
                    [image stretchableImageWithLeftCapWidth:[[node objectAtIndex:1] intValue]
                                               topCapHeight:[[node objectAtIndex:2] intValue]];

        }
        else if ([node count] == 5) {

            UIEdgeInsets insets =
                    UIEdgeInsetsMake(
                            [[node objectAtIndex:1] intValue],
                            [[node objectAtIndex:2] intValue],
                            [[node objectAtIndex:3] intValue],
                            [[node objectAtIndex:4] intValue]);

            image = [image resizableImageWithCapInsets:insets];
        }
    }
    if (!image) {
        image = [UIImage new];
    }
    return image;
}


@end
//
// 

#import "ISAUIImageValueConverter.h"
#import "UIImage+ISAppearance.h"


@implementation ISAUIImageValueConverter

- (id)createFromNode:(id)node
{
    UIImage *image = nil;
    if ([node isKindOfClass:[NSString class]]) {

        image = [UIImage imageNamed:node];
        if (!image) {
            return [[UIImage alloc] init];
        }
        return image;
    }
    else if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 0)return nil;

        id firstParam = [node objectAtIndex:0];

        if ([firstParam isKindOfClass:[NSString class]]) {

            image = [UIImage imageNamed:firstParam];

        }
        if ([firstParam isKindOfClass:[UIColor class]]) {
             image = [UIImage imageWithColor:firstParam];
        }
    }

    return image;
}

@end
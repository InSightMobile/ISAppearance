//
// 

#import "UIImageValueConverter.h"


@implementation UIImageValueConverter

- (id)createFromNode:(id)node
{
    if ([node isKindOfClass:[NSString class]]) {

        UIImage *image = [UIImage imageNamed:node];
        if (!image) {
            return [[UIImage alloc] init];
        }
        return image;
    }
    return nil;
}

@end
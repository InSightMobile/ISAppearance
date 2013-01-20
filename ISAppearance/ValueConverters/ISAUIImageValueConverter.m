//
// 

#import "ISAUIImageValueConverter.h"
#import "UIImage+ISAppearance.h"
#import "ISAppearance.h"

@implementation ISAUIImageValueConverter

- (UIImage*) imageNamed:(NSString*)name
{
    return [[ISAppearance sharedInstance] loadImageNamed:name];
    //[UIImage imageNamed:name];
}

- (id)createFromNode:(id)node
{
    UIImage *image = nil;
    if ([node isKindOfClass:[NSString class]]) {

        image = [self imageNamed:node];
        if (!image) {
            return [[UIImage alloc] init];
        }
        return image;
    }
    else if ([node isKindOfClass:[NSArray class]]) {

        if ([node count] == 0)return nil;

        id firstParam = [node objectAtIndex:0];

        if ([firstParam isKindOfClass:[UIColor class]]) {
             image = [UIImage imageWithColor:firstParam];
        }
        else if ([firstParam isKindOfClass:[NSString class]]) {

            image = [self imageNamed:firstParam];

        }

    }

    return image;
}

@end
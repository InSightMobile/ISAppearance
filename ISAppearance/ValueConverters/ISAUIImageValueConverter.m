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

        if([node count] == 2 ) {

            id mode = [node objectAtIndex:1];
            if([mode isKindOfClass:[NSValue class]]) {
                char const* type = [(NSValue *) mode objCType];

                UIEdgeInsets insets;
                [ mode getValue:&insets];
                image = [image resizableImageWithCapInsets:insets];
            }
        }
        else if([node count] == 3 ) {

            image =
                    [image stretchableImageWithLeftCapWidth:[[node objectAtIndex:1] intValue]
                                               topCapHeight:[[node objectAtIndex:2] intValue]];

        }
        else if([node count] == 5 ) {

            UIEdgeInsets insets =
                    UIEdgeInsetsMake(
                            [[node objectAtIndex:1] intValue],
                            [[node objectAtIndex:2] intValue],
                            [[node objectAtIndex:3] intValue],
                            [[node objectAtIndex:4] intValue]);

            image = [image resizableImageWithCapInsets:insets];
        }
    }
    if(!image) {
        image = [UIImage new];
    }
    return image;
}

@end
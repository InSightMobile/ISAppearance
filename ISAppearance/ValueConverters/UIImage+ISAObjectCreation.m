//
// 

#import <ISAppearance/ISAConfig.h>
#import "UIImage+ISAObjectCreation.h"
#import "UIImage+ISACColor.h"
#import "ISAValueConverter.h"
#import "ISAConfig+Private.h"

#if ISA_CODE_GENERATION
#import "ISAValueConverter+CodeGeneration.h"
#endif

@implementation UIImage (ISAObjectCreation)

+ (UIImage *)isaImageNamed:(NSString *)name {
    return [[ISAConfig sharedInstance] loadImageNamed:name];
}

#if ISA_CODE_GENERATION

+ (id)codeWithISANode:(id)node
{
    ISACode *image = nil;
    if ([node isKindOfClass:[NSString class]]) {
        return [ISACode codeWithClass:[UIImage class] flags:ISACodeCached format:@"[UIImage imageNamed:%@]", [ISACode codeForString:node]];
    }
    else if ([node isKindOfClass:[NSArray class]]) {

        image = [ISAValueConverter codeOfClass:self.class withISANode:node];
        if (image) {
            return [ISACode codeForObject:image];
        }

        if ([node count] == 0) {
            return [ISACode codeWithClass:[UIImage class] format:@"[UIImage new]"];
        }

        id firstParam = [node objectAtIndex:0];

        ISACode *firstCodeParam = [ISACode codeForObject:firstParam];

        if (firstCodeParam.codeClass == [UIColor class]) {
            image = [ISACode codeWithClass:[UIImage class] format:@"[UIImage imageWithColor:%@]", firstCodeParam];
        }
        else if (firstCodeParam.codeClass == [NSString class]) {
            image =
                    [ISACode codeWithClass:[UIImage class] flags:ISACodeCached format:@"[UIImage imageNamed:%@]", firstCodeParam];
        }

        if ([node count] == 2) {

            ISACode *secondCodeParam = [ISACode codeForObject:[node objectAtIndex:1]];

            if (secondCodeParam.codeClass == [NSString class]) {
                NSString *modeName = secondCodeParam.sourceString;
                if ([modeName isEqualToString:@"original"]) {
                    image =
                            [ISACode codeWithClass:[UIImage class] format:@"[%@ imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]]", image];
                }
                else if ([modeName isEqualToString:@"template"]) {
                    image =
                            [ISACode codeWithClass:[UIImage class] format:@"[%@ imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]]", image];
                }
            }
            else {
                image =
                        [ISACode codeWithClass:[UIImage class] format:@"[%@ resizableImageWithCapInsets:%@]", image, secondCodeParam];
            }
        }
        else if ([node count] == 3) {

            image = [ISACode codeWithClass:[UIImage class]
                                     flags:image.flags
                                    format:@"[%@ stretchableImageWithLeftCapWidth:%@ topCapHeight:%@]",
                                           image,
                                           [ISACode codeForObject:[node objectAtIndex:1]],
                                           [ISACode codeForObject:[node objectAtIndex:2]]];

        }
        else if ([node count] == 5) {

            image = [ISACode codeWithClass:[UIImage class]
                                     flags:image.flags
                                    format:@"[%@ resizableImageWithCapInsets:UIEdgeInsetsMake(%@,%@,%@,%@)]",
                                           image,
                                           [ISACode codeForObject:[node objectAtIndex:1]],
                                           [ISACode codeForObject:[node objectAtIndex:2]],
                                           [ISACode codeForObject:[node objectAtIndex:3]],
                                           [ISACode codeForObject:[node objectAtIndex:4]]];
        }
    }
    if (!image) {
        image = [ISACode codeWithFormat:@"[UIImage new]"];
    }
    return image;

}

#endif

+ (id)objectWithISANode:(id)node {
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
            image = [UIImage isa_imageWithColor:firstParam];
        }
        else if ([firstParam isKindOfClass:[NSString class]]) {
            image = [self isaImageNamed:firstParam];
        }

        if ([node count] == 2) {
            id mode = [node objectAtIndex:1];
            if ([mode isKindOfClass:[NSString class]]) {
                NSString *modeName = mode;
                if ([modeName isEqualToString:@"original"]) {
                    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                }
                else if ([modeName isEqualToString:@"template"]) {
                    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
            }
            if ([mode isKindOfClass:[NSValue class]]) {
                UIEdgeInsets insets;
                [mode getValue:&insets];
                image = [image resizableImageWithCapInsets:insets];
            }
        }
        else if ([node count] == 3) {
            image = [image stretchableImageWithLeftCapWidth:[[node objectAtIndex:1] intValue]
                                               topCapHeight:[[node objectAtIndex:2] intValue]];
        }
        else if ([node count] == 5) {
            UIEdgeInsets insets = UIEdgeInsetsMake(
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
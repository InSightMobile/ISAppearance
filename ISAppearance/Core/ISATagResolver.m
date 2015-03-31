//
// 



#import "ISATagResolver.h"
#import "ISAValueConverter.h"

@interface ISATagResolver ()

@end

@implementation ISATagResolver {

}

- (ISYAMLTag *)tagForURI:(NSString *)uri {
    if (uri.length < 1) {
        return nil;
    }

    ISYAMLTag *tag = nil;

    NSString *className = uri;

    if ([className characterAtIndex:0] == '!') {
        className = [className substringFromIndex:1];
    }
    ISAValueConverter *converter = [ISAValueConverter converterNamed:className];
    tag = [converter parsingTagForURI:uri];

    return tag;
}

@end
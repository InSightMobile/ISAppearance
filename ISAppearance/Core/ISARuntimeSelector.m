//
// 


#import "ISARuntimeSelector.h"
#import "ISAResponderRuntimeSelector.h"


@implementation ISARuntimeSelector
{

}

+ (id)selectorWithName:(NSString *)selector
{
    if([selector hasPrefix:@"!"]) {
        NSString *className = [selector substringFromIndex:1];
        return [[ISAResponderRuntimeSelector alloc] initWithClassName:className];
    }
    return nil;
}

@end
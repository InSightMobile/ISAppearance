//
// 


#import "ISARuntimeSelector.h"
#import "ISAResponderRuntimeSelector.h"
#import "ISAppearance+CodeGeneration.h"


@interface ISARuntimeSelector ()
@end

@implementation ISARuntimeSelector
{

}

+ (id)selectorWithName:(NSString *)name
{
    if([name hasPrefix:@"!"]) {
        NSString *className = [name substringFromIndex:1];
        ISARuntimeSelector* runtimeSelector = [[ISAResponderRuntimeSelector alloc] initWithClassName:className];

        if(ISA_IS_CODE_GENERATION_MODE) {
            runtimeSelector.name = name;
        }
        return runtimeSelector;
        
    }
    return nil;
}

@end
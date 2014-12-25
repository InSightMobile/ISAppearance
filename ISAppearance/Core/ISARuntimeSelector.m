//
// 


#import "ISARuntimeSelector.h"
#import "ISAResponderRuntimeSelector.h"

#if ISA_CODE_GENERATION
#import "ISAppearance+CodeGeneration.h"
#endif



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

#if ISA_CODE_GENERATION
        if(ISA_IS_CODE_GENERATION_MODE) {
            runtimeSelector.name = name;
        }
#endif
        return runtimeSelector;
        
    }
    return nil;
}

@end
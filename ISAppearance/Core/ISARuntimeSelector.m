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
        NSString *selectorName = [name substringFromIndex:1];

        BOOL negative = NO;

        if([selectorName hasPrefix:@"~"]) {
            selectorName = [selectorName substringFromIndex:1];
            negative = YES;
        }

        ISARuntimeSelector* runtimeSelector = [[ISAResponderRuntimeSelector alloc] initWithClassName:selectorName negative:negative];

#if ISA_CODE_GENERATION
        if(ISA_IS_CODE_GENERATION_MODE) {
            runtimeSelector.name = name;
        }
#endif
        return runtimeSelector;
        
    }
    return nil;
}

- (BOOL)isApplyableTo:(id)target {
    return NO;
}


@end
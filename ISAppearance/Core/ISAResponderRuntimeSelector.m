//
// 



#import "ISAResponderRuntimeSelector.h"

@interface ISAResponderRuntimeSelector ()

@end

@implementation ISAResponderRuntimeSelector
{

    Class _targetClass;
}

- (BOOL)isApplyableTo:(id)target
{
    if([target isKindOfClass:[UIResponder class]]) {

        UIResponder* responder = target;

        while(responder) {

            if([responder isKindOfClass:_targetClass]) {
                return YES;
            }
            responder = responder.nextResponder;
        }
        return NO;
    }
    return NO;
}

- (id)initWithClassName:(NSString *)className
{
    self = [super init];
    if(self) {
        _targetClass = NSClassFromString(className);
    }
    return self;
}


@end
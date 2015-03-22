//
// 



#import "ISAResponderRuntimeSelector.h"

@interface ISAResponderRuntimeSelector ()

@end

@implementation ISAResponderRuntimeSelector
{
    BOOL _negative;
    Class _targetClass;
}

- (BOOL)isApplyableTo:(id)target
{
    if([target isKindOfClass:[UIResponder class]]) {
        UIResponder* responder = target;
        while(responder) {
            if([responder isKindOfClass:_targetClass]) {
                return !_negative;
            }
            responder = responder.nextResponder;
        }
        return _negative;
    }
    return _negative;
}

- (id)initWithClassName:(NSString *)className negative:(BOOL)negative;
{
    self = [super init];
    if(self) {
        _negative = negative;
        _targetClass = NSClassFromString(className);
    }
    return self;
}


@end
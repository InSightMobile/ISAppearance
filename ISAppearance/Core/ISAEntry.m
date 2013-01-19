//
// 


#import "ISAEntry.h"


@interface ISAEntry ()
@property(nonatomic, copy) NSArray *parameters;
@property(nonatomic) SEL selector;
@property(nonatomic, copy) NSString *keyPath;
@end

@implementation ISAEntry
{

}

- (id)initWithSelector:(SEL)selector parameters:(NSArray *)parameters keyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        self.selector = selector;
        self.parameters = parameters;
        self.keyPath = keyPath;
    }
    return self;
}

+ (id)entryWithSelector:(SEL)selector parameters:(NSArray *)parameters keyPath:(NSString *)keyPath
{
    return [[ISAEntry alloc] initWithSelector:selector parameters:parameters keyPath:keyPath];
}

- (void)invokeWithTarget:(id)rootTarget
{
    id target;
    if (_keyPath) {
        @try {
             target = [rootTarget valueForKeyPath:_keyPath];
        }
        @catch (NSException *exception) {
            NSLog(@"exception = %@", exception);
            return;
        }
    }
    else {
        target = rootTarget;
    }
    if (!target) return;

    NSMethodSignature *signature = [target methodSignatureForSelector:_selector];
    if (!signature)return;

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = _selector;

    void *buffer = malloc([invocation.methodSignature frameLength]);
    
    NSMethodSignature* methodSignature = invocation.methodSignature;

    int argumentPos = 2;
    for (id argument in _parameters) {
        
        char const *expectedType = [methodSignature getArgumentTypeAtIndex:argumentPos];
        
        if([argument isKindOfClass:[NSInvocation class]]) {
            
            NSInvocation* argumentInvocation = argument;
                            
            if (strcmp(argumentInvocation.methodSignature.methodReturnType, expectedType) == 0)
            {
                [argumentInvocation invoke];
                [argumentInvocation getReturnValue:buffer];
                [invocation setArgument:buffer atIndex:argumentPos];
            }
            else {
                return;
            }
        }
        else if (strcmp(@encode(id), expectedType) == 0) {
            __autoreleasing id obj = argument;
            [invocation setArgument:&obj atIndex:argumentPos];
        }
        else if ([argument isKindOfClass:[NSNumber class]]) {            
            if (strcmp(@encode(float), expectedType) == 0) {
                float value = [argument floatValue];
                [invocation setArgument:&value atIndex:argumentPos];
            }
            else if (strcmp(@encode(NSInteger), expectedType) == 0) {
                NSInteger value = [argument integerValue];
                [invocation setArgument:&value atIndex:argumentPos];
            }
            else if (strcmp(@encode(BOOL), expectedType) == 0) {
                BOOL value = [argument boolValue];
                [invocation setArgument:&value atIndex:argumentPos];
            }
            else if (strcmp(@encode(double), expectedType) == 0) {
                double value = [argument doubleValue];
                [invocation setArgument:&value atIndex:argumentPos];
            }

            else if (strcmp(@encode(NSUInteger), expectedType) == 0) {
                NSUInteger value = [argument unsignedIntegerValue];
                [invocation setArgument:&value atIndex:argumentPos];
            }

            else { // general NSValue
                
                char const *type = [(NSValue *) argument objCType];                
                if (strcmp(type, expectedType) == 0) {
                    [(NSValue *) argument getValue:buffer];
                    [invocation setArgument:buffer atIndex:argumentPos];
                }
                else {
                    return;
                }
            }
        }
        else if ([argument isKindOfClass:[NSValue class]]) {
            
            char const *type = [(NSValue *) argument objCType];
            
            if (strcmp(type, expectedType) == 0) {
                [(NSValue *) argument getValue:buffer];
                [invocation setArgument:buffer atIndex:argumentPos];
            }
            else {
                return;
            }
        }
        else {
            return;
        }
        argumentPos++;
    }
    free(buffer);
    [invocation invoke];
}


@end
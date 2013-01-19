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

- (void)invokeWithTarget:(id)target
{
    if (_keyPath) {
        target = [target valueForKeyPath:_keyPath];
    }
    if (!target) return;

    NSMethodSignature *signature = [target methodSignatureForSelector:_selector];
    if (!signature)return;

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    invocation.selector = _selector;

    void *buffer = malloc([invocation.methodSignature frameLength]);

    int argumentPos = 2;
    for (id argument in _parameters) {

        char const *expectedType = [invocation.methodSignature getArgumentTypeAtIndex:argumentPos];
        if (strcmp(@encode(id), expectedType) == 0) {
            __autoreleasing id obj = argument;
            [invocation setArgument:&obj atIndex:argumentPos];
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
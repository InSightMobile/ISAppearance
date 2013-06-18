//
// 


#import "ISAStyleEntry.h"


@interface ISAStyleEntry ()
@end

@implementation ISAStyleEntry
{
@private
    NSInvocation *_invocation;
    NSArray *_arguments;
    SEL _selector;
    NSString *_keyPath;

    void (^_block)(id);
}

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        _selector = selector;
        _arguments = [arguments copy];
        _keyPath = [keyPath copy];
    }
    return self;
}

- (id)initWithBlock:(void (^)(id))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

+ (id)entryWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath
{
    return [[ISAStyleEntry alloc] initWithSelector:selector arguments:arguments keyPath:keyPath];
}

- (void)safeInvokeWithTarget:(id)target
{
    if(_block) {
        _block(target);
    }
    if(_invocation) {
        @try {
            [_invocation invokeWithTarget:target];
        }
        @catch (NSException *exception) {
            NSLog(@"invocation failed with selector %@  for %@", NSStringFromSelector(_selector), [target class]);
            return;
        }
    }
}

+ (id)entryWithBlock:(void (^)(id object))block
{
    return [[ISAStyleEntry alloc] initWithBlock:block];
}

- (void)invokeWithTarget:(id)rootTarget
{
    id target = nil;
    if (_keyPath) {
        @try {
            target = [rootTarget valueForKeyPath:_keyPath];
        }
        @catch (NSException *exception) {
            NSLog(@"invalid key path \"%@\" for %@", _keyPath, [rootTarget class]);
            return;
        }
    }
    else {
        target = rootTarget;
    }
    if (!target) return;

    // use cashed invocation
    if (_invocation) {
        [self safeInvokeWithTarget:target];
        return;
    }

    NSMethodSignature *signature = [target methodSignatureForSelector:_selector];
    if (!signature) {
        NSLog(@"invalid selector \"%@\" for %@", NSStringFromSelector(_selector), [rootTarget class]);
        return;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = _selector;

    void *buffer = malloc([invocation.methodSignature frameLength]);

    NSMethodSignature *methodSignature = invocation.methodSignature;

    int argumentPos = 2;
    for (id argument in _arguments) {

        char const *expectedType = [methodSignature getArgumentTypeAtIndex:argumentPos];

        if ([argument isKindOfClass:[NSInvocation class]]) {

            NSInvocation *argumentInvocation = argument;

            if (strcmp(argumentInvocation.methodSignature.methodReturnType, expectedType) == 0) {
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
    [invocation retainArguments];
    _invocation = invocation;
    [self safeInvokeWithTarget:target];
}


@end
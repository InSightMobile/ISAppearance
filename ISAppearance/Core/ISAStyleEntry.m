//
// 


#import "ISAStyleEntry.h"

static NSString *SelectorNameForSetterWithString(NSString *string) {
    NSString *sel = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                    withString:[[string substringToIndex:1] uppercaseString]];

    return [NSString stringWithFormat:@"set%@", sel];
}


static SEL SelectorForPropertySetterFromString(NSString *string) {

    NSString *sel = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                    withString:[[string substringToIndex:1] uppercaseString]];

    return NSSelectorFromString([NSString stringWithFormat:@"set%@:", sel]);
}

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

- (id)safeInvokeWithTarget:(id)target
{
    if (_block) {
        _block(target);
        return nil;
    }
    if (_invocation) {
        @try {
            [_invocation invokeWithTarget:target];
            return [self getReturnValue];
        }
        @catch (NSException *exception) {
            NSLog(@"invocation failed with selector %@  for %@", NSStringFromSelector(_selector), [target class]);
            return nil;
        }
    }
    return nil;
}

- (id)getReturnValue
{
    if (strcmp(_invocation.methodSignature.methodReturnType, @encode(id)) == 0) {
        __autoreleasing id returnValue = nil;
        [_invocation getReturnValue:&returnValue];
        return returnValue;
    }
    return nil;
}

+ (id)entryWithBlock:(void (^)(id object))block
{
    return [[ISAStyleEntry alloc] initWithBlock:block];
}

- (id)invokeWithTarget:(id)rootTarget
{
    id target = nil;
    if (_keyPath) {
        @try {
            target = [rootTarget valueForKeyPath:_keyPath];
        }
        @catch (NSException *exception) {
            NSLog(@"invalid key path \"%@\" for %@", _keyPath, [rootTarget class]);
            return nil;
        }
    }
    else {
        target = rootTarget;
    }
    if (!target) return nil;

    // use cashed invocation
    if (_invocation) {
        return [self safeInvokeWithTarget:target];
    }

    NSMethodSignature *signature = [target methodSignatureForSelector:_selector];
    if (!signature) {
        NSLog(@"invalid selector \"%@\" for %@", NSStringFromSelector(_selector), [rootTarget class]);
        return nil;
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
                return nil;
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
                    return nil;
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
                return nil;
            }
        }
        else {
            return nil;
        }
        argumentPos++;
    }
    free(buffer);
    [invocation retainArguments];
    _invocation = invocation;
    return [self safeInvokeWithTarget:target];
}

+ (ISAStyleEntry *)entryWithKey:(id)key value:(id)value selectorParams:(NSArray *)selectorParams
{
    if ([key isKindOfClass:[NSString class]]) {

        NSArray *array;

        NSMutableArray *keys = [key componentsSeparatedByString:@"."].mutableCopy;
        if (keys.count > 1) {
            key = keys.lastObject;
            [keys removeLastObject];
            NSString *keyPath = [keys componentsJoinedByString:@"."];
            array = @[keyPath, @{SelectorNameForSetterWithString(key) : value}];
        }
        else {
            array = @[@{SelectorNameForSetterWithString(key) : value}];
        }

        ISAStyleEntry *const entry = [self entryWithParams:array selectorParams:selectorParams];
        return entry;
    }
    else {
        // error
        return nil;
    }
}
+ (ISAStyleEntry *)entryWithParams:(NSArray *)params selectorParams:(NSArray *)selectorParams
{
    return [self entryWithParams:params fromIndex:0 selectorParams:selectorParams];
}

+ (ISAStyleEntry *)entryWithParams:(NSArray *)params fromIndex:(NSUInteger)index selectorParams:(NSArray *)selectorParams
{
    NSMutableString *selectorName = [NSMutableString string];
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[params count]];
    __block NSString *keyPath = nil;

    if (selectorParams) {
        params = [params arrayByAddingObjectsFromArray:selectorParams];
    }
    __block BOOL firstItem = YES;

    for (id component in params) {

        if(index>0) {
            index--;
            continue;
        }

        if ([component isKindOfClass:[NSDictionary class]]) {
            [component enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

                if (firstItem) {
                    NSMutableArray *keys = [key componentsSeparatedByString:@"."].mutableCopy;
                    if (keys.count > 1) {
                        key = keys.lastObject;
                        [keys removeLastObject];
                        if (keyPath) {
                            [keys insertObject:keyPath atIndex:0];
                        }
                        keyPath = [keys componentsJoinedByString:@"."];
                    }
                }
                firstItem = NO;

                [selectorName appendFormat:@"%@:", key];
                [parameters addObject:obj];
            }];
        }
        else if ([component isKindOfClass:[NSString class]]) {
            if (keyPath) {
                keyPath = [@[keyPath, component] componentsJoinedByString:@"."];
            }
            else {
                keyPath = component;
            }
        }
    }

    return [ISAStyleEntry entryWithSelector:NSSelectorFromString(selectorName)
                                  arguments:parameters keyPath:keyPath];;
}


@end
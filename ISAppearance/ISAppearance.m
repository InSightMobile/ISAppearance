//
// 

#import "ISAppearance.h"
#import "YAMLKit.h"
#import "ISValueConverter.h"

@interface ISAppearance () <YKTagDelegate, YKParserDelegate>


@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;
@end

@implementation ISAppearance
{

}

+ (ISAppearance *)sharedInstance
{
    static ISAppearance *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
    _instance = [[self alloc] init];
});
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _definitions = [NSMutableArray array];

        NSString *definitionsFile = [[NSBundle mainBundle] pathForResource:@"appearanceDefinitions" ofType:@"yaml"];
        if (definitionsFile)
            [self loadAppearanceFromFile:definitionsFile];

        NSString *file = [[NSBundle mainBundle] pathForResource:@"appearance" ofType:@"yaml"];
        if (file)
            [self loadAppearanceFromFile:file];
    }
    return self;
}

- (YKTag *)parser:(YKParser *)parser tagForURI:(NSString *)uri
{
    if (uri.length < 1)return nil;

    YKTag *tag = nil;

    NSString *className = uri;

    if ([className characterAtIndex:0] == '!') {
        className = [className substringFromIndex:1];
    }
    ISValueConverter *converter = [ISValueConverter converterNamed:className];
    tag = [converter parsingTagForURI:uri];

    return tag;
}

- (void)loadAppearanceFromFile:(NSString *)file
{
    YKParser *parser = [[YKParser alloc] init];
    parser.delegate = self;

    if ([parser readFile:file]) {

        NSError *error = nil;
        NSArray *result = [parser parseWithError:&error];
        if (error) {
            NSLog(@"error = %@", error);
        }
        else {
            NSLog(@"result = %@", result);
            [_definitions addObjectsFromArray:result];
        }
    }
}

- (void)processAppearance
{
    for (NSDictionary *definition in _definitions) {

        [self processAppearance:definition];
    }

}

- (void)processAppearance:(NSDictionary *)definition
{
    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        id appearanceProxy = nil;
        NSString *className;

        if ([key isEqual:@"define"]) {
            [self processDefinitions:(NSDictionary *) obj];
        }
        if ([key isEqual:@"general"]) {
            [self processDefinition:obj forClass:@"general"];
        }

        if ([key isKindOfClass:[NSString class]]) {
            className = key;
            Class cl = NSClassFromString(key);
            if ([cl conformsToProtocol:@protocol(UIAppearance)]) {
                appearanceProxy = [cl appearance];
            }
        }

        if (appearanceProxy) {
            [self processAppearanceProxy:appearanceProxy forClassNamed:className withParams:obj];
        }
    }];
}

- (void)processDefinition:(NSDictionary *)definition forClass:(NSString *)class
{
    if (!_definitionsByClass)
        _definitionsByClass = [NSMutableDictionary dictionary];

    NSMutableDictionary *classInfo = _definitionsByClass[class];
    if (!classInfo)classInfo = [NSMutableDictionary dictionary];

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

    }];
    _definitionsByClass[class] = classInfo;
}

- (void)processDefinitions:(NSDictionary *)definition
{
    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        if ([key isKindOfClass:[NSString class]]) {
            [self processDefinition:obj forClass:key];
        }
        else if ([key isKindOfClass:[NSArray class]]) {
            for (id value in key) {
                [self processDefinition:obj forClass:value];
            }
        }
    }];
}


SEL SelectorForPropertySetterFromString(NSString *string) {
    NSString *sel = [string stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                                    withString:[[string substringToIndex:1] uppercaseString]];

    sel = [NSString stringWithFormat:@"set%@:", sel];

    return NSSelectorFromString(sel);
}

- (void)processAppearanceProxy:(id)appearanceProxy forClassNamed:(NSString *)named withParams:(NSArray *)params
{
    for (id operation in params) {

        if ([operation isKindOfClass:[NSArray class]]) {

                NSMutableString *selectorName = [NSMutableString string];
                NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[operation count] ];

                for (NSDictionary *component in operation) {

                    [component enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

                        [selectorName appendFormat:@"%@:", key];
                        [parameters addObject:obj];
                    }];
                }
                [self invokeWithTarget:appearanceProxy selector:NSSelectorFromString(selectorName) parameters:parameters];
        }
        else if ([operation isKindOfClass:[NSDictionary class]]) {

            [operation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                // decode keys
                SEL storeSelector = SelectorForPropertySetterFromString(key);
                [self invokeWithTarget:appearanceProxy
                              selector:SelectorForPropertySetterFromString(key)
                            parameters:@[obj]];

            }];
        }
    }
}

- (BOOL)invokeWithTarget:(id)appearanceProxy selector:(SEL)selector parameters:(NSArray *)parameters
{
    NSMethodSignature *signature = [appearanceProxy methodSignatureForSelector:selector];
    if (!signature)return NO;

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = appearanceProxy;
    invocation.selector = selector;

    void *buffer = malloc([invocation.methodSignature frameLength]);

    int argumentPos = 2;
    for (id argument in parameters) {

        char const *expectedType = [invocation.methodSignature getArgumentTypeAtIndex:argumentPos];
        if(strcmp(@encode(id), expectedType) == 0) {
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
                return NO;
            }
        }
        else {
            return NO;
        }
        argumentPos++;
    }
    free(buffer);
    [invocation invoke];
}

@end
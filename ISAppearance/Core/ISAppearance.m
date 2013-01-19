//
// 

#import "ISAppearance.h"
#import "YAMLKit.h"
#import "ISAValueConverter.h"
#import "ISASwizzler.h"
#import "ISAEntry.h"

@interface ISAppearance () <YKTagDelegate, YKParserDelegate>


@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;
@end

@implementation ISAppearance
{

    NSMutableDictionary *_classStyles;
    NSMutableDictionary *_objectStyles;
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
        _classStyles = [NSMutableDictionary dictionary];
        _objectStyles = [NSMutableDictionary dictionary];

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
    ISAValueConverter *converter = [ISAValueConverter converterNamed:className];
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

        [self processISAppearance:definition];
    }
}

- (void)processUIAppearance:(NSDictionary *)definition
{
    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        id appearanceProxy = nil;
        NSString *className;

        if ([key isKindOfClass:[NSString class]]) {
            Class cl = NSClassFromString(key);
            if ([cl conformsToProtocol:@protocol(UIAppearance)]) {
                appearanceProxy = [cl appearance];
            }
        }
        else if ([key isKindOfClass:[NSArray class]]) {
            if ([key count]) {
                Class cl = NSClassFromString(key[0]);
                if ([cl conformsToProtocol:@protocol(UIAppearance)]) {

                    NSMutableArray *classes = [NSMutableArray arrayWithCapacity:[key count] - 1];
                    for (int j = 1; j < [key count]; j++) {
                        Class mcl = NSClassFromString(key[j]);
                        if (mcl) [classes addObject:mcl];
                    }

                    switch (classes.count) {
                        case 0:
                            appearanceProxy = [cl appearance];
                        break;
                        case 1:
                            appearanceProxy = [cl appearanceWhenContainedIn:classes[0], nil];
                        break;
                        case 2:
                            appearanceProxy = [cl appearanceWhenContainedIn:classes[0], classes[1], nil];
                        break;
                        case 3:
                            appearanceProxy = [cl appearanceWhenContainedIn:classes[0], classes[1], classes[2], nil];
                        break;
                        case 4:
                            appearanceProxy =
                                    [cl appearanceWhenContainedIn:classes[0], classes[1], classes[2], classes[3], nil];
                        break;
                        default:
                            NSLog(@"ISArrearance: many appearance arguments: %d", classes.count);
                        case 5:
                            appearanceProxy =
                                    [cl appearanceWhenContainedIn:classes[0], classes[1], classes[2], classes[3], classes[4], nil];
                        break;
                    }
                }
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
            NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[operation count]];

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
                [self invokeWithTarget:appearanceProxy
                              selector:SelectorForPropertySetterFromString(key)
                            parameters:@[obj]];

            }];
        }
    }
}

- (BOOL)invokeWithTarget:(id)appearanceProxy selector:(SEL)selector parameters:(NSArray *)parameters
{
    [(ISAEntry *) [ISAEntry entryWithSelector:selector parameters:parameters keyPath:0] invokeWithTarget:appearanceProxy];
    return YES;
}


- (void)processISAppearance:(NSDictionary *)definition
{
    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        if ([key isEqual:@"UIAppearance"]) {
            [self processUIAppearance:obj];
            return;
        }
        if ([key isEqual:@"ISAppearance"]) {
            [self processISAppearance:obj];
            return;
        }

        if ([key isEqual:@"define"]) {
            [self processDefinitions:(NSDictionary *) obj];
        }
        if ([key isEqual:@"general"]) {
            [self processDefinition:obj forClass:@"general"];
        }


        NSArray *components = [key componentsSeparatedByString:@":"];
        NSString *className = components[0];
        Class baseClass = NSClassFromString(className);
        if (baseClass) {
            // ensure appearance are supported
            if (![[ISASwizzler instance] swizzle:baseClass]) {
                NSLog(@"Sorry bu ISAppearance can not be used on %@ class", className);
                return;
            }
            // save a
            NSMutableArray *params = [self styleBlockWithParams:obj];

            if (components.count == 1) { // setup class itself
                NSMutableArray *entries = [_classStyles objectForKey:baseClass];
                if (entries) {
                    [entries addObjectsFromArray:params];
                }
                else {
                    [_classStyles setObject:params forKey:baseClass];
                }
            }
            else {
                NSString *isaClass = components[1];

                NSMutableDictionary *objectStyles = [_objectStyles objectForKey:baseClass];
                if (!objectStyles) {
                    objectStyles = [NSMutableDictionary dictionaryWithCapacity:1];
                    [_objectStyles setObject:objectStyles forKey:baseClass];
                }
                NSMutableArray *entries = [objectStyles objectForKey:isaClass];
                if (entries) {
                    [entries addObjectsFromArray:params];
                }
                else {
                    [objectStyles setObject:params forKey:isaClass];
                }
            }

        }
    }];
}

- (NSMutableArray *)styleBlockWithParams:(NSArray *)params
{
    NSMutableArray *invocations = [NSMutableArray arrayWithCapacity:params.count];
    for (id operation in params) {

        if ([operation isKindOfClass:[NSArray class]]) {  // method style

            NSMutableString *selectorName = [NSMutableString string];
            NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[operation count]];
            NSString *keyPath = nil;

            for (id component in operation) {

                if ([component isKindOfClass:[NSDictionary class]]) {
                    [component enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

                        [selectorName appendFormat:@"%@:", key];
                        [parameters addObject:obj];
                    }];
                }
                else if ([component isKindOfClass:[NSString class]]) {
                    keyPath = component;
                }
            }
            [invocations addObject:[ISAEntry entryWithSelector:NSSelectorFromString(selectorName)
                                                    parameters:parameters keyPath:keyPath]];
        }
        else if ([operation isKindOfClass:[NSDictionary class]]) {  // property style

            [operation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                // decode keys
                [invocations addObject:[ISAEntry entryWithSelector:SelectorForPropertySetterFromString(key)
                                                        parameters:@[obj]
                                                           keyPath:nil]];
            }];
        }
    }
    return invocations;
}

- (void)applyAppearanceTo:(UIView *)view class:(NSString *)isaClass
{
    // apply class styles first
    NSMutableArray *classes = [NSMutableArray array];

    {// find all styles classes
        Class class = [view class];
        while (class) {
            [classes addObject:class];
            class = [class superclass];
        }
    }

    // apply styled classes
    for (Class class in classes.reverseObjectEnumerator) {
        NSArray *classParams = [_classStyles objectForKey:class];
        for (ISAEntry *entry in classParams) {
            [entry invokeWithTarget:view];
        }
    }

    if (isaClass) {
        // apply styled classes
        for (Class class in classes.reverseObjectEnumerator) {
            NSDictionary *styles = [_objectStyles objectForKey:class];
            NSArray *objectParams = nil;
            if (styles) {
                objectParams = [styles objectForKey:isaClass];

                for (ISAEntry *entry in objectParams) {
                    [entry invokeWithTarget:view];
                }
            }
        }
    }
}
@end
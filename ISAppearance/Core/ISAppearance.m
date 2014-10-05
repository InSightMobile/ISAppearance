#import "ISAppearance.h"
#import "ISYAML.h"
#import "ISAValueConverter.h"
#import "ISAStyleEntry.h"
#import "ISAStyle.h"
#import "UIViewController+isa_Injection.h"
#import "UIView+isa_Injection.h"
#import "ISAProxy.h"
#import "UIDevice+isa_SystemInfo.h"
#import "ISATagResolver.h"
#import "NSObject+ISAppearance.h"

static const float kAppearanceReloadDelay = 0.25;


@interface ISAppearance () <ISYAMLParserTagResolver>

@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;

@property(nonatomic, strong) NSMutableDictionary* blocks;

@property(nonatomic, strong) NSMutableDictionary* classStyles;
@property(nonatomic, strong) NSMutableDictionary* objectStyles;
@end


@implementation ISAppearance
{
    NSMutableArray *_sources;
    id _registeredObjects;
    BOOL _monitoring;
    NSMutableArray *_monitoredAssets;
    NSMutableArray *_assets;
    NSMutableSet *_watchedFiles;
    BOOL _isAppearanceLoaded;
    NSMutableSet *_globalStyles;
    NSMutableDictionary *_classesCache;
    BOOL _isReloadScheduled;
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

+ (id)loadDataFromFile:(NSString *)path
{
    ISATagResolver *resolver = [ISATagResolver new];
    ISYAMLParser *parser = [ISYAMLParser new];
    parser.tagResolver = resolver;
    NSError *error = nil;
    id result = [parser parseFile:path parseError:&error];
    return result;
}


- (id)init
{
    self = [super init];
    if (self) {
        [self.class prepareAppearance];

        _classesCache = [NSMutableDictionary dictionary];
        _classStyles = [NSMutableDictionary dictionary];
        _objectStyles = [NSMutableDictionary dictionary];
        _definitions = [NSMutableArray array];
        _sources = [NSMutableArray array];
        _globalStyles = [NSMutableSet setWithCapacity:6];
        [self addDefaultStyles];
    }
    return self;
}

- (void)addDefaultStyles
{
    [self addGlobalStyle:[UIDevice isa_isPad] ? @"iPad" : @"iPhone"];
    [self addGlobalStyle:[UIDevice isa_isPad] ? @"~iPhone" : @"~iPad"];
    [self addGlobalStyle:[UIDevice isa_isIOS7] ? @"iOS7" : @"~iOS7"];
    [self addGlobalStyle:[UIDevice isa_isPhone5] ? @"Phone5" : @"~Phone5"];
    [self addGlobalStyle:[UIDevice isa_isPhone5] ? @"iPhone5" : @"~iPhone5"];
    [self addGlobalStyle:[UIDevice isa_isRetina] ? @"Retina" : @"~Retina"];
}

- (void)addGlobalStyle:(NSString *)string
{
    [_globalStyles addObjectsFromArray:[string componentsSeparatedByString:@":"]];
}

+ (void)prepareAppearance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if ([[UIView class] respondsToSelector:@selector(isa_swizzleClass)]) {
            [UIView isa_swizzleClass];
        }

        if ([[UIViewController class] respondsToSelector:@selector(isa_swizzleClass)]) {
            [UIViewController isa_swizzleClass];
        }
    });
}

- (void)watch:(NSString *)path once:(BOOL)once withCallback:(void (^)())callback
{
    if (_watchedFiles) {
        _watchedFiles = [NSMutableSet setWithCapacity:1];
    }
    if ([_watchedFiles containsObject:path]) {
        return;
    }
    [_watchedFiles addObject:path];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    int fileDescriptor = open([path UTF8String], O_EVTONLY);

    __block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor,
            DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND,
            queue);
    dispatch_source_set_event_handler(source, ^{
        unsigned long flags = dispatch_source_get_data(source);
        if (once) {
            [_watchedFiles removeObject:path];
            dispatch_source_cancel(source);
            callback();
        }
        else if (flags & DISPATCH_VNODE_DELETE) {
            dispatch_source_cancel(source);
            callback();
            [_watchedFiles removeObject:path];
            [self watch:path once:once withCallback:callback];
        }
        else {
            callback();
        }
    });
    dispatch_source_set_cancel_handler(source, ^(void) {
        [_watchedFiles removeObject:path];
        close(fileDescriptor);
    });
    dispatch_resume(source);
}

- (BOOL)applyBlockNamed:(NSString *)blockName toTarget:(id)target
{
    NSMutableArray *blockEntries = self.blocks[blockName];

    if(!blockEntries.count) {
        return NO;
    }

    for (ISAStyleEntry *entry in blockEntries) {
        [entry invokeWithTarget:target];
    }

    return YES;
}

+ (BOOL)isPad
{
    return [UIDevice isa_isPad];
}

+ (BOOL)isPhone5
{
    return [UIDevice isa_isPhone5];
}

+ (BOOL)isRetina
{
    return [UIDevice isa_isRetina];
}

+ (BOOL)isIOS7
{
    return [UIDevice isa_isIOS7];
}

+ (BOOL)isIOS6AndGreater
{
    return [UIDevice isa_isIOS6AndGreater];
}

+ (BOOL)isIOS5
{
    return [UIDevice isa_isIOS5];
}

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring
{
    [self loadAppearanceFromFile:file];
    if (monitoring) {
        _monitoring = YES;
        [self watchAndReloadPath:file once:NO ];
    }
}

+ (id)loadDataFromFileNamed:(NSString *)string bundle:(NSBundle *)bundle
{
    return [ISYAML loadDataFromFileNamed:string bundle:bundle error:NULL];
}

- (ISYAMLTag *)tagForURI:(NSString *)uri
{
    if (uri.length < 1) {
        return nil;
    }

    ISYAMLTag *tag = nil;

    NSString *className = uri;

    if ([className characterAtIndex:0] == '!') {
        className = [className substringFromIndex:1];
    }
    ISAValueConverter *converter = [ISAValueConverter converterNamed:className];
    tag = [converter parsingTagForURI:uri];

    return tag;
}

- (id)loadAppearanceData:(NSString *)file error:(NSError * __autoreleasing *)error
{
    ISYAMLParser *parser = [[ISYAMLParser alloc] init];
    parser.tagResolver = self;

    id result = [parser parseFile:file parseError:error];
    if (error && *error) {
        NSString *line = [*error userInfo][YKProblemLineKey];

        NSString *desc = [NSString stringWithFormat:@"Error in %@:%@", file.lastPathComponent, line];
        *error =
                [[NSError alloc] initWithDomain:@"ISAppearance" code:0 userInfo:@{NSLocalizedDescriptionKey : desc}];
        return nil;
    }
    else {
        return result;
    }
}

- (void)loadAppearanceFromFile:(NSString *)file
{
    if ([[NSFileManager defaultManager] isReadableFileAtPath:file]) {
        [_sources addObject:file];
    }
}

- (void)loadAppearanceNamed:(NSString *)name
{
    NSString *file = [self appearancePathForName:name];
    if (file) {
        [self loadAppearanceFromFile:file];
    }
    if (_monitoring) {
        [self watchAndReloadPath:file once:NO ];
    }
}

- (NSString *)appearancePathForName:(NSString *)name
{
    NSString *ext = [name pathExtension];
    NSString *path = nil;
    if (!ext.length) {
        path = [self findFileNamed:[name stringByAppendingPathExtension:@"yaml"]];
    }
    if (!path) {
        path = [self findFileNamed:name];
    }
    return path;
}

- (void)monitorDirectory:(NSString *)directory
{
#if (TARGET_IPHONE_SIMULATOR)
    if (directory.length) {
        [self addAssetsFolder:directory withMonitoring:YES];
    }
#endif
}


- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory
{
    [self monitorDirectory:directory];
    [self loadAppearanceNamed:name];
}

- (BOOL)reloadAppearanceSourcesWithError:(NSError * __autoreleasing *)error
{
    [_definitions removeAllObjects];
    for (NSString *file in _sources) {
        NSArray *definitions = [self loadAppearanceData:file error:error];
        if (definitions.count) {
            [_definitions addObjectsFromArray:definitions];
        }
        else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)reloadAppearanceWithError:(NSError * __autoreleasing *)error
{
    [_classStyles removeAllObjects];
    [_objectStyles removeAllObjects];
    [_classesCache removeAllObjects];
    return [self processAppearanceWithError:error];
}

- (void)autoReloadAppearance
{
    @try {
        NSError *error = nil;

        if ([self reloadAppearanceWithError:&error]) {
            NSLog(@"ISAppearance reloaded");
        }
        else {
            NSLog(@"ISAppearance reload error: %@",error);
            UIAlertView *alertView =
                    [[UIAlertView alloc] initWithTitle:@"ISAppearance error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

            [alertView show];
        }
    }
    @catch (NSException *ex) {

        NSLog(@"Appearance apply expection:%@", ex);
        UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:@"ISAppearance expection" message:ex.description delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

        [alertView show];
    }

}

- (NSString *)pathForMonitoredAssetFolder:(NSString *)directory
{
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];

    if (exists && isDirectory) {
        return directory;
    }
    else {
        return nil;
    }
}

- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring
{
#if (TARGET_IPHONE_SIMULATOR)
    if (monitoring) {
        NSString *path = [self pathForMonitoredAssetFolder:folder];
        if(path) {
            _monitoring = YES;
            if (!_monitoredAssets) {
                _monitoredAssets = [NSMutableArray arrayWithCapacity:1];
            }
            [_monitoredAssets addObject:path];
        }
    }
    else {
        [self addAssetsFolder:folder];
    }
#else
    [self addAssetsFolder:folder];
#endif
}

- (void)addAssetsFolder:(NSString *)folder
{
    if (!_assets) {
        _assets = [NSMutableArray arrayWithCapacity:1];
    }
    [_assets addObject:folder];
}

- (BOOL)processAppearance
{
    NSError *error = nil;
    if (![self processAppearanceWithError:&error]) {
        NSLog(@"ISAppearance failed with error %@", error);
        return NO;
    }
    return YES;
}

- (BOOL)processAppearanceWithError:(NSError * __autoreleasing *)error
{
    if (![self reloadAppearanceSourcesWithError:error]) {

        return NO;
    }

    for (NSDictionary *definition in _definitions) {
        if (![self processISAppearance:definition baseKeys:nil error:error]) {
            return NO;
        }
    }
    _isAppearanceLoaded = YES;
    [self updateAppearanceRegisteredObjects];

    return YES;
}

- (void)processUIAppearance:(NSDictionary *)definition
{
    if (![definition isKindOfClass:[NSDictionary class]]) {
        return;
    }

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        id appearanceProxy = nil;

        if ([key isKindOfClass:[NSString class]]) {
            key = [key componentsSeparatedByString:@":"];
        }

        if ([key isKindOfClass:[NSArray class]]) {
            if ([key count] == 1) {
                key = key[0];
            }
        }


        if ([key isKindOfClass:[NSString class]]) {
            Class <UIAppearance> cl = NSClassFromString(key);
            if ([cl conformsToProtocol:@protocol(UIAppearance)]) {
                appearanceProxy = [cl appearance];
            }
        }
        else if ([key isKindOfClass:[NSArray class]]) {
            if ([key count]) {
                Class <UIAppearance> cl = NSClassFromString(key[0]);
                if ([cl conformsToProtocol:@protocol(UIAppearance)]) {

                    NSMutableArray *classes = [NSMutableArray arrayWithCapacity:[key count] - 1];
                    for (int j = 1; j < [key count]; j++) {
                        Class mcl = NSClassFromString(key[j]);
                        if (mcl) {
                            [classes addObject:mcl];
                        }
                    }

                    [UINavigationBar appearance];

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
            [self processUIAppearanceProxy:appearanceProxy withParams:obj];
        }
    }];
}

- (void)processDefinition:(NSDictionary *)definition forClass:(NSString *)class
{
    if (!_definitionsByClass) {
        _definitionsByClass = [NSMutableDictionary dictionary];
    }

    NSMutableDictionary *classInfo = _definitionsByClass[class];
    if (!classInfo) {
        classInfo = [NSMutableDictionary dictionary];
    }

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

- (void)processUIAppearanceProxy:(id)appearanceProxy withParams:(NSArray *)params
{
    NSMutableArray *entries = [self styleBlockWithParams:params selectorParams:nil ];
    for (ISAStyleEntry *entry in entries) {
        [entry invokeWithTarget:appearanceProxy];
    }
}

- (BOOL)processISAppearance:(NSDictionary *)definition baseKeys:(NSArray *)baseKeys error:(NSError * __autoreleasing *)pError
{
    if ([definition isKindOfClass:[NSArray class]]) {
        for (id subDefinition in definition) {
            if (![self processISAppearance:subDefinition baseKeys:baseKeys error:pError]) {
                return NO;
            }
        }
        return YES;
    }

    if (![definition isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    __block BOOL result = YES;
    __block NSError *error = nil;

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        NSArray *keys = [key componentsSeparatedByString:@":"];

        NSString *defkey = keys[0];
        NSArray *passedKeys = nil;

        if ([defkey isEqual:@"UIAppearance"]) {
            if ([self checkStyleConformance:keys passedSelectors:&passedKeys]) {
                [self processUIAppearance:obj];
                if (_monitoring) {
                    [self processISAppearance:obj baseKeys:nil error:NULL ];
                }
            }
            return;
        }
        else if ([defkey isEqual:@"ISAppearance"]) {
            if ([self checkStyleConformance:keys passedSelectors:&passedKeys]) {
                [self processISAppearance:obj baseKeys:passedKeys error:NULL ];
            }
            return;
        }
        else if ([defkey isEqual:@"include"]) {
            if ([self checkStyleConformance:keys passedSelectors:&passedKeys]) {
                NSString *file = [self appearancePathForName:obj];
                if (file) {
                    id includeDefinitions = [self loadAppearanceData:file error:&error];
                    if (includeDefinitions) {
                        if ([self processISAppearance:includeDefinitions baseKeys:passedKeys error:&error]) {
                            return;
                        }
                    }
                }
                // if something failed
                result = NO;
                *stop = YES;
            }
            return;
        }
        else if ([defkey isEqual:@"block"]) {
            NSMutableArray *blockParams = [self styleBlockWithParams:obj selectorParams:nil];
            if (blockParams.count && keys.count > 1) {
                NSString *blockName = [[keys subarrayWithRange:NSMakeRange(1, keys.count - 1)] componentsJoinedByString:@":"];

                if(!self.blocks) {
                    self.blocks = [NSMutableDictionary new];
                }

                self.blocks[blockName] = blockParams;
            }
            return;
        }

        if (baseKeys.count) {
            keys = [keys arrayByAddingObjectsFromArray:baseKeys];
        }

        NSMutableArray *params = [self styleBlockWithParams:obj selectorParams:nil];
        if (!params) {
            return;
        }
        [self addParams:params toSelector:keys];
    }];
    if (pError && error) {
        *pError = error;
    }
    return result;
}

- (BOOL)checkStyleConformance:(NSArray *)selectors passedSelectors:(NSArray **)pPassedSelectors
{
    NSMutableArray *passedSelectors = pPassedSelectors ? [NSMutableArray new] : nil;
    for (int i = 1; i < selectors.count; i++) {

        NSString *selector = selectors[i];
        NSString *negativeSelector;
        if ([selector hasPrefix:@"~"]) {
            negativeSelector = [selector substringFromIndex:1];
        }
        else {
            negativeSelector = [@"~" stringByAppendingString:selector];
        }

        if ([_globalStyles containsObject:negativeSelector]) {
            return NO;
        }
        else if (![_globalStyles containsObject:selector]) {
            [passedSelectors addObject:selector];
        }
    }
    if (pPassedSelectors) {
        *pPassedSelectors = passedSelectors;
    }
    return YES;
}

- (void)addParams:(NSArray *)params toSelector:(NSArray *)components
{
    NSString *className = components[0];
    Class baseClass = NSClassFromString(className);
    if (!baseClass) {
        return;
    }
    NSArray *userComponents = [components subarrayWithRange:NSMakeRange(1, components.count - 1)];

    [self addParams:params forClass:baseClass toSelector:userComponents];
}

- (void)addParams:(NSArray *)params forClass:(Class)baseClass toSelector:(NSArray *)userComponents
{
    NSString *className = NSStringFromClass(baseClass);

    NSSet *selectors = [NSSet setWithArray:userComponents];
    ISAStyle *style = [self styleWithClass:className selectors:selectors];

    if (style) {
        [style addEntries:params];
    }
    else {
        style = [ISAStyle new];
        style.baseClass = baseClass;
        style.className = className;
        [style processSelectors:selectors];
        [style addEntries:params];
        [self indexStyle:style];
    }
}

- (void)indexStyle:(ISAStyle *)style
{
    NSString *className = style.className;
    // save a
    if (style.selectors.count == 0) { // setup class itself
        [_classStyles setObject:style forKey:className];
    }
    else {
        NSMutableDictionary *objectStyles = [_objectStyles objectForKey:className];
        if (!objectStyles) {
            objectStyles = [NSMutableDictionary dictionaryWithCapacity:1];
            [_objectStyles setObject:objectStyles forKey:className];
        }
        [objectStyles setObject:style forKey:style.selectors];

        NSSet *components = style.classSelectors;

        for (NSString *component in components) {
            NSMutableArray *entries = [objectStyles objectForKey:component];
            if (entries) {
                [entries addObject:style];
            }
            else {
                [objectStyles setObject:[NSMutableArray arrayWithObject:style] forKey:component];
            }
        }
    }
}

- (ISAStyle *)styleWithClass:(NSString *)className selectors:(NSSet *)components
{
    if (components.count == 0) { // setup class itself
        return [_classStyles valueForKey:className];
    }
    else {
        NSMutableDictionary *objectStyles = [_objectStyles objectForKey:className];
        return [objectStyles objectForKey:components];
    }
}

- (NSMutableArray *)styleBlockWithParams:(id)params selectorParams:(NSArray *)selectorParams
{
    NSMutableArray *invocations = nil;
    if ([params isKindOfClass:[NSDictionary class]]) {

        invocations = [NSMutableArray arrayWithCapacity:[params count]];

        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

            ISAStyleEntry *entry = [ISAStyleEntry entryWithKey:key value:obj selectorParams:selectorParams];
            if (entry) {
                [invocations addObject:entry];
            }
        }];
    }
    else if ([params isKindOfClass:[NSArray class]]) {
        invocations = [NSMutableArray arrayWithCapacity:[params count]];

        for (id operation in params) {

            if ([operation isKindOfClass:[NSArray class]]) {  // method style

                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:operation selectorParams:selectorParams];
                if (entry) {
                    [invocations addObject:entry];
                }
            }
            else if ([operation isKindOfClass:[NSDictionary class]]) {

                [operation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key isKindOfClass:[NSString class]]) {    // property set style
                        // decode keys
                        ISAStyleEntry *entry = [ISAStyleEntry entryWithKey:key value:obj selectorParams:selectorParams];
                        if (entry) {
                            [invocations addObject:entry];
                        }
                    }
                    else if ([key isKindOfClass:[NSArray class]]) {  // modifier style

                        if (selectorParams) {
                            key = [key arrayByAddingObjectsFromArray:selectorParams];
                        }

                        NSMutableArray *subInvokations = [self styleBlockWithParams:obj selectorParams:key];
                        if (subInvokations.count) {
                            [invocations addObjectsFromArray:subInvokations];
                        }
                    }
                    else {
                        // error
                    }
                }];
            }
        }
    }
    else {
        // error
    }
    return invocations;
}

#pragma clang diagnostic push
#pragma ide diagnostic ignored "UnavailableInDeploymentTarget"
- (void)registerObject:(id)object
{
    if (!_registeredObjects) {
        Class cl = NSClassFromString(@"NSHashTable");
        if (cl) {
            _registeredObjects = [NSHashTable weakObjectsHashTable];
        }
        else {
            _registeredObjects = [NSMutableSet set];
        }
    }
    [_registeredObjects addObject:object];
}
#pragma clang diagnostic pop


- (void)updateAppearanceRegisteredObjects
{
    for (id object in [_registeredObjects copy]) {
        if ([object respondsToSelector:@selector(isaClass)]) {
            [self applyAppearanceTo:object usingClassesString:[object isaClass]];
        }
        else {
            [self applyAppearanceTo:object usingClassesString:nil];
        }
    }
    if (_monitoring) {
        [CATransaction flush];
        UIView *mainView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
        // flush view window
        UIView *superview = mainView.superview;
        [mainView removeFromSuperview];
        [superview addSubview:mainView];
    }
    else {
        [_registeredObjects removeAllObjects];
    }
}

- (BOOL)applyAppearanceTo:(id)target
{
    if ([target respondsToSelector:@selector(isaClass)]) {
        return [self applyAppearanceTo:target usingClassesString:[target isaClass]];
    }
    else {
        return [self applyAppearanceTo:target usingClassesString:nil];
    }
}

- (BOOL)applyAppearanceTo:(id)target usingClassesString:(NSString *)classNames
{
    NSSet *userClasses = nil;
    if (classNames.length) {
        NSArray *selectors = [classNames componentsSeparatedByString:@":"];
        userClasses = [NSSet setWithArray:selectors];
    }
    return [self applyAppearanceTo:target usingClasses:userClasses];
}

- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSSet *)userClasses
{

    if(!userClasses) {
        userClasses = [NSSet set];
    }

    if (!_isAppearanceLoaded) {
        [self registerObject:target];
        return NO;
    }

    if (_monitoring) {
        [self registerObject:target];
    }

    Class targetClass = [target class];
    NSString *targetClassName = NSStringFromClass(targetClass);
    NSMutableDictionary *styleCache = _classesCache[targetClassName];
    if (!styleCache) {
        styleCache = [NSMutableDictionary dictionaryWithCapacity:1];
        _classesCache[targetClassName] = styleCache;
    }
    NSArray *styles = styleCache[userClasses];
    if (!styles) {

        NSSet *targetClasses = nil;
        if (userClasses.count) {
            NSMutableSet *classes = [userClasses mutableCopy];
            [classes unionSet:_globalStyles];
            targetClasses = classes;
        }
        else {
            targetClasses = _globalStyles;
        }

        // apply class styles first
        NSMutableArray *classes = [NSMutableArray array];
        {// find all styles classes
            Class class = targetClass;
            while (class) {
                [classes addObject:NSStringFromClass(class)];
                class = [class superclass];
            }
        }

        NSMutableArray *foundStyles = [NSMutableArray new];

        // apply individual classes
        for (NSString *className in classes.reverseObjectEnumerator) {

            ISAStyle *classStyle = [_classStyles objectForKey:className];
            if (classStyle) {
                [foundStyles addObject:classStyle];
            }

            NSMutableSet *stylesToApply = [NSMutableSet new];
            for (NSString *userClass in targetClasses) {
                NSDictionary *styles = [_objectStyles objectForKey:className];
                if (styles) {
                    NSArray *candidateStyles = [styles objectForKey:userClass];
                    for (ISAStyle *style in candidateStyles) {
                        if (![stylesToApply containsObject:style] &&
                                [style isConformToClassSelectors:targetClasses]) {
                            [stylesToApply addObject:style];
                        }
                    }
                }
            }
            NSArray *sortedStyles = [stylesToApply.allObjects sortedArrayUsingSelector:@selector(compare:)];
            [foundStyles addObjectsFromArray:sortedStyles];
        }
        styles = [foundStyles copy];
        styleCache[userClasses] = styles;
    }

    if(styles.count) {
        @autoreleasepool {
            [target isa_willApplyAppearance];
            for (ISAStyle *style in styles) {
                [style applyToTarget:target];
            }
            [target isa_didApplyAppearance];
        }
    }

    return YES;
}

- (NSString *)findFile:(NSString *)file inFolder:(NSString *)folder recursive:(BOOL)reqcursive
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [folder stringByAppendingPathComponent:file];
    if ([manager fileExistsAtPath:path]) {
        return path;
    }

    if (reqcursive) {

        NSDirectoryEnumerator *dirEnumerator =
                [manager enumeratorAtURL:[NSURL fileURLWithPath:folder]
              includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                 options:NSDirectoryEnumerationSkipsHiddenFiles |
                                         NSDirectoryEnumerationSkipsSubdirectoryDescendants |
                                         NSDirectoryEnumerationSkipsPackageDescendants
                            errorHandler:nil];

        // Enumerate the dirEnumerator results, each value is stored in allURLs
        for (NSURL *theURL in dirEnumerator) {
            // Retrieve whether a directory.
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];

            if ([isDirectory boolValue] == YES) {
                path = [self findFile:file inFolder:theURL.path recursive:YES];
                if (path) {
                    return path;
                }
            }
        }
    }
    return nil;
}


- (NSString *)findImageFile:(NSString *)file inFolder:(NSString *)folder forRetina:(BOOL)isRetina forPad:(BOOL)isIpad
                      scale:(CGFloat *)scale
{
    NSString *ext = [file pathExtension];
    NSString *name = [file stringByDeletingPathExtension];

    if (!ext) {
        ext = @"png";
    }

    NSString *mutatedFile;
    NSString *path;

    if (isIpad) {

        if (isRetina) {
            mutatedFile = [NSString stringWithFormat:@"%@@2x~ipad.%@", name, ext];
            path = [self findFile:mutatedFile inFolder:folder recursive:YES];
            if (path) {
                *scale = 2;
                return path;
            }
        }
        mutatedFile = [NSString stringWithFormat:@"%@~ipad.%@", name, ext];
        path = [self findFile:mutatedFile inFolder:folder recursive:YES];
        if (path) {
            *scale = 1;
            return path;
        }
    }

    if (isRetina) {
        mutatedFile = [NSString stringWithFormat:@"%@@2x.%@", name, ext];
        path = [self findFile:mutatedFile inFolder:folder recursive:YES];
        if (path) {
            *scale = 2;
            return path;
        }
    }
    mutatedFile = [NSString stringWithFormat:@"%@.%@", name, ext];
    path = [self findFile:mutatedFile inFolder:folder recursive:YES];
    if (path) {
        *scale = 1;
        return path;
    }
    return nil;
}

- (NSString *)findFileNamed:(NSString *)file
{
    NSString *path = nil;
    for (NSString *folder in _monitoredAssets) {
        path = [self findFile:file inFolder:folder recursive:YES];
        if (path) {
            [self watchAndReloadPath:path once:YES ];
            break;
        }
    }
    if (!path) {
        path = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    }
    if (!path) {
        for (NSString *folder in _assets) {
            path = [self findFile:file inFolder:folder recursive:YES];
            if (path) {
                break;
            }
        }
    }
    return path;
}

- (UIImage *)loadImageNamed:(NSString *)string forRetina:(BOOL)isRetina forPad:(BOOL)isIpad
{
    NSString *path = nil;
    UIImage *image = nil;
    CGFloat scale = 0;
    // find images
    for (NSString *folder in _monitoredAssets) {
        path = [self findImageFile:string inFolder:folder forRetina:isRetina forPad:isIpad scale:&scale];
        if (path) {
            [self watchAndReloadPath:path once:YES ];
            break;
        }
    }
    if (!image) {
        for (NSString *folder in _assets) {
            path = [self findImageFile:string inFolder:folder forRetina:isRetina forPad:isIpad scale:&scale];
            if (path) {
                break;
            }
        }
    }
    if (path) {
        if (scale != 1) {
            image = [UIImage imageWithCGImage:[[UIImage imageWithContentsOfFile:path] CGImage]
                                        scale:scale orientation:UIImageOrientationUp];
        }
        else {
            image = [UIImage imageWithContentsOfFile:path];
        }
    }

    if (!image) {
        image = [UIImage imageNamed:string];
    }

    return image;
}

- (void)watchAndReloadPath:(NSString *)path once:(BOOL)once
{
    [self watch:path once:once withCallback:^{
        [self performSelectorOnMainThread:@selector(scheduleReload) withObject:nil waitUntilDone:NO];
    }];
}

- (void)scheduleReload
{
    if (!_isReloadScheduled) {
        _isReloadScheduled = YES;
        [self performSelector:@selector(performScheduledReload) withObject:nil afterDelay:kAppearanceReloadDelay];
    }
}

- (void)performScheduledReload
{
    [self autoReloadAppearance];
    _isReloadScheduled = NO;
}

- (UIImage *)loadImageNamed:(NSString *)string
{
    bool isRetina = [ISAppearance isRetina];
    bool isPad = [ISAppearance isPad];

    UIImage *image = [self loadImageNamed:string forRetina:isRetina forPad:isPad];
    if (image) {
        return image;
    }

    if (!isRetina) {
        image = [self loadImageNamed:string forRetina:YES forPad:isPad];
        // scale image
        return image;
    }
    return [UIImage imageNamed:string];
}

- (void)addStyleEntry:(ISAStyleEntry *)entry forClass:(Class)class andSelector:(NSString *)selectors
{
    NSArray *keys = [selectors componentsSeparatedByString:@":"];

    [self addParams:@[entry] forClass:class toSelector:keys];
}

- (void)registerProxy:(ISAProxy *)proxy
{

}

- (void)unregisterProxy:(ISAProxy *)proxy
{

}
@end
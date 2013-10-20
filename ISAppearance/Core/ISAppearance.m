#import "ISAppearance.h"
#import "ISA_YAMLKit.h"
#import "ISAValueConverter.h"
#import "ISAStyleEntry.h"
#import "NSObject+ISA_Swizzle.h"
#import "ISAStyle.h"

@interface ISAppearance () <YKParserDelegate>

@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;

@end


@implementation ISAppearance
{
    NSMutableDictionary *_classStyles;
    NSMutableDictionary *_objectStyles;
    NSMutableArray *_sources;
    id _registeredObjects;
    BOOL _monitoring;
    NSMutableArray *_monitoredAssets;
    NSMutableArray *_assets;
    NSMutableSet *_watchedFiles;
    BOOL _isAppearanceLoaded;
    NSMutableSet *_globalStyles;
    NSMutableDictionary *_classesCache;
}

+ (ISAppearance *)sharedInstance
{
    static ISAppearance *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^
    {
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (id)loadDataFromFile:(NSString *)path
{
    return [ISA_YAMLKit loadFromFile:path error:NULL];
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
    [self addGlobalStyle:[ISAppearance isPad] ? @"iPad" : @"iPhone"];
    [self addGlobalStyle:[ISAppearance isIOS7] ? @"iOS7" : @"~iOS7"];
    [self addGlobalStyle:[ISAppearance isPhone5] ? @"Phone5" : @"~Phone5"];
    [self addGlobalStyle:[ISAppearance isRetina] ? @"Retina" : @"~Retina"];
}

- (void)addGlobalStyle:(NSString *)string
{
    [_globalStyles addObjectsFromArray:[string componentsSeparatedByString:@":"]];
}

+ (void)prepareAppearance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^
    {

        if ([[UIView class] respondsToSelector:@selector(ISA_swizzleClass)]) {
            [UIView ISA_swizzleClass];
        }

        if ([[UIViewController class] respondsToSelector:@selector(ISA_swizzleClass)]) {
            [UIViewController ISA_swizzleClass];
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
    dispatch_source_set_event_handler(source, ^
    {
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
    dispatch_source_set_cancel_handler(source, ^(void)
    {
        [_watchedFiles removeObject:path];
        close(fileDescriptor);
    });
    dispatch_resume(source);
}

+ (BOOL)isPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)isPhone5
{
    return !self.isPad && (fabs((double) [[UIScreen mainScreen] bounds].size.height - (double) 568) < DBL_EPSILON );
}

+ (BOOL)isRetina
{
    return [UIScreen mainScreen].scale == 2.0;
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


+ (BOOL)isIOS7
{
#ifdef __IPHONE_7_0
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
#else
    return NO;
#endif
}

+ (BOOL)isIOS6AndGreater
{
#ifdef __IPHONE_6_0
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0");
#else
    return NO;
#endif
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
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    NSString *path = [bundle pathForResource:[string stringByDeletingPathExtension]
                                      ofType:[string pathExtension]];
    return [self loadDataFromFile:path];
}

- (ISA_YKTag *)parser:(ISA_YKParser *)parser tagForURI:(NSString *)uri
{
    if (uri.length < 1) {
        return nil;
    }

    ISA_YKTag *tag = nil;

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
    ISA_YKParser *parser = [[ISA_YKParser alloc] init];
    parser.delegate = self;
    if ([parser readFile:file]) {
        id result = [parser parseWithError:error];
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
    else {
        return nil;
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
    NSError *error = nil;
    if ([self reloadAppearanceWithError:&error]) {
        [self performSelector:@selector(reloadAppearanceWithError:) withObject:nil afterDelay:0.3];
    }
    else {
        UIAlertView *alertView =
                [[UIAlertView alloc] initWithTitle:@"ISAppearance error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];

        [alertView show];
    }

}

- (NSString *)pathForMonitoredAssetFolder:(NSString *)directory
{
    if ([directory hasPrefix:@"~/"]) {
        // we use this trick to locate user directory outside of simulator

        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

        NSUInteger pos = [path rangeOfString:@"/Library/Application Support/iPhone Simulator/"].location;
        path = [path substringToIndex:pos];

        directory = [path stringByAppendingPathComponent:[directory substringFromIndex:2]];
    }

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
        _monitoring = YES;
        NSString *path = [self pathForMonitoredAssetFolder:folder];
        if(path) {
            if (!_monitoredAssets) _monitoredAssets = [NSMutableArray arrayWithCapacity:1];
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
        if (![self processISAppearance:definition error:error]) {
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

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {

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

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {

    }];
    _definitionsByClass[class] = classInfo;
}

- (void)processDefinitions:(NSDictionary *)definition
{
    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {

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

- (BOOL)processISAppearance:(NSDictionary *)definition error:(NSError * __autoreleasing *)pError
{
    if ([definition isKindOfClass:[NSArray class]]) {
        for (id subDefinition in definition) {
            if (![self processISAppearance:subDefinition error:pError]) {
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

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {

        NSArray *keys = [key componentsSeparatedByString:@":"];

        NSString *defkey = keys[0];

        if ([defkey isEqual:@"UIAppearance"]) {
            if ([self checkStyleConformance:keys]) {
                [self processUIAppearance:obj];
                if (_monitoring) {
                    [self processISAppearance:obj error:NULL ];
                }
            }
            return;
        }
        else if ([defkey isEqual:@"ISAppearance"]) {
            if ([self checkStyleConformance:keys]) {
                [self processISAppearance:obj error:NULL ];
            }
            return;
        }
        else if ([defkey isEqual:@"include"]) {
            if ([self checkStyleConformance:keys]) {
                NSString *file = [self appearancePathForName:obj];
                if (file) {
                    id includeDefinitions = [self loadAppearanceData:file error:&error];
                    if (includeDefinitions) {
                        if ([self processISAppearance:includeDefinitions error:&error]) {
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

        NSArray *selector = keys;
        NSMutableArray *params = [self styleBlockWithParams:obj selectorParams:nil];
        if (!params) {
            return;
        }
        [self addParams:params toSelector:selector];
    }];
    if (pError && error) {
        *pError = error;
    }
    return result;
}

- (BOOL)checkStyleConformance:(NSArray *)selectors
{
    for (int i = 1; i < selectors.count; i++) {
        if (![_globalStyles containsObject:selectors[i]]) {
            return NO;
        }
    }
    return YES;
}

- (void)addParams:(NSMutableArray *)params toSelector:(NSArray *)components
{
    //NSArray *components = [selector componentsSeparatedByString:@":"];
    NSString *className = components[0];
    Class baseClass = NSClassFromString(className);
    if (!baseClass) {
        return;
    }
    className = NSStringFromClass(baseClass);

    NSArray *userComponents = [components subarrayWithRange:NSMakeRange(1, components.count - 1)];

    NSSet *selectors = [NSSet setWithArray:userComponents];
    ISAStyle *style = [self styleWithClass:className selectors:selectors];

    if (style) {
        [style addEntries:params];
    }
    else {
        style = [ISAStyle new];
        style.baseClass = baseClass;
        style.className = className;
        style.selectors = selectors;
        [style addEntries:params];
        [self indexStyle:style];
    }
}

- (void)indexStyle:(ISAStyle *)style
{
    NSSet *components = style.selectors;
    NSString *className = style.className;

    // save a
    if (components.count == 0) { // setup class itself
        [_classStyles setObject:style forKey:className];
    }
    else {
        NSMutableDictionary *objectStyles = [_objectStyles objectForKey:className];
        if (!objectStyles) {
            objectStyles = [NSMutableDictionary dictionaryWithCapacity:1];
            [_objectStyles setObject:objectStyles forKey:className];
        }
        [objectStyles setObject:style forKey:components];

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
    NSMutableArray *invocations = [NSMutableArray arrayWithCapacity:[params count]];

    if ([params isKindOfClass:[NSDictionary class]]) {
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {

            ISAStyleEntry *entry = [ISAStyleEntry entryWithKey:key value:obj selectorParams:selectorParams];
            if (entry) {
                [invocations addObject:entry];
            }
        }];
    }
    else if ([params isKindOfClass:[NSArray class]]) {

        for (id operation in params) {

            if ([operation isKindOfClass:[NSArray class]]) {  // method style

                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:operation selectorParams:selectorParams];
                if (entry) {
                    [invocations addObject:entry];
                }
            }
            else if ([operation isKindOfClass:[NSDictionary class]]) {

                [operation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                {
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

- (void)registerObject:(id)object
{
    if (!_registeredObjects) {
        Class cl = NSClassFromString(@"NSHashTable");
        if ([cl resolveClassMethod:@selector(weakObjectsHashTable)]) {
            _registeredObjects = [NSHashTable weakObjectsHashTable];
        }
        else {
            _registeredObjects = [NSMutableSet set];
        }
    }
    [_registeredObjects addObject:object];
}


- (void)updateAppearanceRegisteredObjects
{
    for (id object in [_registeredObjects copy]) {
        if ([object respondsToSelector:@selector(isaClass)]) {
            [self applyAppearanceTo:object usingClasses:[object isaClass]];
        }
        else {
            [self applyAppearanceTo:object usingClasses:nil];
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

- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSString *)classNames
{
    NSSet *userClasses = nil;
    if (classNames.length) {
        userClasses = [NSSet setWithArray:[classNames componentsSeparatedByString:@":"]];
    }
    else {
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

        NSSet* targetClasses = nil;
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
                [classStyle applyToTarget:target];
            }

            NSMutableSet *stylesToApply = [NSMutableSet new];
            for (NSString *userClass in targetClasses) {
                NSDictionary *styles = [_objectStyles objectForKey:className];
                if (styles) {
                    NSArray *candidateStyles = [styles objectForKey:userClass];
                    for (ISAStyle *style in candidateStyles) {
                        if (![stylesToApply containsObject:style] &&
                                [style isConformToSelectors:targetClasses]) {
                            [stylesToApply addObject:style];
                        }
                    }
                }
            }
            [foundStyles addObjectsFromArray:stylesToApply.allObjects];
        }
        styles = [foundStyles copy];
        styleCache[userClasses] = styles;
    }


    for (ISAStyle *style in styles) {
        [style applyToTarget:target];
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
    [self watch:path once:once withCallback:^
    {
        [self performSelectorOnMainThread:@selector(autoReloadAppearance) withObject:nil waitUntilDone:NO];
    }];
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

@end
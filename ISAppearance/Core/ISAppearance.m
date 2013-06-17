#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "ISAppearance.h"
#import "YAMLKit.h"
#import "ISAValueConverter.h"
#import "ISAEntry.h"
#import "NSObject+ISA_Swizzle.h"

@interface ISAppearance () <YKParserDelegate>


@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;
@end

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


@implementation ISAppearance
{
    NSMutableDictionary *_classStyles;
    NSMutableDictionary *_objectStyles;
    NSMutableArray *_sources;
    id _registeredObjects;
    BOOL _monitoring;
    NSMutableArray *_monitoredAssets;
    NSMutableArray *_assets;
    NSMutableSet *_wachedFiles;
    BOOL _isAppearanceLoaded;
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
        _sources = [NSMutableArray array];

        [self.class prepareAppearance];
    }
    return self;
}

+ (void)prepareAppearance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{

        if ([[UIView class] respondsToSelector:@selector(ISA_swizzleClass)])
        {
            [UIView ISA_swizzleClass];
            // do whatever you need to do
        }

        if ([[UIViewController class] respondsToSelector:@selector(ISA_swizzleClass)])
        {
            [UIViewController ISA_swizzleClass];
            // do whatever you need to do
        }
    });
 }

- (void)watch:(NSString *)path once:(BOOL)once withCallback:(void (^)())callback
{
    if (_wachedFiles) _wachedFiles = [NSMutableSet setWithCapacity:1];
    if ([_wachedFiles containsObject:path]) {
        return;
    }
    [_wachedFiles addObject:path];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    int fileDescriptor = open([path UTF8String], O_EVTONLY);

    __block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileDescriptor,
            DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND,
            queue);
    dispatch_source_set_event_handler(source, ^{
        unsigned long flags = dispatch_source_get_data(source);
        if (once) {
            [_wachedFiles removeObject:path];
            dispatch_source_cancel(source);
            callback();
        }
        else if (flags & DISPATCH_VNODE_DELETE) {
            dispatch_source_cancel(source);
            callback();
            [_wachedFiles removeObject:path];
            [self watch:path once:once withCallback:callback];
        }
        else {
            callback();
        }
    });
    dispatch_source_set_cancel_handler(source, ^(void) {
        [_wachedFiles removeObject:path];
        close(fileDescriptor);
    });
    dispatch_resume(source);
}

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring
{
    [self loadAppearanceFromFile:file];
    if (monitoring) {
        _monitoring = YES;
        [self watchAndReloadPath:file once:NO ];
    }
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

- (void)loadAppearanceData:(NSString *)file
{
    YKParser *parser = [[YKParser alloc] init];
    parser.delegate = self;

    if ([parser readFile:file]) {

        NSError *error = nil;
        NSArray *result = [parser parseWithError:&error];
        if (error) {
            DDLogError(@"error = %@", error);
        }
        else {
            DDLogVerbose(@"appearance loaded: %@", result);
            [_definitions addObjectsFromArray:result];
        }
    }
}

- (void)loadAppearanceFromFile:(NSString *)file
{
    [_sources addObject:file];
    [self loadAppearanceData:file];
}

- (void)loadAppearanceNamed:(NSString *)name
{
    NSString *file = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (file) {
        [self loadAppearanceFromFile:file];
    }
}

- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory
{
#if !(TARGET_IPHONE_SIMULATOR)

    [self loadAppearanceNamed:name];

#else

    if([directory hasPrefix:@"~/"]) {
        // we use this trick to locate user directory outside of simulator

        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];

        NSUInteger pos = [path rangeOfString:@"/Library/Application Support/iPhone Simulator/"].location;
        path = [path substringToIndex:pos];

        directory = [path stringByAppendingPathComponent:[directory substringFromIndex:2]];
    }

    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
    
    if(exists && isDirectory) {
        
        NSString* appearancePath = [directory stringByAppendingPathComponent:name];
        
        if(appearancePath && [[NSFileManager defaultManager] fileExistsAtPath:appearancePath]) {
            [self loadAppearanceFromFile:appearancePath withMonitoring:YES];
        }
        else {
           [self loadAppearanceNamed:name];
        }
        
        [self addAssetsFolder:directory withMonitoring:YES];
    }
    else {
        [self loadAppearanceNamed:name];
    }

#endif
}

- (void)reloadAppearanceSources
{
    [_definitions removeAllObjects];
    for (NSString *file in _sources) {
        [self loadAppearanceData:file];
    }
}

- (void)reloadAppearance
{
    [_classStyles removeAllObjects];
    [_objectStyles removeAllObjects];
    [self reloadAppearanceSources];
    [self processAppearance];
}

- (void)autoReloadAppearance
{
    [self reloadAppearance];
    [self performSelector:@selector(reloadAppearance) withObject:nil afterDelay:0.3];
}


- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring
{
    if (monitoring) {
        if (!_monitoredAssets) _monitoredAssets = [NSMutableArray arrayWithCapacity:1];
        [_monitoredAssets addObject:folder];
    }
    else {
        [self addAssetsFolder:folder];
    }
}

- (void)addAssetsFolder:(NSString *)folder
{
    if (!_assets) _assets = [NSMutableArray arrayWithCapacity:1];
    [_assets addObject:folder];
}

- (void)processAppearance
{
    for (NSDictionary *definition in _definitions) {
        [self processISAppearance:definition];
    }
    _isAppearanceLoaded = YES;
    [self updateAppearanceRegisteredObjects];
}

- (void)processUIAppearance:(NSDictionary *)definition
{
    if (![definition isKindOfClass:[NSDictionary class]]) return;

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
            [self processUIAppearanceProxy:appearanceProxy withParams:obj];
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

- (void)processUIAppearanceProxy:(id)appearanceProxy withParams:(NSArray *)params
{
    NSMutableArray *entries = [self styleBlockWithParams:params selectorParams:nil ];
    for (ISAEntry* entry in entries) {
        [entry invokeWithTarget:appearanceProxy];
    }
}

- (void)processISAppearance:(NSDictionary *)definition
{
    if (![definition isKindOfClass:[NSDictionary class]]) return;

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        if ([key isEqual:@"UIAppearance"]) {
            [self processUIAppearance:obj];
            if (_monitoring) {
                [self processISAppearance:obj];
            }
            return;
        }
        if ([key isEqual:@"ISAppearance"]) {
            [self processISAppearance:obj];
            return;
        }

        NSArray *components = [key componentsSeparatedByString:@":"];
        NSString *className = components[0];
        Class baseClass = NSClassFromString(className);
        if (baseClass) {

            // save a
            NSMutableArray *params = [self styleBlockWithParams:obj selectorParams:nil ];

            if (!params) {
                return;
            }

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

- (NSMutableArray *)styleBlockWithParams:(id)params selectorParams:(NSArray *)selectorParams
{
    NSMutableArray *invocations = [NSMutableArray arrayWithCapacity:[params count]];

    if ([params isKindOfClass:[NSDictionary class]]) {
        [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

            ISAEntry * entry= [self entryWithKey:key value:obj selectorParams:selectorParams];
            if(entry) {
                [invocations addObject:entry];
            }
        }];
    }
    else if ([params isKindOfClass:[NSArray class]]) {

        for (id operation in params) {

            if ([operation isKindOfClass:[NSArray class]]) {  // method style

                ISAEntry * entry= [self entryWithParams:operation selectorParams:selectorParams];
                if(entry) {
                    [invocations addObject:entry];
                }
            }
            else if ([operation isKindOfClass:[NSDictionary class]]) {

                [operation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([key isKindOfClass:[NSString class]]) {    // property set style
                        // decode keys
                        ISAEntry * entry= [self entryWithKey:key value:obj selectorParams:selectorParams];
                        if(entry) {
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

- (ISAEntry * const)entryWithKey:(id)key value:(id)value selectorParams:(NSArray *)selectorParams
{
    if([key isKindOfClass:[NSString class]]) {

        NSArray *array;

        NSMutableArray *keys = [key componentsSeparatedByString:@"."].mutableCopy;
        if (keys.count > 1) {
            key = keys.lastObject;
            [keys removeLastObject];
            NSString *keyPath = [keys componentsJoinedByString:@"."];
            array = @[keyPath,@{SelectorNameForSetterWithString(key) : value}];
        }
        else {
            array = @[@{SelectorNameForSetterWithString(key) : value}];
        }

        ISAEntry *const entry = [self entryWithParams:array selectorParams:selectorParams];
        return entry;
    }
    else {
        // error
        return nil;
    }
}

- (ISAEntry * const)entryWithParams:(NSArray *)params selectorParams:(NSArray *)selectorParams
{
    NSMutableString *selectorName = [NSMutableString string];
    NSMutableArray *parameters = [NSMutableArray arrayWithCapacity:[params count]];
    __block NSString *keyPath = nil;

    if (selectorParams) {
        params = [params arrayByAddingObjectsFromArray:selectorParams];
    }
    __block BOOL firstItem = YES;

    for (id component in params) {

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

    return [ISAEntry entryWithSelector:NSSelectorFromString(selectorName)
                             arguments:parameters keyPath:keyPath];;
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
        [self applyAppearanceTo:object usingClasses:[object isaClass]];
    }
    if(_monitoring) {
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
    if(!_isAppearanceLoaded) {
        [self registerObject:target];
        return NO;
    } 
    
    if (_monitoring) {
        [self registerObject:target];
    }

    // apply class styles first
    NSMutableArray *classes = [NSMutableArray array];

    {// find all styles classes
        Class class = [target class];
        while (class) {
            [classes addObject:class];
            class = [class superclass];
        }
    }

    // apply styled classes
    for (Class class in classes.reverseObjectEnumerator) {
        NSArray *classParams = [_classStyles objectForKey:class];
        for (ISAEntry *entry in classParams) {
            [entry invokeWithTarget:target];
        }
    }

    NSSet* userClasses = [NSSet setWithArray:[classNames componentsSeparatedByString:@":"]];

    // apply individual classes
    for (NSString *className in userClasses) {
        for (Class class in classes.reverseObjectEnumerator) {
            NSDictionary *styles = [_objectStyles objectForKey:class];
            NSArray *objectParams = nil;
            if (styles) {
                objectParams = [styles objectForKey:className];

                for (ISAEntry *entry in objectParams) {
                    [entry invokeWithTarget:target];
                }
            }
        }
    }
    // apply individual classes sets

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
                if (path) return path;
            }
        }
    }
    return nil;
}


- (NSString *)findImageFile:(NSString *)file inFolder:(NSString *)folder  forRetina:(BOOL)isRetina forPad:(BOOL)isIpad
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

- (void)watchAndReloadPath:(NSString *)path once:(BOOL)once {
    [self watch:path once:once withCallback:^{
                [self autoReloadAppearance];
            }];
}

- (UIImage *)loadImageNamed:(NSString *)string
{
    bool isRetina = [UIScreen mainScreen].scale == 2.0;
    bool isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;

    UIImage *image = [self loadImageNamed:string forRetina:isRetina forPad:isIpad];
    if (image) return image;

    if (!isRetina) {
        image = [self loadImageNamed:string forRetina:YES forPad:isIpad];
        // scale image
        return image;
    }
    return [UIImage imageNamed:string];
}

@end
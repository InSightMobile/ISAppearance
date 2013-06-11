#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "ISAppearance.h"
#import "YAMLKit.h"
#import "ISAValueConverter.h"
#import "ISAEntry.h"
#import "DDLog.h"

@interface ISAppearance () <YKParserDelegate>


@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;
@end

@implementation ISAppearance {
    NSMutableDictionary *_classStyles;
    NSMutableDictionary *_objectStyles;
    NSMutableArray *_sources;
    id _registeredObjects;
    BOOL _monitoring;
    NSMutableArray *_monitoredAssets;
    NSMutableArray *_assets;
    NSMutableSet *_wachedFiles;
}

+ (ISAppearance *)sharedInstance {
    static ISAppearance *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _classStyles = [NSMutableDictionary dictionary];
        _objectStyles = [NSMutableDictionary dictionary];
        _definitions = [NSMutableArray array];
        _sources = [NSMutableArray array];

        // ensure appearance are supported
        [self swizzle:[UIView class]
                 from:@selector(didMoveToWindow)
                   to:@selector(isaOverride_didMoveToWindow)];
    }
    return self;
}

- (void)swizzle:(Class)class from:(SEL)original to:(SEL)new {
    Method originalMethod = class_getInstanceMethod(class, original);
    Method newMethod = class_getInstanceMethod(class, new);
    if (class_addMethod(class, original, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

- (void)watch:(NSString *)path once:(BOOL)once withCallback:(void (^)())callback {
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
            dispatch_source_cancel(source);
            callback();
        }
        else if (flags & DISPATCH_VNODE_DELETE) {
            dispatch_source_cancel(source);
            callback();
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

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring {
    [self loadAppearanceFromFile:file];
    if (monitoring) {
        _monitoring = YES;
        [self watch:file once:NO withCallback:^{
            [self autoReloadAppearance];
        }];
    }
}

- (YKTag *)parser:(YKParser *)parser tagForURI:(NSString *)uri {
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

- (void)loadAppearanceData:(NSString *)file {
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

- (void)loadAppearanceFromFile:(NSString *)file {
    [_sources addObject:file];
    [self loadAppearanceData:file];
}

- (void)loadAppearanceNamed:(NSString *)name {
    NSString *file = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (file) {
        [self loadAppearanceFromFile:file];
    }
}

- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory {
#if !(TARGET_IPHONE_SIMULATOR)

    [self loadAppearanceNamed:name];

#else
    
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDirectory];
    
    if(exists && isDirectory) {
        
        NSString* appearancePath = [directory stringByAppendingPathComponent:name];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:appearancePath]) {
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

- (void)reloadAppearanceSources {
    [_definitions removeAllObjects];
    for (NSString *file in _sources) {
        [self loadAppearanceData:file];
    }
}

- (void)reloadAppearance {
    [_classStyles removeAllObjects];
    [_objectStyles removeAllObjects];
    [self reloadAppearanceSources];
    [self processAppearance];
    [self updateAppearanceRegisteredObjects];
}

- (void)autoReloadAppearance {
    [self reloadAppearance];
    [self performSelector:@selector(reloadAppearance) withObject:nil afterDelay:0.3];
}


- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring {
    if (monitoring) {
        if (!_monitoredAssets) _monitoredAssets = [NSMutableArray arrayWithCapacity:1];
        [_monitoredAssets addObject:folder];
    }
    else {
        [self addAssetsFolder:folder];
    }
}

- (void)addAssetsFolder:(NSString *)folder {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (!_assets) _assets = [NSMutableArray arrayWithCapacity:1];
    [_assets addObject:folder];
}

- (void)processAppearance {
    for (NSDictionary *definition in _definitions) {

        [self processISAppearance:definition];
    }
}

- (void)processUIAppearance:(NSDictionary *)definition {
    if (![definition isKindOfClass:[NSDictionary class]]) return;

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        id appearanceProxy = nil;
        NSString *className;

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
            [self processAppearanceProxy:appearanceProxy forClassNamed:className withParams:obj];
        }
    }];
}

- (void)processDefinition:(NSDictionary *)definition forClass:(NSString *)class {
    if (!_definitionsByClass)
        _definitionsByClass = [NSMutableDictionary dictionary];

    NSMutableDictionary *classInfo = _definitionsByClass[class];
    if (!classInfo)classInfo = [NSMutableDictionary dictionary];

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

    }];
    _definitionsByClass[class] = classInfo;
}

- (void)processDefinitions:(NSDictionary *)definition {
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

- (void)processAppearanceProxy:(id)appearanceProxy forClassNamed:(NSString *)named withParams:(NSArray *)params {
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

- (BOOL)invokeWithTarget:(id)appearanceProxy selector:(SEL)selector parameters:(NSArray *)parameters {
    [(ISAEntry *) [ISAEntry entryWithSelector:selector arguments:parameters keyPath:0] invokeWithTarget:appearanceProxy];
    return YES;
}


- (void)processISAppearance:(NSDictionary *)definition {
    if (![definition isKindOfClass:[NSDictionary class]]) return;

    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        if ([key isEqual:@"UIAppearance"]) {
            if(_monitoring && NO) {
                [self processISAppearance:obj];
            }
            else {
                [self processUIAppearance:obj];
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
            NSMutableArray *params = [self styleBlockWithParams:obj];

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

- (NSMutableArray *)styleBlockWithParams:(NSArray *)params {
    if (![params isKindOfClass:[NSArray class]]) {
        return nil;
    }

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
                                                     arguments:parameters keyPath:keyPath]];
        }
        else if ([operation isKindOfClass:[NSDictionary class]]) {  // property style

            [operation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                // decode keys
                [invocations addObject:[ISAEntry entryWithSelector:SelectorForPropertySetterFromString(key)
                                                         arguments:@[obj]
                                                           keyPath:nil]];
            }];
        }
    }
    return invocations;
}

- (void)registerObject:(id)object {
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


- (void)updateAppearanceRegisteredObjects {
    for (id object in [_registeredObjects copy]) {
        [self applyAppearanceTo:object usingClasses:[object isaClass]];
    }
    [CATransaction flush];
    UIView *mainView = [[[UIApplication sharedApplication] keyWindow] rootViewController].view;
    // flush view window
    UIView *superview = mainView.superview;
    [mainView removeFromSuperview];
    [superview addSubview:mainView];
}

- (void)applyAppearanceTo:(UIView *)view usingClasses:(NSString *)classNames {
    if (_monitoring) {
        [self registerObject:view];
    }

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

    for (NSString *className in [classNames componentsSeparatedByString:@":"]) {
        if (classes) {
            // apply styled classes
            for (Class class in classes.reverseObjectEnumerator) {
                NSDictionary *styles = [_objectStyles objectForKey:class];
                NSArray *objectParams = nil;
                if (styles) {
                    objectParams = [styles objectForKey:className];

                    for (ISAEntry *entry in objectParams) {
                        [entry invokeWithTarget:view];
                    }
                }
            }
        }
    }
}

- (NSString *)findFile:(NSString *)file inFolder:(NSString *)folder recursive:(BOOL)reqcursive {
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

        NSError *error;
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
                      scale:(CGFloat *)scale {
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

- (UIImage *)loadImageNamed:(NSString *)string forRetina:(BOOL)isRetina forPad:(BOOL)isIpad {
    NSString *path = nil;
    UIImage *image = nil;
    CGFloat scale = 0;
    // find images
    for (NSString *folder in _monitoredAssets) {
        path = [self findImageFile:string inFolder:folder forRetina:isRetina forPad:isIpad scale:&scale];
        if (path) {
            [self watch:path once:YES withCallback:^{
                [self autoReloadAppearance];
            }];
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

- (UIImage *)loadImageNamed:(NSString *)string {
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
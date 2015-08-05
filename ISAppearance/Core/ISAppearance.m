#import "ISAppearance.h"
#import "ISYAML.h"
#import "ISAStyleEntry.h"
#import "ISAStyle.h"
#import "UIViewController+isa_Injection.h"
#import "UIView+isa_Injection.h"
#import "ISAProxy.h"
#import "UIDevice+isa_SystemInfo.h"
#import "NSObject+ISAppearance.h"

#if ISA_CODE_GENERATION
#import "ISAConfig+CodeGeneration.h"
#endif

static const float kAppearanceReloadDelay = 0.25;


@interface ISAppearance ()

@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;

@property(nonatomic, strong) NSMutableDictionary *blocks;

@property(nonatomic, strong) NSMutableDictionary *classStyles;
@property(nonatomic, strong) NSMutableDictionary *objectStyles;

@property(nonatomic, strong) NSMutableArray *UIAppearanceClasses;

- (void)registerGeneratedStyles;
@end


@implementation ISAppearance {
    NSHashTable * _registeredObjects;
    BOOL _isAppearanceLoaded;
    NSMutableSet *_globalStyles;
    NSMutableDictionary *_classesCache;
}

- (void)registerGeneratedStyles {

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
        [self.class prepareAppearance];

        _classesCache = [NSMutableDictionary dictionary];
        _classStyles = [NSMutableDictionary dictionary];
        _objectStyles = [NSMutableDictionary dictionary];
        _definitions = [NSMutableArray array];
        _globalStyles = [NSMutableSet setWithCapacity:6];
        [self addDefaultStyles];
    }
    return self;
}

- (void)addDefaultStyles {
    [self addGlobalStyle:[UIDevice isa_isPad] ? @"iPad" : @"iPhone"];
    [self addGlobalStyle:[UIDevice isa_isPad] ? @"~iPhone" : @"~iPad"];
    [self addGlobalStyle:[UIDevice isa_isIOS7AndLater] ? @"iOS7" : @"~iOS7"];
    [self addGlobalStyle:[UIDevice isa_isIPhone4InchOrBigger] ? @"Phone5" : @"~Phone5"];
    [self addGlobalStyle:[UIDevice isa_isIPhone4InchOrBigger] ? @"iPhone5" : @"~iPhone5"];
    [self addGlobalStyle:[UIDevice isa_isRetina] ? @"Retina" : @"~Retina"];
}

- (void)addGlobalStyle:(NSString *)string {
    [_globalStyles addObjectsFromArray:[string componentsSeparatedByString:@":"]];
}

+ (void)prepareAppearance {
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

- (void)setAppearanceReady:(BOOL)ready {
    if(ready) {
        _isAppearanceLoaded = YES;
        NSHashTable *table = _registeredObjects;
        for (id object in table) {
            [self applyAppearanceTo:object];
        }
        [_registeredObjects removeAllObjects];
    }
}

- (BOOL)applyBlockNamed:(NSString *)blockName toTarget:(id)target {
    NSMutableArray *blockEntries = self.blocks[blockName];

    if (!blockEntries.count) {
        return NO;
    }

    for (ISAStyleEntry *entry in blockEntries) {
        [entry invokeWithTarget:target];
    }

    return YES;
}

- (void)clearCurrentClasses {
    [_classStyles removeAllObjects];
    [_objectStyles removeAllObjects];
    [_classesCache removeAllObjects];
}


- (Class)classForKey:(NSString *)key {
    Class cl = NSClassFromString(key);
    return cl;
}


- (BOOL)isConditionsPassed:(NSArray *)conditions {
    for (NSString *condition in conditions) {
        NSString *negativeCondition;
        if ([condition hasPrefix:@"~"]) {
            negativeCondition = [condition substringFromIndex:1];
        }
        else {
            negativeCondition = [@"~" stringByAppendingString:condition];
        }

        if ([_globalStyles containsObject:negativeCondition]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)checkStyleConformance:(NSArray *)selectors passedSelectors:(NSArray **)pPassedSelectors {

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

- (void)appearanceReady:(BOOL)ready {
    if(ready) {
        _isAppearanceLoaded = YES;

    }
}


- (void)addParams:(NSArray *)params forClass:(Class)baseClass toSelector:(NSArray *)userComponents {
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

- (void)indexStyle:(ISAStyle *)style {
    NSString *className = style.className;
    // save a
    if (style.selectors.count == 0) { // setup class itself
        _classStyles[className] = style;
    }
    else {
        NSMutableDictionary *objectStyles = _objectStyles[className];
        if (!objectStyles) {
            objectStyles = [NSMutableDictionary dictionaryWithCapacity:1];
            _objectStyles[className] = objectStyles;
        }
        objectStyles[style.selectors] = style;

        NSSet *components = style.classSelectors;

        for (NSString *component in components) {
            NSMutableArray *entries = objectStyles[component];
            if (entries) {
                [entries addObject:style];
            }
            else {
                objectStyles[component] = [@[style] mutableCopy];
            }
        }
    }
}

- (ISAStyle *)styleWithClass:(NSString *)className selectors:(NSSet *)components {
    if (components.count == 0) { // setup class itself
        return [_classStyles valueForKey:className];
    }
    else {
        NSMutableDictionary *objectStyles = _objectStyles[className];
        return objectStyles[components];
    }
}

- (void)registerObject:(id)object {
    if (!_registeredObjects) {
        _registeredObjects = [NSHashTable weakObjectsHashTable];
    }
    [_registeredObjects addObject:object];
}


- (BOOL)applyAppearanceTo:(id)target {
    if ([target respondsToSelector:@selector(isaClass)]) {
        return [self applyAppearanceTo:target usingClassesString:[target isaClass]];
    }
    else {
        return [self applyAppearanceTo:target usingClassesString:nil];
    }
}

- (BOOL)applyAppearanceTo:(id)target usingClassesString:(NSString *)classNames {
    NSSet *userClasses = nil;
    if (classNames.length) {
        NSArray *selectors = [classNames componentsSeparatedByString:@":"];
        userClasses = [NSSet setWithArray:selectors];
    }
    return [self applyAppearanceTo:target usingClasses:userClasses];
}

- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSSet *)userClasses {

    if (!userClasses) {
        userClasses = [NSSet set];
    }

    if (!_isAppearanceLoaded) {
        [self registerObject:target];
        return NO;
    }

//    if (_monitoring) {
//        [self registerObject:target];
//    }

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

    if (styles.count) {
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

- (void)addStyleEntry:(ISAStyleEntry *)entry forClass:(Class)aClass andSelector:(NSString *)selectors {
    NSArray *keys = [selectors componentsSeparatedByString:@":"];
    [self addParams:@[entry] forClass:aClass toSelector:keys];
}

- (void)registerProxy:(ISAProxy *)proxy {
}

- (void)unregisterProxy:(ISAProxy *)proxy {
}


@end
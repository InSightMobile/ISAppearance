//
// 



#import "ISAStyle.h"
#import "ISAStyleEntry.h"
#import "ISARuntimeSelector.h"


@implementation ISAStyle {

}

- (id)init {
    self = [super init];
    if (self) {
        self.entries = [NSMutableArray new];
    }
    return self;
}

- (void)addEntries:(NSArray *)array {
    [_entries addObjectsFromArray:array];
}

- (void)applyToTarget:(id)target {
    for (ISARuntimeSelector *selector in _runtimeSelectors) {
        if (![selector isApplyableTo:target]) {
            return;
        }
    }

    for (ISAStyleEntry *entry in _entries) {
        [entry invokeWithTarget:target];
    }
}

- (BOOL)isConformToClassSelectors:(NSSet *)set {
    return [_classSelectors isSubsetOfSet:set];
}

- (void)processSelectors:(NSSet *)selectors {
    NSMutableSet *set = [NSMutableSet setWithCapacity:selectors.count];
    NSMutableArray *runtime = [NSMutableArray new];
    for (NSString *selector in selectors) {

        ISARuntimeSelector *runtimeSelector = [ISARuntimeSelector selectorWithName:selector];
        if (runtimeSelector) {
            [runtime addObject:runtimeSelector];
        }
        else {
            [set addObject:selector];
        }
    }
    self.selectors = [set copy];
    if (runtime.count) {
        self.runtimeSelectors = [runtime copy];
    }
}

- (NSComparisonResult)compare:(ISAStyle *)style {
    NSInteger first = self.selectors.count;
    NSInteger second = style.selectors.count;

    if (first < second) {
        return (NSComparisonResult) NSOrderedAscending;
    }
    else if (first > second) {
        return (NSComparisonResult) NSOrderedDescending;
    }
    else {
        return (NSComparisonResult) NSOrderedSame;
    }
}


- (void)setSelectors:(NSSet *)selectors {
    _selectors = selectors;
    _classSelectors = selectors;
}

@end
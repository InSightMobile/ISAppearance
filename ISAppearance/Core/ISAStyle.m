//
// 



#import "ISAStyle.h"
#import "ISAStyleEntry.h"
#import "ISARuntimeSelector.h"


@implementation ISAStyle
{

}

- (id)init
{
    self = [super init];
    if (self) {
        self.entries = [NSMutableArray new];
    }
    return self;
}

- (void)addEntries:(NSArray *)array
{
    [_entries addObjectsFromArray:array];
}

- (void)applyToTarget:(id)target
{
    for (ISARuntimeSelector* selector in _runtimeSelectors) {
       if(![selector isApplayableTo:target]) {
           return;
       }
    }

    for (ISAStyleEntry *entry in _entries) {
        [entry invokeWithTarget:target];
    }
}

- (BOOL)isConformToClassSelectors:(NSSet *)set
{
    return [_classSelectors isSubsetOfSet:set];
}

- (void)processSelectors:(NSSet *)selectors
{
    self.selectors = selectors;
}

- (void)setSelectors:(NSSet *)selectors
{
    _selectors = selectors;
    _classSelectors = selectors;
}

@end
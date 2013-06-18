//
// 



#import "ISAStyle.h"
#import "ISAStyleEntry.h"


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
    for (ISAStyleEntry *entry in _entries) {
        [entry invokeWithTarget:target];
    }
}

- (BOOL)isConformToSelectors:(NSSet *)set
{
    return [self.selectors isSubsetOfSet:set];
}
@end
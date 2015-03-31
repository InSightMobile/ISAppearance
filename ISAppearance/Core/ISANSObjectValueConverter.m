//
// 

#import "ISANSObjectValueConverter.h"
#if ISA_CODE_GENERATION
#import "ISAValueConverter+CodeGeneration.h"
#endif


@interface ISANSObjectValueConverter ()
@property(nonatomic, strong) Class objectClass;
@end

@implementation ISANSObjectValueConverter
{

}

- (id)initWithObjectClass:(Class)objectClass
{
    self = [super init];
    if (self) {
        if ([objectClass respondsToSelector:@selector(objectWithISANode:)]) {
            self.objectClass = objectClass;
        }
        else {
            return nil;
        }
    }
    return self;
}

- (id)objectWithISANode:(id)node
{
    return [_objectClass objectWithISANode:node];
}

#if ISA_CODE_GENERATION
- (id)codeWithISANode:(id)node
{
    if([_objectClass respondsToSelector:@selector(codeWithISANode:)]) {
        return [ISACode fixCodeForClass:_objectClass value:[_objectClass codeWithISANode:node]];

    }
    else {
        return [ISACode fixCodeForClass:_objectClass value:[_objectClass objectWithISANode:node]];
    }
}
#endif

@end
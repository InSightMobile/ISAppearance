//
// 



#import "ISANSObjectValueConverter.h"


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

- (id)codeWithISANode:(id)node
{
    if([_objectClass respondsToSelector:@selector(codeWithISANode:)]) {
        return [_objectClass codeWithISANode:node];
    }
    else {
        return [_objectClass objectWithISANode:node];
    }
}


@end
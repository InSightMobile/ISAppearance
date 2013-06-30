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


@end
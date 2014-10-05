//
// 

#import "NSObject+ISAObjectCreation.h"
#import "ISAValueConverting.h"

@implementation NSObject (ISAObjectCreation)

+ (id)objectWithISANode:(id)node
{
    id object =  [ISAValueConverter objectOfClass:self.class withISANode:node];
    if(object) {
        return object;
    }
    else {
        return [self new];
    }
}

@end
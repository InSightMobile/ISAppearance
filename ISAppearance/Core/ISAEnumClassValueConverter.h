//
// 



#import <Foundation/Foundation.h>
#import "ISAValueConverting.h"


@interface ISAEnumClassValueConverter : ISAValueConverter

@property(nonatomic, strong) NSDictionary *mapping;

- (id)initWithObjectClass:(Class)objectClass;
@end
//
// 



#import <Foundation/Foundation.h>
#import "ISARuntimeSelector.h"


@interface ISAResponderRuntimeSelector : ISARuntimeSelector

- (BOOL)isApplyableTo:(id)target;

- (id)initWithClassName:(NSString *)name;

@end
//
// 



#import <Foundation/Foundation.h>


@interface ISARuntimeSelector : NSObject

- (BOOL)isApplyableTo:(id)target;

- (id)initWithClassName:(NSString *)name;

+ (id)selectorWithName:(NSString *)selector;

@end
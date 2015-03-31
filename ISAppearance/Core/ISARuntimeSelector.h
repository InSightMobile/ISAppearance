//
// 



#import <Foundation/Foundation.h>


@interface ISARuntimeSelector : NSObject

@property(nonatomic, copy) NSString *name;

+ (id)selectorWithName:(NSString *)name;

- (BOOL)isApplyableTo:(id)target;

@end
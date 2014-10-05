//
// 



#import <Foundation/Foundation.h>


@interface ISARuntimeSelector : NSObject

@property(nonatomic, copy) NSString *name;

- (BOOL)isApplyableTo:(id)target;

- (id)initWithClassName:(NSString *)name;

+ (id)selectorWithName:(NSString *)name;

@end
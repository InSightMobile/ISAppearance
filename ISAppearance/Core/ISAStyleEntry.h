//
// 



#import <Foundation/Foundation.h>


@interface ISAStyleEntry : NSObject

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;
+ (id)entryWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;

- (id)initWithBlock:(void (^)(id))pFunction;

+ (id)entryWithBlock:(void(^)(id object))block;

- (void)invokeWithTarget:(id)target;

@end
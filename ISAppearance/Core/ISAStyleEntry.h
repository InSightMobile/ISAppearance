//
// 



#import <Foundation/Foundation.h>


@interface ISAStyleEntry : NSObject

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;

+ (id)entryWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;

- (id)initWithBlock:(void (^)(id))pFunction;

+ (id)entryWithBlock:(void (^)(id object))block;

+ (ISAStyleEntry *)entryWithKey:(id)key value:(id)value selectorParams:(NSArray *)selectorParams;

+ (ISAStyleEntry *)entryWithParams:(NSArray *)params selectorParams:(NSArray *)selectorParams;

- (id)invokeWithTarget:(id)target;

@end
//
// 



#import <Foundation/Foundation.h>

@class ISACode;


@interface ISAStyleEntry : NSObject

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;

+ (id)entryWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;

- (id)initWithBlock:(void (^)(id))pFunction;

- (instancetype)initWithInvocation:(NSInvocation *)invocation;


+ (id)entryWithBlock:(void (^)(id object))block;

+ (ISAStyleEntry *)entryWithKey:(id)key value:(id)value selectorParams:(NSArray *)selectorParams;

+ (ISAStyleEntry *)entryWithParams:(NSArray *)params selectorParams:(NSArray *)selectorParams;

+ (ISAStyleEntry *)entryWithParams:(NSArray *)params fromIndex:(NSUInteger)index selectorParams:(NSArray *)selectorParams;

- (id)invokeWithTarget:(id)target;

+ (ISAStyleEntry *)entryWithInvocation:(NSInvocation *)invocation;

- (ISACode*)generateCode;

- (ISACode*)codeWithTarget:(id)rootTarget;
@end
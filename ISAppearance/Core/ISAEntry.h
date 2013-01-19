//
// 



#import <Foundation/Foundation.h>


@interface ISAEntry : NSObject

- (id)initWithSelector:(SEL)selector parameters:(NSArray *)parameters keyPath:(NSString *)keyPath;

+ (id)entryWithSelector:(SEL)selector parameters:(NSArray *)parameters keyPath:(NSString *)keyPath;

- (void)invokeWithTarget:(id)target;

@end
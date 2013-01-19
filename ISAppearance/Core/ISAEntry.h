//
// 



#import <Foundation/Foundation.h>


@interface ISAEntry : NSObject

- (id)initWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;
+ (id)entryWithSelector:(SEL)selector arguments:(NSArray *)arguments keyPath:(NSString *)keyPath;

- (void)invokeWithTarget:(id)target;

@end
//
// 



#import <Foundation/Foundation.h>


@interface ISAProxy : NSProxy
+ (ISAProxy *)proxyForClass:(Class)pClass;

+ (ISAProxy *)proxyForClass:(Class)pClass andSelector:(NSString *)selector;
@end
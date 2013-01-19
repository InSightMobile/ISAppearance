//
// 

#import <Foundation/Foundation.h>

@interface ISASwizzler : NSObject

+ (ISASwizzler *)instance;

- (BOOL)swizzle:(Class)class;

@end
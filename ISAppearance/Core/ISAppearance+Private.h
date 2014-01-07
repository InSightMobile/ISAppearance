//
// 



#import <Foundation/Foundation.h>
#import "ISAppearance.h"

@class ISAStyleEntry;
@class ISAProxy;

@interface ISAppearance (Private)

- (void)addStyleEntry:(ISAStyleEntry *)entry forClass:(Class)class andSelector:(NSString *)selectors;

- (UIImage *)loadImageNamed:(NSString *)string;

- (void)registerProxy:(ISAProxy *)proxy;

- (void)unregisterProxy:(ISAProxy *)proxy;

@end
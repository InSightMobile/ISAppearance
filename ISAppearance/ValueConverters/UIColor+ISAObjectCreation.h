//
// 



#import <Foundation/Foundation.h>

@interface UIColor (ISAObjectCreation)
+ (UIColor *)colorWithHexString:(NSString *)hex;

+ (id)colorWithString:(NSString *)node;

+ (id)objectWithISANode:(id)node;
@end
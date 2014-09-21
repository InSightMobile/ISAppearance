//
// 



#import <Foundation/Foundation.h>

@interface UIColor (ISAHexString)

+ (UIColor *)colorWithHexString:(NSString *)hex;

- (NSString *)hexString;

- (NSString *)hexStringWithAlpha;
@end
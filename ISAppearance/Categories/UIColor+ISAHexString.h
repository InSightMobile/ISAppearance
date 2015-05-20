//
// 



#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (ISAHexString)

+ (UIColor *)colorWithHexString:(NSString *)hex;

- (NSString *)hexString;

- (NSString *)hexStringWithAlpha;
@end
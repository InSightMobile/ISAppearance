//
// 



#import <Foundation/Foundation.h>

@interface UIDevice (isa_SystemInfo)

+ (BOOL)isa_isPad;

+ (BOOL)isa_isIPhone4InchOrBigger;

+ (BOOL)isa_isRetina;

+ (BOOL)isa_isIOS7AndLater;

+ (BOOL)isa_isIOS8AndLater;


+ (BOOL)isa_isPhone5 __attribute__ ((deprecated));

+ (BOOL)isa_isIOS7 __attribute__ ((deprecated));

+ (BOOL)isa_isIOS6AndGreater __attribute__ ((deprecated));

@end
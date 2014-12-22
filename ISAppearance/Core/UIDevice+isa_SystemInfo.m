//
// 



#import "UIDevice+isa_SystemInfo.h"


@implementation UIDevice (isa_SystemInfo)

+ (BOOL)isa_isPad
{
    static int result = -1;
    if(result<0) {
        result = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    }
    return result > 0;
}

+ (BOOL)isa_isPhone5
{
    static int result = -1;
    if(result<0) {
        result = !self.isa_isPad && (fabs((double) [[UIScreen mainScreen] bounds].size.height - (double) 568) < DBL_EPSILON );
    }
    return result > 0;
}

+ (BOOL)isa_isIPhone4InchOrBigger
{
    static int result = -1;
    if(result<0) {
        result = !self.isa_isPad && [[UIScreen mainScreen] bounds].size.height >= 568;
    }
    return result > 0;
}

+ (BOOL)isa_isRetina
{
    static int result = -1;
    if(result<0) {
        result = [UIScreen mainScreen].scale == 2.0;
    }
    return result > 0;
}

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


+ (BOOL)isa_isIOS7
{
    return [self isa_isIOS7AndLater];
}

+ (BOOL)isa_isIOS7AndLater
{
#ifdef __IPHONE_7_0
    static int result = -1;
    if(result<0) {
        result = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
    }
    return result > 0;
#else
    return NO;
#endif
}


+ (BOOL)isa_isIOS8AndLater
{
#ifdef __IPHONE_8_0
    static int result = -1;
    if(result<0) {
        result = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
    }
    return result > 0;
#else
    return NO;
#endif
}

+ (BOOL)isa_isPreIOS7
{
    return ![self isa_isIOS7AndLater];
}

+ (BOOL)isa_isIOS6AndGreater
{
#ifdef __IPHONE_6_0
    static int result = -1;
    if(result<0) {
        result = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0");
    }
    return result > 0;
#else
    return NO;
#endif
}

+ (BOOL)isa_isIOS5
{
#ifdef __IPHONE_6_0
    static int result = -1;
    if(result<0) {
        result =  SYSTEM_VERSION_LESS_THAN(@"6.0");
    }
    return result > 0;
#else
    return YES;
#endif
}

@end
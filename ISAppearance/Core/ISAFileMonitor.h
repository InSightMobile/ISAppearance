//
// 



#import <Foundation/Foundation.h>

@interface ISAFileMonitor : NSObject

+(void)watch:(NSString *)path withCallback:(void (^)())callback;

@end
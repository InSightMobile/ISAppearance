//
// 



#import <Foundation/Foundation.h>


@interface ISAppearance : NSObject
+ (ISAppearance *)sharedInstance;

- (void)loadAppearanceFromFile:(NSString *)file;
- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring;

- (void)processAppearance;

- (void)applyAppearanceTo:(UIView *)view usingClasses:(NSString *)classes;

@end
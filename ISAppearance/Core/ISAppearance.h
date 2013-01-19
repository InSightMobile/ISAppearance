//
// 



#import <Foundation/Foundation.h>


@interface ISAppearance : NSObject
+ (ISAppearance *)sharedInstance;

- (void)loadAppearanceFromFile:(NSString *)file;

- (void)processAppearance;

- (void)applyAppearanceTo:(UIView *)view class:(NSString *)class;
@end
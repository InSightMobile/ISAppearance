//
// 



#import <Foundation/Foundation.h>


@interface ISAppearance : NSObject
+ (ISAppearance *)sharedInstance;

-(void)loadAppearanceFromFile:(NSString *)file;

-(void)processAppearance;
@end
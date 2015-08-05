//
// Created by Yaroslav ponomarenko on 05/08/15.
//

#import <UIKit/UIKit.h>

@interface ISAConfig : NSObject

+ (ISAConfig *)sharedInstance;

- (void)loadAppearanceNamed:(NSString *)name;
- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory;
- (BOOL)processAppearance;

@end
//
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <ISAppearance/UIView+ISAInjection.h>

@interface ISAppearance : NSObject
+ (ISAppearance *)sharedInstance;

- (void)loadAppearanceFromFile:(NSString *)file;

+ (void)prepareAppearance;

- (void)loadAppearanceNamed:(NSString *)name;

- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory;

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder;


- (void)processAppearance;


- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSString *)classes;

- (UIImage *)loadImageNamed:(NSString *)string;
@end
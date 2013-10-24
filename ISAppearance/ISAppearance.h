//
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ISAppearance/UIView+ISAInjection.h"

@interface ISAppearance : NSObject
+ (ISAppearance *)sharedInstance;

+ (id)loadDataFromFile:(NSString *)path;

- (void)loadAppearanceFromFile:(NSString *)file;

+ (void)prepareAppearance;

- (void)loadAppearanceNamed:(NSString *)name;

+ (BOOL)isPad;

+ (BOOL)isPhone5;

+ (BOOL)isRetina;

+ (BOOL)isIOS7;

+ (BOOL)isIOS6AndGreater;

- (void)monitorDirectory:(NSString *)directory;

+ (id)loadDataFromFileNamed:(NSString *)string bundle:(NSBundle *)bundle;

- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory;

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder;


- (BOOL)processAppearance;

- (BOOL)processAppearanceWithError:(NSError * __autoreleasing *)error;


- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSString *)classes;

- (UIImage *)loadImageNamed:(NSString *)string;
@end
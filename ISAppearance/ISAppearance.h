//
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ISAppearance/UIView+ISAppearance.h"
#include "ISAppearance/NSObject+ISAppearance.h"

#if TARGET_IPHONE_SIMULATOR
#define ISA_CODE_GENERATION 1
#endif

@interface ISAppearance : NSObject

+ (ISAppearance *)sharedInstance;

+ (void)prepareAppearance;

- (void)loadAppearanceNamed:(NSString *)name;

- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory;


- (BOOL)processAppearance;

- (BOOL)processAppearanceWithError:(NSError * __autoreleasing *)error;


- (BOOL)applyAppearanceTo:(id)target1;

- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSString *)classes;

- (BOOL)applyBlockNamed:(NSString *)block toTarget:(id)target;


+ (BOOL)isPad;

+ (BOOL)isPhone5;

+ (BOOL)isRetina;

+ (BOOL)isIOS7;

+ (BOOL)isIOS5;

+ (BOOL)isIOS6AndGreater;


+ (id)loadDataFromFile:(NSString *)path;

- (void)loadAppearanceFromFile:(NSString *)file;

- (void)monitorDirectory:(NSString *)directory;

+ (id)loadDataFromFileNamed:(NSString *)string bundle:(NSBundle *)bundle;

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder;


- (NSString *)generateCode;

@end
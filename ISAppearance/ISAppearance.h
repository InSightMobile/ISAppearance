//
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ISAppearance/UIView+ISAppearance.h"
#include "ISAppearance/NSObject+ISAppearance.h"

#define ISA_STRINGIZE_IMPL(s) @#s
#define ISA_STRINGIZE(s) ISA_STRINGIZE_IMPL(s)

#define ISA_PATH_FROM_BASE(base,path) (ISA_STRINGIZE_IMPL(base) path)

@interface ISAppearance : NSObject

+ (ISAppearance *)sharedInstance;

+ (void)prepareAppearance;

- (void)loadAppearanceNamed:(NSString *)name;

- (void)loadAppearanceNamed:(NSString *)name withMonitoringForDirectory:(NSString *)directory;


- (BOOL)processAppearance;

- (BOOL)processAppearanceWithError:(NSError * __autoreleasing *)error;


- (BOOL)isConditionsPassed:(NSArray *)conditions;

- (BOOL)applyAppearanceTo:(id)target1;

- (BOOL)applyAppearanceTo:(id)target usingClassesString:(NSString *)classes;

- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSSet *)userClasses;

- (BOOL)applyBlockNamed:(NSString *)block toTarget:(id)target;


+ (id)loadDataFromFile:(NSString *)path;

- (void)loadAppearanceFromFile:(NSString *)file;

- (void)monitorDirectory:(NSString *)directory;

+ (id)loadDataFromFileNamed:(NSString *)string bundle:(NSBundle *)bundle;

- (void)loadAppearanceFromFile:(NSString *)file withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder withMonitoring:(BOOL)monitoring;

- (void)addAssetsFolder:(NSString *)folder;

- (void)processGeneratedAppearance;

// deprecated 

+ (BOOL)isPad __attribute__ ((deprecated));

+ (BOOL)isPhone5 __attribute__ ((deprecated));

+ (BOOL)isRetina __attribute__ ((deprecated));

+ (BOOL)isIOS7 __attribute__ ((deprecated));

+ (BOOL)isIOS6AndGreater __attribute__ ((deprecated));

@end
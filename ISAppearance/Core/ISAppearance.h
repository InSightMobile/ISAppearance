//
// 

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "ISAppearance/UIView+ISAppearance.h"
#include "ISAppearance/NSObject+ISAppearance.h"

#define ISA_STRINGIZE_IMPL(s) @#s
#define ISA_STRINGIZE(s) ISA_STRINGIZE_IMPL(s)

#define ISA_PATH_FROM_BASE(base, path) (ISA_STRINGIZE_IMPL(base) path)

@interface ISAppearance : NSObject

+ (ISAppearance *)sharedInstance;
+ (void)prepareAppearance;

- (BOOL)isConditionsPassed:(NSArray *)conditions;

- (BOOL)applyAppearanceTo:(id)target1;

- (BOOL)applyAppearanceTo:(id)target usingClassesString:(NSString *)classes;

- (BOOL)applyAppearanceTo:(id)target usingClasses:(NSSet *)userClasses;

- (BOOL)applyBlockNamed:(NSString *)block toTarget:(id)target;

@end
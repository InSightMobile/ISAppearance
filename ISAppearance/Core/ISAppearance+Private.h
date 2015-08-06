//
// 



#import <Foundation/Foundation.h>
#import "ISAppearance.h"

@class ISAStyleEntry;
@class ISAProxy;

@interface ISAppearance (Private)

@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;
@property(nonatomic, strong) NSMutableDictionary *blocks;
@property(nonatomic, strong) NSMutableDictionary *classStyles;
@property(nonatomic, strong) NSMutableDictionary *objectStyles;

- (void)addStyleEntry:(ISAStyleEntry *)entry
             forClass:(Class)aClass
          andSelector:(NSString *)selectors;

- (void)addParams:(NSArray *)params forClass:(Class)baseClass toSelector:(NSArray *)userComponents;

- (void)registerProxy:(ISAProxy *)proxy;

- (void)unregisterProxy:(ISAProxy *)proxy;

- (void)clearCurrentClasses;

- (BOOL)checkStyleConformance:(NSArray *)selectors passedSelectors:(NSArray **)pPassedSelectors;

- (void)setAppearanceReady:(BOOL)ready;

@end
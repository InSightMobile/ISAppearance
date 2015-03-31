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

- (void)addStyleEntry:(ISAStyleEntry *)entry forClass:(Class)class

andSelector: (NSString * )
selectors;

- (UIImage *)loadImageNamed:(NSString *)string;

- (void)registerProxy:(ISAProxy *)proxy;

- (void)unregisterProxy:(ISAProxy *)proxy;

- (void)clearCurrentClasses;

@property(nonatomic, strong) NSMutableArray *UIAppearanceClasses;

@end
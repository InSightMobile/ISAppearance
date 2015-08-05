//
// 



#import <Foundation/Foundation.h>
#import "ISAppearance.h"
#import "ISAConfig.h"

@class ISAStyleEntry;
@class ISAProxy;

@interface ISAConfig (Private)

@property(nonatomic, strong) NSMutableArray *definitions;
@property(nonatomic, strong) NSMutableDictionary *definitionsByClass;
@property(nonatomic, strong) NSMutableDictionary *blocks;
@property(nonatomic, strong) NSMutableDictionary *classStyles;
@property(nonatomic, strong) NSMutableDictionary *objectStyles;

- (UIImage *)loadImageNamed:(NSString *)string;
- (void)clearCurrentClasses;

@property(nonatomic, strong) NSMutableArray *UIAppearanceClasses;

- (UIImage *)loadImageNamed:(NSString *)string;

@end
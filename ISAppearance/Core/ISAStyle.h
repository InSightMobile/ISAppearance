//
// 

#import <Foundation/Foundation.h>

@interface ISAStyle : NSObject

@property(strong, nonatomic) NSMutableArray *entries;

@property(nonatomic, strong) Class baseClass;

@property(nonatomic, copy) NSString *className;

@property(nonatomic, copy) NSSet *selectors;
@property(nonatomic, copy) NSArray *runtimeSelectors;
@property(nonatomic, copy) NSSet *classSelectors;

- (void)addEntries:(NSArray *)array;

- (void)applyToTarget:(id)target;

- (BOOL)isConformToClassSelectors:(NSSet *)set;

- (void)processSelectors:(NSSet *)set;

- (NSComparisonResult)compare:(ISAStyle *)style;

@end
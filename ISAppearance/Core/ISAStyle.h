//
// 

#import <Foundation/Foundation.h>

@interface ISAStyle : NSObject

@property (strong, nonatomic) NSMutableArray* entries;

@property(nonatomic, strong) Class baseClass;

@property(nonatomic, copy) NSString *className;

@property(nonatomic, copy) NSSet *selectors;

- (void)addEntries:(NSArray *)array;

- (void)applyToTarget:(id)target;

- (BOOL)isConformToSelectors:(NSSet *)set;
@end
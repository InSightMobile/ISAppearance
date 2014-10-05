//
//

#import <Foundation/Foundation.h>

@class ISACodeEntry;
@class ISACode;


@interface ISACodeManager : NSObject
@property(nonatomic, strong) NSMutableArray *definitions;

+ (ISACodeManager *)instance;

- (ISACodeEntry *)registerCode:(ISACode *)code;

- (NSString *)generateCodeWithSource:(NSString *)code;

- (ISACodeEntry *)entryForName:(NSString *)name;

- (void)addDefinition:(NSString *)definition;
@end
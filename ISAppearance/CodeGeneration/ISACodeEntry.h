//
//

#import <Foundation/Foundation.h>
#import "ISACode.h"

@class ISACode;


@interface ISACodeEntry : NSObject
@property(nonatomic, copy) NSString *name;

@property(nonatomic, readonly) NSString *referenceCode;

+ (ISACodeEntry *)entryWithCode:(ISACode *)code name:(NSString *)name;


+ (NSString *)processCodeWithSource:(NSString *)source withProcessor:(NSString *(^)(ISACodeEntry *entry))processor;

- (void)addCode:(ISACode *)code;

- (BOOL)shouldGeneratedDefinition;
@end
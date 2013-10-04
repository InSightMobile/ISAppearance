//
// 

#import <Foundation/Foundation.h>
#import "ISA_YKTag.h"

@class ISA_YKTag;


@interface ISAValueConverter : NSObject

+ (ISAValueConverter *)converterNamed:(NSString *)className;

+ (id)objectOfClass:(Class)pClass withISANode:(id)node;

- (id)objectWithISANode:(id)node;

- (ISA_YKTag *)parsingTagForURI:(NSString *)uri;

@end
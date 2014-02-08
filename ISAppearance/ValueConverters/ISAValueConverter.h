//
// 

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"

@class ISYAMLTag;


@interface ISAValueConverter : NSObject

+ (ISAValueConverter *)converterNamed:(NSString *)className;

+ (id)objectOfClass:(Class)pClass withISANode:(id)node;

- (id)objectWithISANode:(id)node;

- (ISYAMLTag *)parsingTagForURI:(NSString *)uri;

@end
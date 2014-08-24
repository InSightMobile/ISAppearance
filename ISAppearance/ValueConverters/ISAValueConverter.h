//
// 

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"
#import "ISAppearance.h"
#import "ISACode.h"


@class ISYAMLTag;


@interface ISAValueConverter : NSObject

+ (ISAValueConverter *)converterNamed:(NSString *)className;

+ (id)objectOfClass:(Class)pClass withISANode:(id)node;

- (id)objectWithISANode:(id)node;

- (id)codeWithISANode:(id)node;

- (ISYAMLTag *)parsingTagForURI:(NSString *)uri;

@end
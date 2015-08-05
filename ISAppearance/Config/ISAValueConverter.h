//
// 

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"
#import "ISAppearance.h"
#include "ISAValueConverting.h"


@interface ISAValueConverter : NSObject <ISAValueConverting>

+ (id <ISAValueConverting>)converterNamed:(NSString *)className;

+ (id)objectOfClass:(Class)pClass withISANode:(id)node;

+ (Class)converterClassForTypeName:(NSString *)className;

- (id)objectWithISANode:(id)node;


- (ISYAMLTag *)parsingTagForURI:(NSString *)uri;

@end
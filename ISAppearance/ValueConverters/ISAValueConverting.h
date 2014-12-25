//
// 

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"
#import "ISAppearance.h"

@class ISYAMLTag;

@protocol ISAValueConverting <NSObject>

- (id)objectWithISANode:(id)node;

- (ISYAMLTag *)parsingTagForURI:(NSString *)uri;

@optional
- (id)codeWithISANode:(id)node;
- (id)boxedCodeWithISANode:(id)node;

@end


@interface ISAValueConverter : NSObject<ISAValueConverting>

+ (id<ISAValueConverting>)converterNamed:(NSString *)className;

+ (id)objectOfClass:(Class)pClass withISANode:(id)node;

+ (Class)converterClassForTypeName:(NSString *)className;

- (id)objectWithISANode:(id)node;


- (ISYAMLTag *)parsingTagForURI:(NSString *)uri;

@end
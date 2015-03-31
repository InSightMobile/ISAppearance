//
// Created by Ярослав Пономаренко on 25.12.14.
//

#import <Foundation/Foundation.h>
#import "ISAValueConverter.h"
#import "ISAppearance+CodeGeneration.h"
#import "ISACode.h"

@interface ISAValueConverter (CodeGeneration)

+ (id)codeOfClass:(Class)pClass withISANode:(id)node;
- (id)codeWithISANode:(id)node;
- (id)boxedCodeWithISANode:(id)node;

@end
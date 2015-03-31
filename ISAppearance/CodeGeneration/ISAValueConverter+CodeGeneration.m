//
// Created by Ярослав Пономаренко on 25.12.14.
//

#import "ISAValueConverter+CodeGeneration.h"


@implementation ISAValueConverter (CodeGeneration)


+ (id)codeOfClass:(Class)pClass withISANode:(id)node {
    id result = nil;
    if ([node isKindOfClass:[NSArray class]]) {
        if ([node count] > 0) {
            if ([node[0] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:0 selectorParams:nil];
                result = [entry codeWithTarget:pClass];
            }
            else if ([node count] > 1 && [node[1] isKindOfClass:[NSDictionary class]]) {
                ISAStyleEntry *entry = [ISAStyleEntry entryWithParams:node fromIndex:1 selectorParams:nil];
                result = [entry codeWithTarget:node[0]];
            }
        }
    }
    if (result) {
        return [ISACode fixCodeForClass:pClass value:result];
    }
    return nil;
}

- (id)codeWithISANode:(id)node {
    return [self objectWithISANode:node];
}

- (id)boxedCodeWithISANode:(id)node {
    return nil;
}

@end
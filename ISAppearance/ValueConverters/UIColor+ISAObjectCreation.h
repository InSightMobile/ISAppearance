//
// 



#import <Foundation/Foundation.h>

@interface UIColor (ISAObjectCreation)

+ (id)colorWithString:(NSString *)node;

+ (id)objectWithISANode:(id)node;

#if ISA_CODE_GENERATION
+ (id)codeWithISANode:(id)node;
#endif

@end
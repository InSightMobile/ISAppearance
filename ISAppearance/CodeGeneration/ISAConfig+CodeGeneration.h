//
//

#import <Foundation/Foundation.h>
#import "ISAConfig.h"
#import "ISAStyleEntry.h"

#ifdef ISA_CODE_GENERATION
#define ISA_IS_CODE_GENERATION_MODE ([ISAConfig isCodeGeneration])
#else
#define ISA_IS_CODE_GENERATION_MODE NO
#endif


@class ISACode;

@interface ISAConfig (CodeGeneration)

+ (BOOL)isCodeGeneration;

- (void)generateCodeWithPath:(NSString *)string;

@end

@class ISACode;

@interface ISAStyleEntry (CodeGeneration)
- (ISACode *)generateCode;

- (ISACode *)codeWithTarget:(id)rootTarget;
@end
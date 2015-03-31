//
//

#import <Foundation/Foundation.h>
#import "ISAppearance.h"
#import "ISAStyleEntry.h"

#ifdef ISA_CODE_GENERATION
#define ISA_IS_CODE_GENERATION_MODE ([ISAppearance isCodeGeneration])
#else
#define ISA_IS_CODE_GENERATION_MODE NO
#endif



@class ISACode;

@interface ISAppearance (CodeGeneration)

+ (BOOL)isCodeGeneration;

- (void)generateCodeWithPath:(NSString *)string;
- (void)processGeneratedAppearance;

@end

@class ISACode;

@interface ISAStyleEntry(CodeGeneration)
- (ISACode*)generateCode;
- (ISACode*)codeWithTarget:(id)rootTarget;
@end
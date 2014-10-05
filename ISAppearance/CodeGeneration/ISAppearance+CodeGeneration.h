//
//

#import <Foundation/Foundation.h>
#import "ISAppearance.h"

#define ISA_CODE_GENERATION


#ifdef ISA_CODE_GENERATION
#define ISA_IS_CODE_GENERATION_MODE ([ISAppearance isCodeGeneration])
#else
#define ISA_IS_CODE_GENERATION_MODE NO
#endif

@interface ISAppearance (CodeGeneration)

+ (BOOL)isCodeGeneration;




@end
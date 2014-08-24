//
//

#import "ISAppearance+CodeGeneration.h"
#import "ISAppearance+Private.h"
#import "ISAStyleEntry.h"
#import "ISAStyle.h"
#import "ISACode.h"

static BOOL _codeGenerationMode;

static NSString *_codeTemplate = @""
        "#import \"ISAppearance.h\"\n"
        "@interface ISAppearance(GeneratedStyles)\n"
        "@end\n"
        "@implementation ISAppearance(GeneratedStyles)\n"
        "- (void)registerGeneratedStyles {\n"
        "%@\n"
        "}\n"
        "@end";

@implementation ISAppearance (CodeGeneration)

+ (BOOL)isCodeGeneration
{
    return _codeGenerationMode;
}

- (NSString *)generateCode
{
    _codeGenerationMode = YES;
    [self processAppearance];

    NSMutableArray *classes = [NSMutableArray new];

    [self.classStyles enumerateKeysAndObjectsUsingBlock:^(id key, ISAStyle *style, BOOL *stop) {
        [self processStyleStyle:style resultClasses:classes];
    }];

    [self.objectStyles enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *styles, BOOL *stop) {
        [styles enumerateKeysAndObjectsUsingBlock:^(id key, id styleOrArray, BOOL *stop) {

            if ([styleOrArray isKindOfClass:[NSArray class]]) {

                for (ISAStyle *style in styleOrArray) {
                    [self processStyleStyle:style resultClasses:classes];
                }
            }
            else {
                [self processStyleStyle:styleOrArray resultClasses:classes];
            }
        }];
    }];

    NSString *code = [NSString stringWithFormat:_codeTemplate, [classes componentsJoinedByString:@"\n"]];


    _codeGenerationMode = NO;
    return code;
}

- (void)processStyleStyle:(ISAStyle *)style resultClasses:(NSMutableArray *)classes
{
    NSMutableArray *entryStrings = [NSMutableArray new];
    for (ISAStyleEntry *styleEntry in style.entries) {
        [entryStrings addObject:[self generateCodeForEntry:styleEntry]];
    }
    NSString *styleCode = [entryStrings componentsJoinedByString:@";\n        "];

    NSString *styleSelectors = [style.classSelectors.allObjects componentsJoinedByString:@":"];
    if (style.classSelectors.count == 0) {
        styleSelectors = @"nil";
    }
    else {
        styleSelectors = [NSString stringWithFormat:@"@\"%@\"",styleSelectors];
    }

    NSString *classCode = [NSString stringWithFormat:@"    [%@ isa_appearanceForSelector:%@ withBlock:^(id object) {\n"
                                                             "        %@\n"
                                                             "    }];\n", style.className, styleSelectors, styleCode];

    [classes addObject:classCode];
}

- (id)generateCodeForEntry:(ISAStyleEntry *)entry
{
    ISACode *codeEntry = [entry generateCode];


    return codeEntry.codeString;
}


@end
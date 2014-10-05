//
//

#import "ISAppearance+CodeGeneration.h"
#import "ISAppearance+Private.h"
#import "ISAStyleEntry.h"
#import "ISAStyle.h"
#import "ISACode.h"
#import "ISARuntimeSelector.h"
#import "ISACodeManager.h"

static BOOL _codeGenerationMode;

static NSString *_codeTemplate = @""
        "#import <ISAppearance/ISAppearance.h>\n"
        "%@\n\n"
        "@interface ISAppearance(GeneratedStyles)\n\n"
        "@end\n\n"
        "@implementation ISAppearance(GeneratedStyles)\n\n"
        "- (void)registerGeneratedStyles {\n\n"
        "%@\n\n"
        "%@\n\n"
        "}\n\n"
        "@end";

@implementation ISAppearance (CodeGeneration)

+ (BOOL)isCodeGeneration
{
    return _codeGenerationMode;
}

- (NSString *)generateCodeWithIncludes:(NSArray *)userIncludes
{
    _codeGenerationMode = YES;
    [self clearCurrentClasses];
    [self processAppearance];

    ISACodeManager *manager = [ISACodeManager instance];


    NSMutableArray *classes = [NSMutableArray new];
    NSMutableSet *includes = [NSMutableSet setWithArray:userIncludes];

    for (NSArray *appearance in self.UIAppearanceClasses) {

        ISAStyleEntry *style = appearance[2];

        NSArray *classSelectors = [appearance[1] isKindOfClass:[NSArray class]] ? appearance[1] : nil;
        NSArray *baseKeys = [appearance[3] isKindOfClass:[NSArray class]] ? appearance[3] : nil;

        ISACode *target = nil;
        if (classSelectors.count) {

            NSMutableArray *selCode = [NSMutableArray new];

            for (NSString *sel in classSelectors) {
                [selCode addObject:[NSString stringWithFormat:@"[%@ class]", sel]];
                [self includeClassName:NSStringFromClass(sel) to:includes];
            }

            [self includeClassName:NSStringFromClass(appearance[0]) to:includes];

            target = [ISACode codeWithFormat:
                    @"[%@ appearanceWhenContainedIn:%@,nil]",
                    appearance[0],
                    [selCode componentsJoinedByString:@","]
            ];
        }
        else {
            target = [ISACode codeWithFormat:@"[%@ appearance]", appearance[0]];
        }

        ISACode *code = [style codeWithTarget:target];

        if (baseKeys.count) {

            code = [ISACode codeWithFormat:@"if([self isConditionsPassed:%@]){%@;}", [ISACode codeForArray:baseKeys], code];


        }

        [classes addObject:[NSString stringWithFormat:@"    %@;\n", code.sourceString]];

    }

    [self.classStyles enumerateKeysAndObjectsUsingBlock:^(id key, ISAStyle *style, BOOL *stop) {
        [self processStyleStyle:style resultClasses:classes includes:includes];
    }];

    [self.objectStyles enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary *styles, BOOL *stop) {
        [styles enumerateKeysAndObjectsUsingBlock:^(id key, id styleOrArray, BOOL *stop) {

            if ([styleOrArray isKindOfClass:[NSArray class]]) {

                for (ISAStyle *style in styleOrArray) {
                    [self processStyleStyle:style resultClasses:classes includes:includes];
                }
            }
            else {
                [self processStyleStyle:styleOrArray resultClasses:classes includes:includes];
            }
        }];
    }];


    NSString *sourceCode = [classes componentsJoinedByString:@"\n"];

    NSString *generatedCode = [manager generateCodeWithSource:sourceCode];


    NSString *code = [NSString stringWithFormat:
            _codeTemplate,
            [includes.allObjects componentsJoinedByString:@"\n"],
            [manager.definitions componentsJoinedByString:@"\n\n"],
                    generatedCode];


    _codeGenerationMode = NO;
    [self clearCurrentClasses];
    [self processAppearance];
    return code;
}

- (void)processStyleStyle:(ISAStyle *)style resultClasses:(NSMutableArray *)classes includes:(NSMutableSet *)includes
{
    NSString *className = style.className;

    [self includeClassName:className to:includes];

    NSMutableArray *entryStrings = [NSMutableArray new];
    for (ISAStyleEntry *styleEntry in style.entries) {
        [entryStrings addObject:[NSString stringWithFormat:@"%@;", [self generateCodeForEntry:styleEntry]]];
    }
    NSString *styleCode = [entryStrings componentsJoinedByString:@"\n        "];

    NSMutableArray *selectors = [NSMutableArray new];
    [selectors addObjectsFromArray:style.classSelectors.allObjects];

    for (ISARuntimeSelector *runtimeSelector in style.runtimeSelectors) {
        [selectors addObject:runtimeSelector.name];
    }

    NSString *styleSelectors = [selectors componentsJoinedByString:@":"];
    if (style.classSelectors.count == 0) {
        styleSelectors = @"nil";
    }
    else {
        styleSelectors = [NSString stringWithFormat:@"@\"%@\"", styleSelectors];
    }


    NSString *classCode = [NSString stringWithFormat:@"    [%@ isa_appearanceForSelector:%@ withBlock:^(%@ *object) {\n"
                                                             "        %@\n"
                                                             "    }];\n", className, styleSelectors, className, styleCode];

    [classes addObject:classCode];
}

- (void)includeClassName:(NSString *)className to:(NSMutableSet *)includes
{
    if (![className hasPrefix:@"UI"]) {
        [includes addObject:[NSString stringWithFormat:@"#import \"%@.h\"", className]];
    }
}

- (id)generateCodeForEntry:(ISAStyleEntry *)entry
{
    ISACode *codeEntry = [entry generateCode];

    return codeEntry.sourceString;
}


- (void)generateCodeWithPath:(NSString *)path
{

    NSString *include = [[path.lastPathComponent stringByDeletingPathExtension] stringByAppendingPathExtension:@"h"];


    NSString *code = [self generateCodeWithIncludes:@[[NSString stringWithFormat:@"#import \"%@\"", include]]];
    [code writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:NULL];

}


@end
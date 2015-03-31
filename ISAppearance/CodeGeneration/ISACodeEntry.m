//
//

#import "ISACodeEntry.h"
#import "ISACodeManager.h"


@interface ISACodeEntry ()

@property(nonatomic, copy) NSString *sourceCode;
@property(nonatomic, copy) NSString *className;
@property(nonatomic, strong) Class codeClass;
@property(nonatomic) int codeReferenceCount;
@property(nonatomic) ISACodeFlags flags;
@end

@implementation ISACodeEntry {

    NSString *_referenceCode;
}
- (NSString *)referenceCode {
    if (_referenceCode) {
        return _referenceCode;
    }

    if (self.shouldGeneratedDefinition) {

        _referenceCode = self.name;
        [self generateDefinition];

    }
    else {
        _referenceCode = self.resolvedCode;
    }

    return _referenceCode;
}

- (BOOL)shouldGeneratedDefinition {
    if (self.codeClass == [NSNumber class] ||
            self.codeClass == [NSString class] ||
            (self.flags & ISACodeCached) ||
            (self.flags & ISACodeForceInline)) {
        return NO;
    }
    return YES;
}

- (void)generateDefinition {
    NSString *definition = [NSString stringWithFormat:@"   %@ * const %@ = %@;", self.className, self.name, self.resolvedCode];
    [[ISACodeManager instance] addDefinition:definition];
}

- (NSString *)resolvedCode {
    NSString *generatedCode = [ISACodeEntry processCodeWithSource:self.sourceCode withProcessor:^NSString *(ISACodeEntry *entry) {
        return entry.referenceCode;
    }];
    return generatedCode;
}

+ (ISACodeEntry *)entryWithCode:(ISACode *)code name:(NSString *)name {
    ISACodeEntry *entry = [[self alloc] init];

    entry.codeReferenceCount = 1;
    entry.name = name;
    entry.sourceCode = code.sourceString;
    entry.codeClass = code.codeClass;
    entry.className = NSStringFromClass(code.codeClass);
    entry.flags = code.flags;

    return entry;
}

- (void)addCode:(ISACode *)code {
    self.codeReferenceCount++;
}


+ (NSString *)processCodeWithSource:(NSString *)source withProcessor:(NSString *(^)(ISACodeEntry *entry))processor {
    NSMutableString *generated = [NSMutableString new];

    NSScanner *scanner = [NSScanner scannerWithString:source];
    scanner.charactersToBeSkipped = nil;

    while (!scanner.atEnd) {

        NSString *base = nil;
        NSString *itemName = nil;
        [scanner scanUpToString:@"<?" intoString:&base];
        if ([scanner scanString:@"<?" intoString:NULL]) {
            [scanner scanUpToString:@"?>" intoString:&itemName];
            [scanner scanString:@"?>" intoString:NULL];

            [generated appendString:base];

            ISACodeEntry *entry = [[ISACodeManager instance] entryForName:itemName];
            [generated appendString:processor(entry)];
        }
        else {
            [generated appendString:base];
        }
    }

    return generated;
}

@end
//
//

#import "ISACodeManager.h"
#import "ISACodeEntry.h"


@interface ISACodeManager ()
@property(nonatomic, strong) NSMutableDictionary *entriesByCode;
@property(nonatomic, strong) NSMutableDictionary *entriesByName;
@property(nonatomic) int varIndex;
@end

@implementation ISACodeManager {

}

+ (ISACodeManager *)instance {
    static ISACodeManager *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.entriesByCode = [NSMutableDictionary new];
        self.entriesByName = [NSMutableDictionary new];
        self.definitions = [NSMutableArray new];
    }

    return self;
}

- (NSString *)generateNameForCode:(ISACode *)code {
    self.varIndex++;
    return [NSString stringWithFormat:@"var%d", self.varIndex];
}


- (ISACodeEntry *)registerCode:(ISACode *)code {
    if (!code.codeClass) {
        return nil;
    }


    ISACodeEntry *entry = _entriesByCode[code.sourceString];

    if (!entry) {
        entry = [ISACodeEntry entryWithCode:code name:[self generateNameForCode:code]];
        _entriesByCode[code.sourceString] = entry;
        _entriesByName[entry.name] = entry;
    }
    else {
        [entry addCode:code];
    }
    return entry;
}


- (NSString *)generateCodeWithSource:(NSString *)source {
    return [ISACodeEntry processCodeWithSource:source withProcessor:^NSString *(ISACodeEntry *entry) {
        return [entry referenceCode];
    }];
    return nil;
}

- (ISACodeEntry *)entryForName:(NSString *)name {
    return _entriesByName[name];
}

- (void)addDefinition:(NSString *)definition {
    [_definitions addObject:definition];
}

@end
//
// 

#import <Foundation/Foundation.h>
#import "ISAppearance.h"
#import "YAMLKit.h"
#import "ISConverter.h"

@interface ISAppearance() <YKTagDelegate, YKParserDelegate>


@property (nonatomic,strong)NSMutableArray *definitions;
@end

@implementation ISAppearance
{

}

+ (ISAppearance *)sharedInstance
{
    static ISAppearance *_instance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
    _instance = [[self alloc] init];
});
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _definitions = [NSMutableArray array];

        NSString *definitionsFile = [[NSBundle mainBundle] pathForResource:@"appearanceDefinitions" ofType:@"yaml"];
        if (definitionsFile)
            [self loadAppearanceFromFile:definitionsFile];

        NSString *file = [[NSBundle mainBundle] pathForResource:@"appearance" ofType:@"yaml"];
        if (file)
            [self loadAppearanceFromFile:file];
    }
    return self;
}

- (YKTag *)parser:(YKParser *)parser tagForURI:(NSString *)uri
{
    if (uri.length < 1)return nil;

    YKTag* tag = nil;

    NSString *className = uri;

    if ([className characterAtIndex:0] == '!') {
        className = [className substringFromIndex:1];
    }
    className = [NSString stringWithFormat:@"%@Converter",className];
    Class cl = NSClassFromString(className);
    if (cl) {
        tag = [cl parsingTagForURI:uri];
    }

    return tag;
}

- (void)loadAppearanceFromFile:(NSString *)file
{
    YKParser* parser = [[YKParser alloc] init];
    parser.delegate = self;
    
    if ([parser readFile:file]) {

        NSError *error = nil;
        NSArray * result = [parser parseWithError:&error];
        if(error) {
            NSLog(@"error = %@", error);
        }
        else {
            NSLog(@"result = %@", result);
            [_definitions addObjectsFromArray:result];
        }
    }
}

- (void)processAppearance
{
    for (NSDictionary * definition in _definitions) {

        [self processAppearance:definition];
    }

}

- (void)processAppearance:(NSDictionary *)definition
{
    [definition enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        id appearanceProxy = nil;
        NSString *className;

        if ([key isEqual:@"define"]) {
            [self processDefinitions:(NSDictionary *)obj];
        }

        if ([key isKindOfClass:[NSString class]]) {
            className = key;
            Class cl = NSClassFromString(key);
            if ([cl conformsToProtocol:@protocol(UIAppearance)]) {
                appearanceProxy = [cl appearance];
            }
        }

        if (appearanceProxy) {
            [self processAppearanceProxy:appearanceProxy forClassNamed:className withParams:obj];
        }

    }];
}

- (void)processDefinitions:(NSDictionary *)definition
{


}



SEL SelectorForPropertySetterFromString(NSString *string)
{
    NSString *sel = [string stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                    withString:[[string substringToIndex:1] uppercaseString]];

    sel = [NSString stringWithFormat:@"set%@:",sel];

    return NSSelectorFromString(sel);
}

- (void)processAppearanceProxy:(id)appearanceProxy forClassNamed:(NSString *)named withParams:(NSDictionary*)params
{
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        // try to decode object

        // decode keys
        SEL storeSelector = SelectorForPropertySetterFromString(key);

        @try {
            NSMethodSignature *signature = [appearanceProxy methodSignatureForSelector:storeSelector];

            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.target = appearanceProxy;
            invocation.selector = storeSelector;
            [invocation setArgument:&obj atIndex:2];

            [invocation invoke];

        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }

    }];
}

@end
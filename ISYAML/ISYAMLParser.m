//
//  ISYAMLParser.m
//  ISYAML
//
//  Created by Patrick Thomson on 12/29/08.
//

#import "yaml.h"
#import "ISYAMLParser.h"
#import "ISAMLConstants.h"
#import "ISYAMLNativeTagManager.h"

typedef enum {
    YKParserStateNone,
    YKParserStateDocument,
    YKParserStateMapping,
    YKParserStateSeqence,

} YKParserStates;


@interface YKParserState : NSObject {
    id _node;
    ISYAMLTag *_tag;
    YKParserStates _state;
}
@property(strong, nonatomic) id node;
@property(strong, nonatomic) ISYAMLTag *tag;
@property(nonatomic) YKParserStates state;
@property(nonatomic) BOOL isKey;

@property(nonatomic, copy) NSString *anchor;


- (id)processNode;
@end

@implementation YKParserState

@synthesize node = _node;
@synthesize tag = _tag;
@synthesize state = _state;

- (id)processNode {
    if (_tag) {
        return [_tag processNode:_node];
    }
    else {
        return _node;
    }
}
@end

@interface ISYAMLParser (YKParserPrivateMethods)

- (id)interpretObjectFromEvent:(yaml_event_t)event;

- (NSError *)constructErrorFromParser:(yaml_parser_t *)p;

- (void)destroy;

@end

@interface ISYAMLParser ()

@end

@implementation ISYAMLParser {
    NSMutableDictionary *_aliases;
    BOOL _parserInitialzed;

    BOOL _readyToParse;
    FILE *_fileInput;
    const char *_stringInput;
    void *_opaque_parser;
    NSMutableDictionary *_tagsByName;
    NSMutableDictionary *_explicitTagsByName;
}


- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
        _aliases = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithContext:(NSMutableDictionary *)context {
    self = [super init];
    if (self) {
        [self commonInit];
        _aliases = context;
    }
    return self;
}

- (void)commonInit {
    _opaque_parser = malloc(sizeof(yaml_parser_t));
    if (_opaque_parser) {
        _parserInitialzed = yaml_parser_initialize(_opaque_parser) != 0;
    }

    _tagsByName = [[NSMutableDictionary alloc] initWithDictionary:[[ISYAMLNativeTagManager sharedManager] tagsByName]];
    _explicitTagsByName = [_tagsByName mutableCopy];
}

- (NSArray *)parseString:(NSString *)string parseError:(NSError **)error {
    [self readString:string];
    id result = [self parseWithError:error];
    [self destroy];
    return result;
}

- (NSArray *)parseData:(NSData *)data parseError:(NSError **)error {
    [self readData:data];
    id result = [self parseWithError:error];
    [self destroy];
    return result;
}

- (NSArray *)parseFile:(NSString *)path parseError:(NSError **)error {
    [self readFile:path];
    id result = [self parseWithError:error];
    [self destroy];
    return result;
}

- (void)reset {
    [self destroy];
    _parserInitialzed = yaml_parser_initialize(_opaque_parser) != 0;
}

- (BOOL)readFile:(NSString *)path {
    if (!path || [path isEqualToString:@""]) {
        return FALSE;
    }

    [self reset];

    _fileInput = fopen([path fileSystemRepresentation], "r");
    _readyToParse = ((_fileInput != NULL) && [self prepareParser]);
    if (_readyToParse) {
        yaml_parser_set_input_file(_opaque_parser, _fileInput);
    }
    return _readyToParse;
}

- (BOOL)readData:(NSData *)data {
    if (!data.length) {
        return FALSE;
    }

    [self reset];

    _stringInput = [data bytes];
    _readyToParse = [self prepareParser];
    if (_readyToParse) {
        yaml_parser_set_input_string(_opaque_parser, (const unsigned char *) _stringInput, [data length]);
    }
    return _readyToParse;
}

- (BOOL)readString:(NSString *)str {
    if (!str || [str isEqualToString:@""]) {
        return FALSE;
    }

    [self reset];

    _stringInput = [str UTF8String];
    _readyToParse = [self prepareParser];
    if (_readyToParse) {
        yaml_parser_set_input_string(_opaque_parser, (const unsigned char *) _stringInput, [str length]);
    }
    return _readyToParse;
}

- (BOOL)prepareParser {
    if (!_parserInitialzed) {
        _parserInitialzed = yaml_parser_initialize(_opaque_parser) != 0;
    }
    return _parserInitialzed;
}

- (NSArray *)parse {
    return [self parseWithError:NULL];
}

- (ISYAMLTag *)explicitTagWithString:(NSString *)string {
    ISYAMLTag *tag = nil;

    if (string) {
        tag = [_explicitTagsByName objectForKey:string];
    }

    if (tag) {
        return tag;
    }

    if ([_tagResolver respondsToSelector:@selector(tagForURI:)]) {
        tag = [_tagResolver tagForURI:string];
        if (tag) {
            [_explicitTagsByName setObject:tag forKey:string];
        }
    }

    return tag;
}

- (ISYAMLTag *)tagWithUTF8String:(char *)tagName {
    if (!tagName) {
        return nil;
    }

    NSString *name = [NSString stringWithUTF8String:(const char *) tagName];
    return [self explicitTagWithString:name];
}


- (id)processState:(YKParserState *)state {
    id value = [state processNode];
    if (state.anchor) {
        [_aliases setObject:value forKey:state.anchor];
    }
    return value;
}

- (NSArray *)parseWithError:(NSError **)e {
    if (!_readyToParse) {
        if (e != NULL) {
            *e = [self constructErrorFromParser:NULL];
        }
        return nil;
    }

    yaml_event_t event;
    BOOL done = NO;

    NSMutableArray *documents = [NSMutableArray array];
    NSMutableArray *containerStack = [NSMutableArray array];

    BOOL startNewDocument = FALSE;

    YKParserState *state = [YKParserState new];
    YKParserState *lastState = [YKParserState new];

    while (!done) {
        if (!yaml_parser_parse(_opaque_parser, &event)) {
            if (e != NULL) {
                *e = [self constructErrorFromParser:_opaque_parser];
            }
            // An error occurred, set the stack to null and exit loop
            documents = nil;
            done = TRUE;
        }
        else {
            switch (event.type) {
                case YAML_STREAM_START_EVENT:
                    state.node = nil;
                    break;
                case YAML_STREAM_END_EVENT:
                    state.node = nil;
                    done = TRUE;
                    break;
                case YAML_ALIAS_EVENT:
                    if (event.data.alias.anchor) {
                        NSString *anchor = [NSString stringWithUTF8String:(char *) event.data.sequence_start.anchor];
                        id value = [_aliases objectForKey:anchor];
                        if (value) {
                            state.node = value;
                        }
                        else {
                            state.node = [NSNull null];
                        }
                    }
                    break;
                case YAML_SEQUENCE_START_EVENT:
                    if (event.data.sequence_start.anchor) {
                        state.anchor = [NSString stringWithUTF8String:(char *) event.data.sequence_start.anchor];
                    }
                    state.tag = [self tagWithUTF8String:(char *) event.data.sequence_start.tag];
                    state.node = [NSMutableArray array];
                    state.state = YKParserStateSeqence;
                    [containerStack addObject:lastState];
                    lastState = state;
                    state = [YKParserState new];
                    break;
                case YAML_DOCUMENT_START_EVENT:
                    state.node = documents;
                    state.state = YKParserStateSeqence;
                    state.tag = nil;
                    lastState = state;
                    state = [YKParserState new];
                    break;
                case YAML_MAPPING_START_EVENT:
                    if (event.data.mapping_start.anchor) {
                        state.anchor = [NSString stringWithUTF8String:(char *) event.data.sequence_start.anchor];
                    }
                    state.tag = [self tagWithUTF8String:(char *) event.data.mapping_start.tag];
                    state.node = [NSMutableDictionary dictionary];
                    state.state = YKParserStateMapping;
                    [containerStack addObject:lastState];
                    lastState = state;
                    state = [YKParserState new];
                    break;
                case YAML_SEQUENCE_END_EVENT:
                case YAML_DOCUMENT_END_EVENT:
                case YAML_MAPPING_END_EVENT:
                    state = lastState;
                    lastState = [containerStack lastObject];
                    [containerStack removeLastObject];
                    break;
                case YAML_SCALAR_EVENT:

                    if (event.data.scalar.tag == 0 && lastState.state == YKParserStateMapping) {
                        state.node = [NSString stringWithUTF8String:(const char *) event.data.scalar.value];
                    }
                    else {
                        state.node = [self interpretObjectFromEvent:event];
                    }
                    break;
                case YAML_NO_EVENT:
                default:
                    break;
            }
            if (state.node) {
                if (lastState.isKey) {
                    YKParserState *keyState = lastState;
                    lastState = [containerStack lastObject];
                    [containerStack removeLastObject];
                    [lastState.node setObject:[self processState:state] forKey:[self processState:keyState]];

                    state = [YKParserState new];
                }
                else if (lastState.state == YKParserStateSeqence) {
                    [lastState.node addObject:[self processState:state]];
                    state = [YKParserState new];
                }
                else if (lastState.state == YKParserStateMapping) {
                    state.isKey = YES;
                    [containerStack addObject:lastState];
                    lastState = state;
                    state = [YKParserState new];
                }
                else if (startNewDocument) {
                    [documents addObject:state.node];
                    startNewDocument = FALSE;
                }
            }
        }
        yaml_event_delete(&event);
    }

    // we've reached the end of the stream, nothing additional to parse
    _readyToParse = NO;
    return documents;
}

- (void)addTag:(ISYAMLTag *)tag {
    _tagsByName[tag.verbatim] = tag;
}

- (void)addExplicitTag:(ISYAMLTag *)tag {
    _explicitTagsByName[tag.verbatim] = tag;
}

- (id)interpretObjectFromString:(NSString *)stringValue explicitTag:(NSString *)explicitTagString plain:(BOOL)plain {
    // Special event, if scalar style is not a "plain" style then just return the string representation
    if (explicitTagString == nil && !plain) {
        return stringValue;
    }

    // If an explicit tag was identified, try to cast it from nil, nil means that the implicit tag (or source tag) has
    // not been identified yet
    ISYAMLTag *explicitTag = [self explicitTagWithString:explicitTagString];

    id results = [explicitTag castValue:stringValue fromTag:nil];
    if (results) {
        return results;
    }

    for (ISYAMLTag *resultsTag in [_tagsByName allValues]) {
        if ((results = [resultsTag decodeFromString:stringValue explicitTag:explicitTag])) {
            return results;
        }
    }

    return stringValue;
}

- (id)interpretObjectFromEvent:(yaml_event_t)event {
    NSString *anchor;
    if (event.data.mapping_start.anchor) {
        anchor = [NSString stringWithUTF8String:(char *) event.data.sequence_start.anchor];
    }

    NSString *stringValue = (!event.data.scalar.value ? nil :
            [NSString stringWithUTF8String:(const char *) event.data.scalar.value]);
    NSString *explicitTagString = (!event.data.scalar.tag ? nil :
            [NSString stringWithUTF8String:(const char *) event.data.scalar.tag]);

    id value = [self interpretObjectFromString:stringValue
                                   explicitTag:explicitTagString
                                         plain:event.data.scalar.style == YAML_PLAIN_SCALAR_STYLE];

    if (anchor && value) {

        [_aliases setObject:value forKey:anchor];

    }

    return value;
}


- (NSError *)constructErrorFromParser:(yaml_parser_t *)p {
    int code = 0;
    NSMutableDictionary *data = [NSMutableDictionary dictionary];

    if (p != NULL) {
        // actual parser error
        code = p->error;
        // get the string encoding.
        NSStringEncoding enc = 0;
        switch (p->encoding) {
            case YAML_UTF8_ENCODING:
                enc = NSUTF8StringEncoding;
                break;
            case YAML_UTF16LE_ENCODING:
                enc = NSUTF16LittleEndianStringEncoding;
                break;
            case YAML_UTF16BE_ENCODING:
                enc = NSUTF16BigEndianStringEncoding;
                break;
            default:
                break;
        }
        data[NSStringEncodingErrorKey] = @(enc);

        data[ISYAMLProblemDescriptionKey] = !p->problem ? [NSNull null] : [NSString stringWithUTF8String:p->problem];
        data[ISYAMLProblemOffsetKey] = [NSNumber numberWithInteger:p->problem_offset];
        data[ISYAMLProblemValueKey] = [NSNumber numberWithInteger:p->problem_value];
        data[ISYAMLProblemLineKey] = [NSNumber numberWithInteger:p->problem_mark.line];
        data[ISYAMLProblemIndexKey] = [NSNumber numberWithInteger:p->problem_mark.index];
        data[ISYAMLProblemColumnKey] = [NSNumber numberWithInteger:p->problem_mark.column];

        data[ISYAMLErrorContextDescriptionKey] = !p->context ? [NSNull null] : [NSString stringWithUTF8String:p->context];
        data[ISYAMLErrorContextLineKey] = [NSNumber numberWithInteger:p->context_mark.line];
        data[ISYAMLErrorContextColumnKey] = [NSNumber numberWithInteger:p->context_mark.column];
        data[ISYAMLErrorContextIndexKey] = [NSNumber numberWithInteger:p->context_mark.index];
    }
    else if (_readyToParse) {
        data[NSLocalizedDescriptionKey] = NSLocalizedString(@"Internal assertion failed, possibly due to specially malformed input.", @"");
    }
    else {
        data[NSLocalizedFailureReasonErrorKey] = NSLocalizedString(@"YAML parser was not ready to parse.", @"");
        data[NSLocalizedDescriptionKey] = NSLocalizedString(@"Did you remember to call readFile: or readString:?", @"");
    }

    return [NSError errorWithDomain:ISYAMLErrorDomain code:code userInfo:data];
}

- (void)destroy {
    _stringInput = nil;
    if (_fileInput) {
        fclose(_fileInput);
        _fileInput = NULL;
    }
    if (_parserInitialzed) {
        yaml_parser_delete(_opaque_parser);
        _parserInitialzed = NO;
    }
}


- (void)dealloc {
    _tagsByName = nil;
    _explicitTagsByName = nil;
    [self destroy];
    free(_opaque_parser), _opaque_parser = nil;
}

@end

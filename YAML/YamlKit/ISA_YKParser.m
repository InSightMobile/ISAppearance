//
//  ISA_YKParser.m
//  ISA_YAMLKit
//
//  Created by Patrick Thomson on 12/29/08.
//

#import "yaml.h"
#import "ISA_YKParser.h"
#import "YKConstants.h"
#import "ISA_YKNativeTagManager.h"

typedef enum
{
    YKParserStateNone,
    YKParserStateDocument,
    YKParserStateMapping,
    YKParserStateSeqence,

} YKParserStates;


@interface YKParserState : NSObject
{
    id _node;
    ISA_YKTag *_tag;
    YKParserStates _state;
}
@property(strong, nonatomic) id node;
@property(strong, nonatomic) ISA_YKTag *tag;
@property(nonatomic) YKParserStates state;
@property(nonatomic) BOOL isKey;

@property(nonatomic, copy) NSString *anchor;


- (id)processNode;
@end

@implementation YKParserState

@synthesize node = _node;
@synthesize tag = _tag;
@synthesize state = _state;

- (id)processNode
{
    if (_tag) {
        return [_tag processNode:_node];
    }
    else {
        return _node;
    }
}
@end

@interface ISA_YKParser (YKParserPrivateMethods)

- (id)interpretObjectFromEvent:(yaml_event_t)event;

- (NSError *)_constructErrorFromParser:(yaml_parser_t *)p;

- (void)_destroy;

@end

@implementation ISA_YKParser
{
    NSMutableDictionary *_aliases;
}

@synthesize isReadyToParse = readyToParse;
@synthesize tagsByName;

- (id)init
{
    if (!(self = [super init]))
        return nil;

    opaque_parser = malloc(sizeof(yaml_parser_t));
    if (!opaque_parser || !yaml_parser_initialize(opaque_parser)) {
        return nil;
    }

    tagsByName = [[NSMutableDictionary alloc] initWithDictionary:[[ISA_YKNativeTagManager sharedManager] tagsByName]];
    _explicitTagsByName = [tagsByName mutableCopy];

    _aliases = [NSMutableDictionary dictionary];

    return self;
}

- (void)reset
{
    [self _destroy];
    yaml_parser_initialize(opaque_parser);
}

- (BOOL)readFile:(NSString *)path
{
    if (!path || [path isEqualToString:@""])
        return FALSE;

    [self reset];
    fileInput = fopen([path fileSystemRepresentation], "r");
    readyToParse = ((fileInput != NULL) && (yaml_parser_initialize(opaque_parser)));
    if (readyToParse)
        yaml_parser_set_input_file(opaque_parser, fileInput);
    return readyToParse;
}

- (BOOL)readString:(NSString *)str
{
    if (!str || [str isEqualToString:@""])
        return FALSE;

    [self reset];
    stringInput = [str UTF8String];
    readyToParse = yaml_parser_initialize(opaque_parser);
    if (readyToParse)
        yaml_parser_set_input_string(opaque_parser, (const unsigned char *) stringInput, [str length]);
    return readyToParse;
}

- (NSArray *)parse
{
    return [self parseWithError:NULL];
}

- (ISA_YKTag *)explicitTagWithString:(NSString *)string
{
    ISA_YKTag *tag = nil;
    
    if(string) {
        tag = [_explicitTagsByName objectForKey:string];
    }

    if (tag) return tag;

    if ([_delegate respondsToSelector:@selector(parser:tagForURI:)]) {
        tag = [_delegate parser:self tagForURI:string];
        if (tag)
            [_explicitTagsByName setObject:tag forKey:string];
    }

    return tag;
}

- (ISA_YKTag *)tagWithUTF8String:(char *)tagName
{
    if (!tagName)return nil;

    NSString *name = [NSString stringWithUTF8String:(const char *) tagName];
    return [self explicitTagWithString:name];
}


- (id)processState:(YKParserState *)state
{
    id value = [state processNode];
    if (state.anchor) {
        [_aliases setObject:value forKey:state.anchor];
    }
    return value;
}

- (NSArray *)parseWithError:(NSError **)e
{
    if (!readyToParse) {
        if (e != NULL)
            *e = [self _constructErrorFromParser:NULL];
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
        if (!yaml_parser_parse(opaque_parser, &event)) {
            if (e != NULL) {
                *e = [self _constructErrorFromParser:opaque_parser];
            }
            // An error occurred, set the stack to null and exit loop
            documents = nil;
            done = TRUE;
        } else {
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
                        NSString *anchor = [NSString stringWithUTF8String:event.data.sequence_start.anchor];
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
                        state.anchor = [NSString stringWithUTF8String:event.data.sequence_start.anchor];
                    }
                    state.tag = [self tagWithUTF8String:event.data.sequence_start.tag];
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
                        state.anchor = [NSString stringWithUTF8String:event.data.sequence_start.anchor];
                    }
                    state.tag = [self tagWithUTF8String:event.data.mapping_start.tag];
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

                    if (event.data.scalar.tag == 0 && lastState.state == YKParserStateMapping)
                        state.node = [NSString stringWithUTF8String:(const char *) event.data.scalar.value];
                    else
                        state.node = [self interpretObjectFromEvent:event];
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
    readyToParse = NO;
    return documents;
}

- (void)addTag:(ISA_YKTag *)tag
{
    [tagsByName setObject:tag forKey:[tag verbatim]];
}

- (void)addExplicitTag:(ISA_YKTag *)tag
{
    [_explicitTagsByName setObject:tag forKey:[tag verbatim]];
}

- (id)interpretObjectFromString:(NSString *)stringValue explicitTag:(NSString *)explicitTagString plain:(BOOL)plain
{
    // Special event, if scalar style is not a "plain" style then just return the string representation
    if (explicitTagString == nil && !plain)
        return stringValue;

    // If an explicit tag was identified, try to cast it from nil, nil means that the implicit tag (or source tag) has
    // not been identified yet
    ISA_YKTag *explicitTag = [self explicitTagWithString:explicitTagString];

    id results = [explicitTag castValue:stringValue fromTag:nil];
    if (results)
        return results;

    for (ISA_YKTag *resultsTag in [tagsByName allValues]) {
        if ((results = [resultsTag decodeFromString:stringValue explicitTag:explicitTag]))
            return results;
    }

    return stringValue;
}

- (id)interpretObjectFromEvent:(yaml_event_t)event
{
    NSString *anchor;
    if (event.data.mapping_start.anchor) {
        anchor = [NSString stringWithUTF8String:event.data.sequence_start.anchor];
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


- (NSError *)_constructErrorFromParser:(yaml_parser_t *)p
{
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
        [data setObject:[NSNumber numberWithInteger:enc] forKey:NSStringEncodingErrorKey];

        [data setObject:(!p->problem ? [NSNull null] : [NSString stringWithUTF8String:p->problem])
                 forKey:YKProblemDescriptionKey];
        [data setObject:[NSNumber numberWithInteger:p->problem_offset] forKey:YKProblemOffsetKey];
        [data setObject:[NSNumber numberWithInteger:p->problem_value] forKey:YKProblemValueKey];
        [data setObject:[NSNumber numberWithInteger:p->problem_mark.line] forKey:YKProblemLineKey];
        [data setObject:[NSNumber numberWithInteger:p->problem_mark.index] forKey:YKProblemIndexKey];
        [data setObject:[NSNumber numberWithInteger:p->problem_mark.column] forKey:YKProblemColumnKey];

        [data setObject:(!p->context ? [NSNull null] : [NSString stringWithUTF8String:p->context])
                 forKey:YKErrorContextDescriptionKey];
        [data setObject:[NSNumber numberWithInteger:p->context_mark.line] forKey:YKErrorContextLineKey];
        [data setObject:[NSNumber numberWithInteger:p->context_mark.column] forKey:YKErrorContextColumnKey];
        [data setObject:[NSNumber numberWithInteger:p->context_mark.index] forKey:YKErrorContextIndexKey];
    } else if (readyToParse) {
        [data setObject:NSLocalizedString(@"Internal assertion failed, possibly due to specially malformed input.", @"") forKey:NSLocalizedDescriptionKey];
    } else {
        [data setObject:NSLocalizedString(@"YAML parser was not ready to parse.", @"") forKey:NSLocalizedFailureReasonErrorKey];
        [data setObject:NSLocalizedString(@"Did you remember to call readFile: or readString:?", @"") forKey:NSLocalizedDescriptionKey];
    }

    return [NSError errorWithDomain:YKErrorDomain code:code userInfo:data];
}

- (void)_destroy
{
    stringInput = nil;
    if (fileInput) {
        fclose(fileInput);
        fileInput = NULL;
    }
    yaml_parser_delete(opaque_parser);
}


- (void)dealloc
{
    tagsByName = nil;
    _explicitTagsByName = nil;
    [self _destroy];
    free(opaque_parser), opaque_parser = nil;
}

@end

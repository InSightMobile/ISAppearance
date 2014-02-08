//
//  ISYAMLTag.m
//  ISYAML
//
//  Created by Faustino Osuna on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ISYAMLTag.h"
//#import "RegexKitLite.h"
#import "ISYAMLUnknownNode.h"

@interface ISYAMLTag (YKTagPrivateMethods)

// Following method is used for internal subclasses.  This method allows for subclasses to determine how a stringValue
// should be decoded.  This method is called from -decodeFromString:explicitTag:.  -decodeFromString:explictTag: attempts
// to decode a string value using -internalDecodeFromString:extraInfo:, if a value was successfully decoded it then
// attempts to cast the value (if an explicitTag was specified) using -castValue:toTag:.  If -castValue:toTag: is unsuccessful
// then -castValue:toTag: attempts to call the explicit's tag -castValue:fromTag:.  If the explicit tag does not return a value
// then the system cannot cast and the value is returned as an ISYAMLUnknownNode vice a native scalar value.
- (id)internalDecodeFromString:(NSString *)stringValue extraInfo:(NSDictionary *)extraInfo;

@end

@implementation ISYAMLTag
{
    NSString *verbatim;
    NSString *shorthand;
    id <ISYAMLTagDelegate> __weak delegate;
}

- (id)initWithURI:(NSString *)aURI delegate:(id <ISYAMLTagDelegate>)aDelegate
{
    if (!aURI) {
        return nil;
    }

    if (!(self = [super init])) {
            return nil;
    }

    verbatim = [aURI copy];
    shorthand = [[[aURI componentsSeparatedByString:@":"] lastObject] copy];
    delegate = aDelegate;

    return self;
}

- (void)dealloc
{
    verbatim = nil;
    shorthand = nil;
    delegate = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), verbatim];
}

- (id)decodeFromString:(NSString *)stringValue explicitTag:(ISYAMLTag *)explicitTag
{
    // If string cannot be decoded, nil is returned.  If the string was decoded and cannot be casted, YKUknownNode is returned
    id resultingValue = [self internalDecodeFromString:stringValue
                                             extraInfo:[NSDictionary dictionaryWithObject:(explicitTag ? (id) explicitTag : (id) [NSNull null])
                                                                                   forKey:@"explicitTag"]];
    if (!resultingValue || !explicitTag || self == explicitTag) {
            return resultingValue;
    }

    id castedValue = [self castValue:resultingValue toTag:explicitTag];
    if (castedValue) {
            return castedValue;
    }

    return [ISYAMLUnknownNode unknownNodeWithStringValue:stringValue implicitTag:self explicitTag:explicitTag
                                                position:ISYAMLMakeRange(ISYAMLMakeMark(0, 0, 0), ISYAMLMakeMark(0, 0, 0))];
}

- (id)internalDecodeFromString:(NSString *)stringValue extraInfo:(NSDictionary *)extraInfo
{
    id result = nil;

    if (result) {
            return result;
    }

    if (![delegate respondsToSelector:@selector(tag:decodeFromString:extraInfo:)]) {
            return nil;
    }

    return [(id <ISYAMLTagDelegate>) delegate tag:self decodeFromString:stringValue extraInfo:extraInfo];
}

- (id)castValue:(id)value fromTag:(ISYAMLTag *)castingTag
{
    id result = nil;
    if (!castingTag) {
        if ([delegate respondsToSelector:@selector(tag:processNode:extraInfo:)]) {
            result = [delegate tag:self processNode:value extraInfo:nil];
        }
    }
    if (result) {
            return result;
    }

    if (![delegate respondsToSelector:@selector(tag:castValue:fromTag:)]) {
            return nil;
    }
    return [(id <ISYAMLTagDelegate>) delegate tag:self castValue:value fromTag:castingTag];
}

- (id)castValue:(id)value toTag:(ISYAMLTag *)castingTag
{

    id resultingValue = [castingTag castValue:value fromTag:self];
    if (resultingValue) {
            return resultingValue;
    }

    if (![delegate respondsToSelector:@selector(tag:castValue:toTag:)]) {
            return nil;
    }
    return [(id <ISYAMLTagDelegate>) delegate tag:self castValue:value toTag:castingTag];
}

@synthesize verbatim;

- (id)processNode:(id)node
{
    if (![delegate respondsToSelector:@selector(tag:processNode:extraInfo:)]) {
        return node;
    }
    id result = [(id <ISYAMLTagDelegate>) delegate tag:self processNode:node extraInfo:nil];
    if (!result) {

        //return node;
    }
    return result;
}

@synthesize shorthand;
@synthesize delegate;

@end

@interface ISYAMLRegexTag (YKRegexTagPrivateMethods)

- (NSArray *)findRegexThatMatchesStringValue:(NSString *)stringValue hint:(id *)hint;

@end

@implementation ISYAMLRegexTag : ISYAMLTag

- (id)initWithURI:(NSString *)aURI delegate:(id <ISYAMLTagDelegate>)aDelegate
{
    if (!(self = [super initWithURI:aURI delegate:aDelegate])) {
            return nil;
    }

    regexDeclarations = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc
{
    regexDeclarations = nil;
}

- (void)addRegexDeclaration:(NSString *)regex hint:(id)hint
{
    [regexDeclarations setValue:(hint ? hint : [NSNull null]) forKey:regex];
}

- (id)internalDecodeFromString:(NSString *)stringValue extraInfo:(NSDictionary *)extraInfo
{
    id hint = nil;
    NSArray *components = [self findRegexThatMatchesStringValue:stringValue hint:&hint];
    if (!components) {
            return nil;
    }

    NSMutableDictionary *scopeMutableExtraInfo = [NSMutableDictionary dictionaryWithDictionary:extraInfo];
    [scopeMutableExtraInfo setValue:components forKey:@"components"];
    [scopeMutableExtraInfo setValue:(hint ? hint : [NSNull null]) forKey:@"hint"];
    NSDictionary *scopeExtraInfo = [NSDictionary dictionaryWithDictionary:scopeMutableExtraInfo];

    return [super internalDecodeFromString:stringValue extraInfo:scopeExtraInfo];
}

- (NSArray *)arrayOfCaptureComponentsFrom:(NSString *)string matchedByRegex:(NSString *)regexp
{
    NSError *error = NULL;

    NSRegularExpression *regex = [NSRegularExpression
            regularExpressionWithPattern:regexp
                                 options:0
                                   error:&error];

    NSMutableArray *array = [NSMutableArray new];
    [regex enumerateMatchesInString:string options:0 range:NSMakeRange(0, string.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

        [array addObject:[string substringWithRange:result.range]];

    }];
    return array;
}

- (NSArray *)findRegexThatMatchesStringValue:(NSString *)stringValue hint:(id *)hint
{
    NSArray *components = nil;
    for (NSString *regex in regexDeclarations) {

        components = [self arrayOfCaptureComponentsFrom:stringValue matchedByRegex:regex];
        if ([components count] > 0) {
            if (hint) {
                            *hint = [regexDeclarations valueForKey:regex];
            }
            return components;
        }
    }
    return nil;
}

@end



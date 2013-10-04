//
//  ISA_YAMLKit.m
//  ISA_YAMLKit
//
//  Created by Patrick Thomson on 12/30/08.
//  Copyright 2008 Patrick Thomson. All rights reserved.
//

#import "ISA_YAMLKit.h"

@implementation ISA_YAMLKit

#pragma mark Parser
+ (id)loadFromString:(NSString *)str
{
    if (!str || [str isEqualToString:@""])
        return nil;

    ISA_YKParser *p = [[ISA_YKParser alloc] init];
    [p readString:str];

    NSArray *result = [p parse];
    // If parse returns a one-element array, extract it.
    if ([result count] == 1) {
        return [result objectAtIndex:0];
    }
    return result;
}

+ (id)loadFromFile:(NSString *)path
{
    if (!path || [path isEqualToString:@""])
        return nil;

    ISA_YKParser *p = [[ISA_YKParser alloc] init];
    [p readFile:path];

    NSArray *result = [p parse];
    // If parse returns a one-element array, extract it.
    if ([result count] == 1) {
        return [result objectAtIndex:0];
    }
    return result;
}

+ (id)loadFromURL:(NSURL *)url
{
    if (!url)
        return nil;

    NSString *contents = [NSString stringWithContentsOfURL:url
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    if (contents == nil) return nil; // if there was an error reading from the URL
    return [self loadFromString:contents];
}

#pragma mark Emitter
+ (NSString *)dumpObject:(id)object
{
    ISA_YKEmitter *e = [[ISA_YKEmitter alloc] init];
    [e emitItem:object];
    return [e emittedString];
}

+ (BOOL)dumpObject:(id)object toFile:(NSString *)path
{
    ISA_YKEmitter *e = [[ISA_YKEmitter alloc] init];
    [e emitItem:object];
    return [[e emittedString] writeToFile:path
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:NULL];
}

+ (BOOL)dumpObject:(id)object toURL:(NSURL *)path
{
    ISA_YKEmitter *e = [[ISA_YKEmitter alloc] init];
    [e emitItem:object];
    return [[e emittedString] writeToURL:path
                              atomically:YES
                                encoding:NSUTF8StringEncoding
                                   error:NULL];
}

@end

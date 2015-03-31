//
//  ISYAML.m
//  ISYAML
//
//  Created by Patrick Thomson on 12/30/08.
//  Copyright 2008 Patrick Thomson. All rights reserved.
//

#import "ISYAML.h"

@implementation ISYAML

#pragma mark Parser
+ (id)loadFromString:(NSString *)str
{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }

    ISYAMLParser *p = [[ISYAMLParser alloc] init];
    NSArray *result = [p parseString:str parseError:NULL ];

    // If parse returns a one-element array, extract it.
    if ([result count] == 1) {
        return [result objectAtIndex:0];
    }
    return result;
}

+ (id)loadDataFromFileNamed:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error
{
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }

    NSString *ext = [name pathExtension];
    if (!ext.length) {
        ext = @"yaml";
    }

    NSString *path = [bundle pathForResource:[name stringByDeletingPathExtension]
                                      ofType:ext];


    return [self loadFromFile:path error:error];
}


+ (id)loadFromFile:(NSString *)path error:(NSError **)error
{
    if (!path || [path isEqualToString:@""]) {
        return nil;
    }

    ISYAMLParser *p = [[ISYAMLParser alloc] init];

    NSError *parseError = nil;

    NSArray *result = [p parseFile:path parseError:&parseError];
    // If parse returns a one-element array, extract it.

    if (parseError) {
        NSLog(@"parsing failed with error: %@", parseError);

        if (error) {
            *error = parseError;
        }
        return nil;
    }

    if ([result count] == 1) {
        return [result objectAtIndex:0];
    }
    return result;
}

+ (id)loadFromURL:(NSURL *)url
{
    if (!url) {
        return nil;
    }

    NSString *contents = [NSString stringWithContentsOfURL:url
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    if (contents == nil) {
        return nil;
    } // if there was an error reading from the URL
    return [self loadFromString:contents];
}

#pragma mark Emitter
+ (NSString *)dumpObject:(id)object
{
    ISYAMLEmitter *e = [[ISYAMLEmitter alloc] init];
    [e emitItem:object];
    return [e emittedString];
}

+ (BOOL)dumpObject:(id)object toFile:(NSString *)path
{
    ISYAMLEmitter *e = [[ISYAMLEmitter alloc] init];
    [e emitItem:object];
    return [[e emittedString] writeToFile:path
                               atomically:YES
                                 encoding:NSUTF8StringEncoding
                                    error:NULL];
}

+ (BOOL)dumpObject:(id)object toURL:(NSURL *)path
{
    ISYAMLEmitter *e = [[ISYAMLEmitter alloc] init];
    [e emitItem:object];
    return [[e emittedString] writeToURL:path
                              atomically:YES
                                encoding:NSUTF8StringEncoding
                                   error:NULL];
}

@end

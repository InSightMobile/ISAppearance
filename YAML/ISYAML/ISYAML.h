/*
 *  ISYAML.h
 *  ISYAML
 *
 *  Based on YAMLKit
 *  Created by Patrick Thomson on 12/29/08.
 *  Copyright 2008 Patrick Thomson. All rights reserved.
 *
 */

#import "ISAMLConstants.h"
#import "ISYAMLTag.h"
#import "ISYAMLUnknownNode.h"
#import "ISYAMLParser.h"
#import "ISYAMLEmitter.h"


@interface ISYAML : NSObject

#pragma mark Parser
+ (id)loadFromString:(NSString *)aString;

+ (id)loadDataFromFileNamed:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)error;

+ (id)loadFromFile:(NSString *)path error:(NSError **)error;

+ (id)loadFromURL:(NSURL *)url;

#pragma mark Emitter

+ (NSString *)dumpObject:(id)object;

+ (BOOL)dumpObject:(id)object toFile:(NSString *)path;

+ (BOOL)dumpObject:(id)object toURL:(NSURL *)path;

@end

@compatibility_alias ISA_YAMLKit ISYAML;

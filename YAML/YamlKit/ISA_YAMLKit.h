/*
 *  YAMLKit.h
 *  YAMLKit
 *
 *  Created by Patrick Thomson on 12/29/08.
 *  Copyright 2008 Patrick Thomson. All rights reserved.
 *
 */

#import "NSData+ISA_Base64.h"
#import "YKConstants.h"
#import "ISA_YKTag.h"
#import "ISA_YKUnknownNode.h"
#import "ISA_YKParser.h"
#import "ISA_YKEmitter.h"

@interface ISA_YAMLKit : NSObject
{
}

#pragma mark Parser
+ (id)loadFromString:(NSString *)aString;

+ (id)loadFromFile:(NSString *)path error:(NSError **)error;

+ (id)loadFromURL:(NSURL *)url;

#pragma mark Emitter
+ (NSString *)dumpObject:(id)object;

+ (BOOL)dumpObject:(id)object toFile:(NSString *)path;

+ (BOOL)dumpObject:(id)object toURL:(NSURL *)path;

@end

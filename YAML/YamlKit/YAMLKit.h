/*
 *  YAMLKit.h
 *  YAMLKit
 *
 *  Created by Patrick Thomson on 12/29/08.
 *  Copyright 2008 Patrick Thomson. All rights reserved.
 *
 */

#import "NSData+Base64.h"
#import "YKConstants.h"
#import "YKTag.h"
#import "YKUnknownNode.h"
#import "YKParser.h"
#import "YKEmitter.h"

@interface YAMLKit : NSObject {
}

#pragma mark Parser
+ (id)loadFromString:(NSString *)aString;
+ (id)loadFromFile:(NSString *)path;
+ (id)loadFromURL:(NSURL *)url;

#pragma mark Emitter
+ (NSString *)dumpObject:(id)object;
+ (BOOL)dumpObject:(id)object toFile:(NSString *)path;
+ (BOOL)dumpObject:(id)object toURL:(NSURL *)path;

@end

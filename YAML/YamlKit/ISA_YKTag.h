//
//  ISA_YKTag.h
//  ISA_YAMLKit
//
//  Created by Faustino Osuna on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISA_YKTag;

@protocol YKTagDelegate <NSObject>

- (id)tag:(ISA_YKTag *)tag decodeFromString:(NSString *)stringValue extraInfo:(NSDictionary *)extraInfo;

- (id)tag:(ISA_YKTag *)tag castValue:(id)value fromTag:(ISA_YKTag *)castingTag;

- (id)tag:(ISA_YKTag *)tag castValue:(id)value toTag:(ISA_YKTag *)castingTag;

- (id)tag:(ISA_YKTag *)tag processNode:(id)node extraInfo:(NSDictionary *)extraInfo;

@end

@interface ISA_YKTag : NSObject
{
    NSString *verbatim;
    NSString *shorthand;
    id <YKTagDelegate> __weak delegate;
}

- (id)initWithURI:(NSString *)aURI delegate:(id <YKTagDelegate>)aDelegate;

- (id)decodeFromString:(NSString *)stringValue explicitTag:(ISA_YKTag *)explicitTag;

- (id)castValue:(id)value fromTag:(ISA_YKTag *)castingTag;

- (id)castValue:(id)value toTag:(ISA_YKTag *)castingTag;

@property(readonly) NSString *verbatim;

- (id)processNode:(id)node;

@property(readonly) NSString *shorthand;
@property(weak) id delegate;

@end

@interface YKRegexTag : ISA_YKTag
{
    NSDictionary *regexDeclarations;
}

- (void)addRegexDeclaration:(NSString *)regex hint:(id)hint;

@end

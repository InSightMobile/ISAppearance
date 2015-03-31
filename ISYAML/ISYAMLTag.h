//
//  ISYAMLTag.h
//  ISYAML
//
//  Created by Faustino Osuna on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISYAMLTag;

@protocol ISYAMLTagDelegate <NSObject>

- (id)tag:(ISYAMLTag *)tag decodeFromString:(NSString *)stringValue extraInfo:(NSDictionary *)extraInfo;

- (id)tag:(ISYAMLTag *)tag castValue:(id)value fromTag:(ISYAMLTag *)castingTag;

- (id)tag:(ISYAMLTag *)tag castValue:(id)value toTag:(ISYAMLTag *)castingTag;

- (id)tag:(ISYAMLTag *)tag processNode:(id)node extraInfo:(NSDictionary *)extraInfo;

@end

@interface ISYAMLTag : NSObject


- (id)initWithURI:(NSString *)aURI delegate:(id <ISYAMLTagDelegate>)aDelegate;

- (id)decodeFromString:(NSString *)stringValue explicitTag:(ISYAMLTag *)explicitTag;

- (id)castValue:(id)value fromTag:(ISYAMLTag *)castingTag;

- (id)castValue:(id)value toTag:(ISYAMLTag *)castingTag;

@property(readonly) NSString *verbatim;

- (id)processNode:(id)node;

@property(readonly) NSString *shorthand;
@property(weak) id delegate;

@end

@interface ISYAMLRegexTag : ISYAMLTag {
    NSDictionary *regexDeclarations;
}

- (void)addRegexDeclaration:(NSString *)regex hint:(id)hint;

@end

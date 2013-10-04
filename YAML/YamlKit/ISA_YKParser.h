//
//  ISA_YKParser.h
//  ISA_YAMLKit
//
//  Created by Patrick Thomson on 12/29/08.
//

#import <Foundation/Foundation.h>
#import "ISA_YKTag.h"

@protocol YKParserDelegate;

@interface ISA_YKParser : NSObject
{
    BOOL readyToParse;
    FILE *fileInput;
    const char *stringInput;
    void *opaque_parser;
    NSMutableDictionary *tagsByName;
    NSMutableDictionary *_explicitTagsByName;
}

- (void)reset;

- (BOOL)readString:(NSString *)path;

- (BOOL)readFile:(NSString *)path;

- (NSArray *)parse;

- (NSArray *)parseWithError:(NSError **)e;

- (void)addTag:(ISA_YKTag *)tag;

- (void)addExplicitTag:(ISA_YKTag *)tag;

@property(readonly) BOOL isReadyToParse;
@property(readonly) NSDictionary *tagsByName;

@property(weak) id <YKParserDelegate> delegate;

@end


@protocol YKParserDelegate <NSObject>
@optional

- (ISA_YKTag *)parser:(ISA_YKParser *)parser tagForURI:(NSString *)uri;

@end


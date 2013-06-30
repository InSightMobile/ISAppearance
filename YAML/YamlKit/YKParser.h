//
//  YKParser.h
//  YAMLKit
//
//  Created by Patrick Thomson on 12/29/08.
//

#import <Foundation/Foundation.h>
#import "YKTag.h"

@protocol YKParserDelegate;

@interface YKParser : NSObject
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

- (void)addTag:(YKTag *)tag;

- (void)addExplicitTag:(YKTag *)tag;

@property(readonly) BOOL isReadyToParse;
@property(readonly) NSDictionary *tagsByName;

@property(weak) id <YKParserDelegate> delegate;

@end


@protocol YKParserDelegate <NSObject>
@optional

- (YKTag *)parser:(YKParser *)parser tagForURI:(NSString *)uri;

@end


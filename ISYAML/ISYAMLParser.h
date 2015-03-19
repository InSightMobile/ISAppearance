//
//  ISYAMLParser.h
//  ISYAML
//
//  Created by Patrick Thomson on 12/29/08.
//

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"

@protocol ISYAMLParserTagResolver;

@interface ISYAMLParser : NSObject

- (id)initWithContext:(NSMutableDictionary *)context;

- (NSArray *)parseString:(NSString *)string parseError:(NSError **)error;
- (NSArray *)parseData:(NSData *)data parseError:(NSError **)error;
- (NSArray *)parseFile:(NSString *)path  parseError:(NSError **)error;

@property(strong, nonatomic) id <ISYAMLParserTagResolver> tagResolver;

@end


@protocol ISYAMLParserTagResolver <NSObject>

- (ISYAMLTag *)tagForURI:(NSString *)uri;

@end


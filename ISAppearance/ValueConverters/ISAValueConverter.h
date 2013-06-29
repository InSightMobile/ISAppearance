//
// 


#import <Foundation/Foundation.h>
#import "YKTag.h"

@class YKTag;


@interface ISAValueConverter : NSObject

+ (ISAValueConverter *)converterNamed:(NSString *)className;

- (id)objectWithISANode:(id)node;

- (YKTag *)parsingTagForURI:(NSString *)uri;

@end
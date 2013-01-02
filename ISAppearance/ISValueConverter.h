//
// 



#import <Foundation/Foundation.h>
#import "YKTag.h"

@class YKTag;


@interface ISValueConverter : NSObject

+(ISValueConverter *)converterNamed:(NSString *)className;

-(id)createFromNode:(id)node;

-(YKTag *)parsingTagForURI:(NSString *)uri;

@end
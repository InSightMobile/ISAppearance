//
// 



#import <Foundation/Foundation.h>
#import "YKTag.h"

@class YKTag;


@interface ISConverter : NSObject

-(id)createFromNode:(id)node;

+(YKTag *)parsingTagForURI:(NSString *)uri;

@end
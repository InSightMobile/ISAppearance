//
//

#import <Foundation/Foundation.h>


@interface ISACode : NSObject

@property(nonatomic, copy) NSString *codeString;

+ (instancetype)codeWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);


+ (id)codeWithInvokation:(NSInvocation *)invocation keyPath:(NSString *)path selector:(SEL)selector arguments:(NSArray *)arguments;
@end
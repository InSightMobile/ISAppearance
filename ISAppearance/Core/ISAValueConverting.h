//

#import "ISYAMLTag.h"

@protocol ISAValueConverting <NSObject>

- (id)objectWithISANode:(id)node;

- (ISYAMLTag *)parsingTagForURI:(NSString *)uri;

@optional
- (id)codeWithISANode:(id)node;
- (id)boxedCodeWithISANode:(id)node;

@end

//
//

#import <Foundation/Foundation.h>

@class ISACodeEntry;
@class ISACode;

typedef NS_OPTIONS(NSInteger, ISACodeFlags) {
    ISACodeCached = 1 << 0,
    ISACodeForceInline = 1 << 1,

};


@interface ISACode : NSObject

@property(nonatomic, readonly) NSString *codeString;

@property(nonatomic, copy) NSString *sourceString;

@property(nonatomic, strong) Class codeClass;

@property(nonatomic) ISACodeFlags flags;

- (instancetype)initWithTypeName:(NSString *)typeName codeString:(NSString *)codeString;

+ (instancetype)codeWithClass:(Class)codeClass format:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);

+ (instancetype)codeWithClass:(Class)codeClass flags:(ISACodeFlags)flags format:(NSString *)format, ...;

+ (instancetype)codeWithTypeName:(NSString *)typeName format:(NSString *)format, ...;

+ (instancetype)codeWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);


+ (id)codeWithInvokation:(NSInvocation *)invocation keyPath:(NSString *)path selector:(SEL)selector arguments:(NSArray *)arguments;

+ (ISACode *)codeForString:(NSString *)string;

+ (ISACode *)fixCodeForClass:(Class)pClass value:(id)value;

+ (ISACode *)codeForObject:(id)param;

+ (ISACode *)codeForNumber:(id)argument;

+ (id)codeForNil;

+ (ISACode *)codeWithInvokation:(NSInvocation *)invocation target:(id)target keyPath:(NSString *)path selector:(SEL)selector arguments:(NSArray *)arguments;

+ (ISACode *)codeForArray:(id)argument;

+ (ISACode *)codeForDictionary:(id)argument;

+ (NSObject *)codeWithTypeName:(NSString *)string object:(id)object;

+ (id)fixCodeForTypeName:(NSString *)name value:(id)value;
@end
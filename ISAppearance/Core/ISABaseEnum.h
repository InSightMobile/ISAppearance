//
// 



#import <Foundation/Foundation.h>


@interface ISABaseEnum : NSObject
+ (NSInteger)valueWithName:(NSString *)name;

+ (NSNumber *)numberWithName:(NSString *)name;

+ (NSString *)nameWithValue:(NSInteger)value;

+ (NSInteger)unknownValue;

+ (NSDictionary *)nameToValueMapping;
@end
//
//  ISYAMLEmitter.h
//  ISYAML
//
//  Created by Patrick Thomson on 12/29/08.
//

#import <Foundation/Foundation.h>

@interface ISYAMLEmitter : NSObject {
    NSMutableData *buffer;
    BOOL usesExplicitDelimiters;
    NSStringEncoding encoding;
    void *opaque_emitter;
}

- (void)emitItem:(id)item;

- (NSString *)emittedString;

- (NSData *)emittedData;

@property(nonatomic) BOOL usesExplicitDelimiters;
@property(nonatomic) NSStringEncoding encoding;

@end

//
//  ISYAMLUnknownNode.h
//  ISYAML
//
//  Created by Faustino Osuna on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"

typedef struct {
    NSUInteger line;
    NSUInteger column;
    NSUInteger index;
} ISYAMLMark;

typedef struct {
    ISYAMLMark start;
    ISYAMLMark end;
} ISYAMLRange;

ISYAMLRange ISYAMLMakeRange(ISYAMLMark start, ISYAMLMark end);

ISYAMLMark ISYAMLMakeMark(NSUInteger line, NSUInteger column, NSUInteger index);

@interface ISYAMLUnknownNode : NSObject {
    ISYAMLRange position;
    ISYAMLTag *implicitTag;
    ISYAMLTag *explicitTag;
    NSString *stringValue;
}

+ (id)unknownNodeWithStringValue:(NSString *)aStringValue implicitTag:(ISYAMLTag *)aImplicitTag
                     explicitTag:(ISYAMLTag *)aExplicitTag position:(ISYAMLRange)aPosition;

- (id)initWithStringValue:(NSString *)aStringValue implicitTag:(ISYAMLTag *)aImplicitTag explicitTag:(ISYAMLTag *)aExplicitTag
                 position:(ISYAMLRange)aPosition;

@property(readonly) ISYAMLRange position;
@property(readonly) ISYAMLTag *implicitTag;
@property(readonly) ISYAMLTag *explicitTag;
@property(readonly) NSString *stringValue;

@end

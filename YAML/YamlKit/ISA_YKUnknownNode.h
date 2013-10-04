//
//  ISA_YKUnknownNode.h
//  ISA_YAMLKit
//
//  Created by Faustino Osuna on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISA_YKTag.h"

typedef struct
{
    NSUInteger line;
    NSUInteger column;
    NSUInteger index;
} ISA_YKMark;

typedef struct
{
    ISA_YKMark start;
    ISA_YKMark end;
} ISA_YKRange;

ISA_YKRange ISA_YKMakeRange(ISA_YKMark start, ISA_YKMark end);

ISA_YKMark ISA_YKMakeMark(NSUInteger line, NSUInteger column, NSUInteger index);

@interface ISA_YKUnknownNode : NSObject
{
    ISA_YKRange position;
    ISA_YKTag *implicitTag;
    ISA_YKTag *explicitTag;
    NSString *stringValue;
}

+ (id)unknownNodeWithStringValue:(NSString *)aStringValue implicitTag:(ISA_YKTag *)aImplicitTag
                     explicitTag:(ISA_YKTag *)aExplicitTag position:(ISA_YKRange)aPosition;

- (id)initWithStringValue:(NSString *)aStringValue implicitTag:(ISA_YKTag *)aImplicitTag explicitTag:(ISA_YKTag *)aExplicitTag
                 position:(ISA_YKRange)aPosition;

@property(readonly) ISA_YKRange position;
@property(readonly) ISA_YKTag *implicitTag;
@property(readonly) ISA_YKTag *explicitTag;
@property(readonly) NSString *stringValue;

@end

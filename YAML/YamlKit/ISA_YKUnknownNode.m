//
//  ISA_YKUnknownNode.m
//  ISA_YAMLKit
//
//  Created by Faustino Osuna on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ISA_YKUnknownNode.h"

inline ISA_YKRange ISA_YKMakeRange(ISA_YKMark start, ISA_YKMark end) {
    ISA_YKRange results = {start, end};
    return results;
}

inline ISA_YKMark ISA_YKMakeMark(NSUInteger line, NSUInteger column, NSUInteger idx) {
    ISA_YKMark results = {line, column, idx};
    return results;
}

@implementation ISA_YKUnknownNode

+ (id)unknownNodeWithStringValue:(NSString *)aStringValue implicitTag:(ISA_YKTag *)aImplicitTag
                     explicitTag:(ISA_YKTag *)aExplicitTag position:(ISA_YKRange)aPosition
{
    return [[self alloc] initWithStringValue:aStringValue implicitTag:aImplicitTag explicitTag:aExplicitTag
                                    position:aPosition];
}

- (id)initWithStringValue:(NSString *)aStringValue implicitTag:(ISA_YKTag *)aImplicitTag explicitTag:(ISA_YKTag *)aExplicitTag
                 position:(ISA_YKRange)aPosition
{
    if (!(self = [super init]))
        return nil;

    stringValue = [aStringValue copy];
    implicitTag = aImplicitTag;
    explicitTag = aExplicitTag;
    memcpy(&position, &aPosition, sizeof(ISA_YKRange));

    return self;
}

- (void)dealloc
{
    stringValue = nil;
    implicitTag = nil;
    explicitTag = nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{!%@ %@ (%ld:%ld),(%ld:%ld)}", explicitTag, stringValue,
                                      (long) position.start.line, (long) position.start.column, (long) position.end.line, (long) position.end.column];
}

@synthesize position;
@synthesize implicitTag;
@synthesize explicitTag;
@synthesize stringValue;

@end

//
//  ISYAMLUnknownNode.m
//  ISYAML
//
//  Created by Faustino Osuna on 10/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ISYAMLUnknownNode.h"

inline ISYAMLRange ISYAMLMakeRange(ISYAMLMark start, ISYAMLMark end) {
    ISYAMLRange results = {start, end};
    return results;
}

inline ISYAMLMark ISYAMLMakeMark(NSUInteger line, NSUInteger column, NSUInteger idx) {
    ISYAMLMark results = {line, column, idx};
    return results;
}

@implementation ISYAMLUnknownNode

+ (id)unknownNodeWithStringValue:(NSString *)aStringValue implicitTag:(ISYAMLTag *)aImplicitTag
                     explicitTag:(ISYAMLTag *)aExplicitTag position:(ISYAMLRange)aPosition
{
    return [[self alloc] initWithStringValue:aStringValue implicitTag:aImplicitTag explicitTag:aExplicitTag
                                    position:aPosition];
}

- (id)initWithStringValue:(NSString *)aStringValue implicitTag:(ISYAMLTag *)aImplicitTag explicitTag:(ISYAMLTag *)aExplicitTag
                 position:(ISYAMLRange)aPosition
{
    if (!(self = [super init])) {
            return nil;
    }

    stringValue = [aStringValue copy];
    implicitTag = aImplicitTag;
    explicitTag = aExplicitTag;
    memcpy(&position, &aPosition, sizeof(ISYAMLRange));

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

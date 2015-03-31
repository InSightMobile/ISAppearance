//
//  ISYAMLNativeTagManager.h
//  ISYAML
//
//  Created by Faustino Osuna on 10/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISYAMLTag.h"

@interface ISYAMLNativeTagManager : NSObject

+ (id)sharedManager;

@property(readonly, strong) NSDictionary *tagsByName;

@end

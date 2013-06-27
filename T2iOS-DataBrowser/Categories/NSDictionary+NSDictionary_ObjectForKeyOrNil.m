//
//  NSDictionary+NSDictionary_ObjectForKeyOrNil.m
//  T2User
//
//  Created by Tim Brooks on 6/11/13.
//  Copyright (c) 2013 T2. All rights reserved.
//

#import "NSDictionary+NSDictionary_ObjectForKeyOrNil.h"

@implementation NSDictionary (ObjectForKeyOrNil)

- (id)objectForKeyOrNil:(id)key
{
    id val = [self objectForKey:key];
    if ([val isEqual:[NSNull null]]) {
        return nil;
    }
    
    return val;
}

@end

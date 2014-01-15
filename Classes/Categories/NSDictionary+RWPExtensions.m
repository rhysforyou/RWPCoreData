//
//  NSDictionary+RWPExtensions.m
//  GistPad
//
//  Created by Rhys Powell on 12/01/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

#import "NSDictionary+RWPExtensions.h"

@implementation NSDictionary (RWPExtensions)

- (id)safeObjectForKey:(NSString *)key
{
	id obj = [self objectForKey:key];
	if ([obj isEqual:[NSNull null]]) {
		obj = nil;
	}
	return obj;
}

@end

//
//  NSDictionary+RWPExtensions.h
//  GistPad
//
//  Created by Rhys Powell on 12/01/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RWPExtensions)

- (id)safeObjectForKey:(NSString *)key;

@end

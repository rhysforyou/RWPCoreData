//
//  RWPRemoteManagedObject.m
//  GistPad
//
//  Created by Rhys Powell on 12/01/2014.
//  Copyright (c) 2014 Rhys Powell. All rights reserved.
//

#import "RWPRemoteManagedObject.h"

@implementation RWPRemoteManagedObject

@dynamic remoteID;
@dynamic createdAt;
@dynamic updatedAt;

+ (instancetype)objectWithRemoteID:(NSNumber *)remoteID
{
    return [self objectWithRemoteID:remoteID context:nil];
}

+ (instancetype)objectWithRemoteID:(NSNumber *)remoteID context:(NSManagedObjectContext *)context
{
    RWPRemoteManagedObject *object = [self existingObjectWithRemoteID:remoteID context:context];

    if (object == nil) {
        object = [[self alloc] initWithContext:context];
        object.remoteID = remoteID;
    }

    return object;
}

+ (instancetype)existingObjectWithRemoteID:(NSNumber *)remoteID
{
    return [self existingObjectWithRemoteID:remoteID context:nil];
}

+ (instancetype)existingObjectWithRemoteID:(NSNumber *)remoteID context:(NSManagedObjectContext *)context
{
    if (context == nil) {
        context = [self mainContext];
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [self entityWithContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"remoteID = %@", remoteID];
    fetchRequest.fetchLimit = 1;

    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];

    if ([results count] == 0) {
        return nil;
    }

    return results[0];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
{
    return [self objectWithDictionary:dictionary context:[self mainContext]];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context
{
    if (dictionary == nil) {
        return nil;
    }

    NSNumber *remoteID = dictionary[@"id"];

    if (remoteID == nil || [remoteID integerValue] == 0) {
        return nil;
    }

    if (context == nil) {
        context = [self mainContext];
    }

    RWPRemoteManagedObject *object = [self objectWithRemoteID:remoteID context:context];

    if ([object shouldUnpackDictionary:dictionary]) {
        [object unpackDictionary:dictionary];
    }

    return object;
}

+ (instancetype)existingObjectWithDictionary:(NSDictionary *)dictionary
{
    return [self existingObjectWithDictionary:dictionary context:[self mainContext]];
}

+ (instancetype)existingObjectWithDictionary:(NSDictionary *)dictionary context:(NSManagedObjectContext *)context
{
    if (dictionary == nil) {
        return nil;
    }

    NSNumber *remoteID = dictionary[@"id"];

    if (remoteID == nil || [remoteID integerValue] == 0) {
        return nil;
    }

    if (context == nil) {
        context = [self mainContext];
    }

    RWPRemoteManagedObject *object = [self existingObjectWithRemoteID:remoteID context:context];


    if (object == nil) {
        return nil;
    }

    if ([object shouldUnpackDictionary:dictionary]) {
        [object unpackDictionary:dictionary];
    }

    return object;
}

- (void)unpackDictionary:(NSDictionary *)dictionary
{
    self.remoteID = dictionary[@"id"];
    self.createdAt = [[self class] parseDate:dictionary[@"created_at"]];
    self.updatedAt = [[self class] parseDate:dictionary[@"updated_at"]];
}

- (BOOL)shouldUnpackDictionary:(NSDictionary *)dictionary
{
    return self.updatedAt == nil || [self.updatedAt isEqualToDate:[[self class] parseDate:dictionary[@"updated_at"]]] == NO;
}

+ (NSDate *)parseDate:(id)dateStringOrDateNumber {
	// Return nil if nil is given
	if (!dateStringOrDateNumber || dateStringOrDateNumber == [NSNull null]) {
		return nil;
	}

	// Parse number
	if ([dateStringOrDateNumber isKindOfClass:[NSNumber class]]) {
		return [NSDate dateWithTimeIntervalSince1970:[dateStringOrDateNumber doubleValue]];
	}

	// Parse string
	else if ([dateStringOrDateNumber isKindOfClass:[NSString class]]) {
		// ISO8601 Parser borrowed from SSToolkit. http://sstoolk.it
		NSString *iso8601 = dateStringOrDateNumber;
		if (!iso8601) {
			return nil;
		}

		const char *str = [iso8601 cStringUsingEncoding:NSUTF8StringEncoding];
		char newStr[25];

		struct tm tm;
		size_t len = strlen(str);
		if (len == 0) {
			return nil;
		}

		// UTC
		if (len == 20 && str[len - 1] == 'Z') {
			strncpy(newStr, str, len - 1);
			strncpy(newStr + len - 1, "+0000", 5);
		}

		// Timezone
		else if (len == 24 && str[22] == ':') {
			strncpy(newStr, str, 22);
			strncpy(newStr + 22, str + 23, 2);
		}

		// Poorly formatted timezone
		else {
			strncpy(newStr, str, len > 24 ? 24 : len);
		}

		// Add null terminator
		newStr[sizeof(newStr) - 1] = 0;

		if (strptime(newStr, "%FT%T%z", &tm) == NULL) {
			return nil;
		}

		time_t t;
		t = mktime(&tm);

		return [NSDate dateWithTimeIntervalSince1970:t];
	}

	NSAssert1(NO, @"Failed to parse date: %@", dateStringOrDateNumber);
	return nil;
}

@end

//
//  RWPManagedObject.m
//
//	The MIT License (MIT)
//
//	Copyright (c) 2014 Rhys Powell
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "RWPManagedObject.h"

static NSManagedObjectContext *__managedObjectContext = nil;
static NSDictionary *__persistentStoreOptions = nil;
static NSManagedObjectModel *__managedObjectModel = nil;
static NSURL *__persistentStoreURL;

@implementation RWPManagedObject

+ (NSManagedObjectContext *)mainContext
{
    if (__managedObjectContext == nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        __managedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    }

    return __managedObjectContext;
}

+ (BOOL)hasMainContext
{
    return __managedObjectContext != nil;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSManagedObjectModel *model = [self managedObjectModel];
        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

        NSURL *url = [self persistentStoreURL];
        NSDictionary *options = [self persistentStoreOptions];
        NSError *error = nil;

        [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
        if (error) {
            NSLog(@"Error setting persistent store: %@", error.localizedDescription);
        }
    });

    return persistentStoreCoordinator;
}

+ (NSDictionary *)persistentStoreOptions
{
    if (__persistentStoreOptions == nil) {
        __persistentStoreOptions = @{
									 NSMigratePersistentStoresAutomaticallyOption : @YES,
									 NSInferMappingModelAutomaticallyOption : @YES
									 };
    }

    return __persistentStoreOptions;
}

+ (void)setPersistentStoreOptions:(NSDictionary *)options
{
    __persistentStoreOptions = options;
}

+ (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel == nil) {
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];

        if (!model) {
            [[NSException exceptionWithName:@"RWPManagedObjectMissingModel" reason:@"You need to provide a managed model" userInfo:nil] raise];
            return nil;
        }

        [self setManagedObjectModel:model];
    }

    return __managedObjectModel;
}

+ (void)setManagedObjectModel:(NSManagedObjectModel *)model
{
    __managedObjectModel = model;
}

+ (NSURL *)persistentStoreURL
{
    if (__persistentStoreURL == nil) {
        NSDictionary *applicationData = [[NSBundle mainBundle] infoDictionary];
        NSString *applicationName = applicationData[@"CFBundleDisplayName"];
        NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *url = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", applicationName]];

        [self setPersistentStoreURL:url];
    }

    return __persistentStoreURL;
}

+ (void)setPersistentStoreURL:(NSURL *)url
{
    __persistentStoreURL = url;
}

+ (NSString *)entityName
{
    return NSStringFromClass(self);
}

+ (NSEntityDescription *)entity
{
    return [self entityWithContext:nil];
}

+ (NSEntityDescription *)entityWithContext:(NSManagedObjectContext *)context
{
    if (context == nil) {
        context = [self mainContext];
    }

    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}

+ (NSArray *)defaultSortDescriptors
{
    return nil;
}

- (id)init
{
    return [self initWithContext:nil];
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context
{
    if (context == nil) {
        context = [[self class] mainContext];
    }

    NSEntityDescription *entity = [[self class] entityWithContext:context];
    self = [self initWithEntity:entity insertIntoManagedObjectContext:context];

    return self;
}

- (void)save
{
	NSError *error = nil;

	if (![self.managedObjectContext save:&error]) {
		NSLog(@"[RWPCoreData] Unable to save data: %@", error);
	}
}

@end

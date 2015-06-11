/*!
 * MCTManagedObject.m
 * MCTObjectStore
 *
 * The MIT License (MIT)
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * @author Skylar Schipper
 *   @email skylar@pco.bz
 *
 */
#import <libkern/OSAtomic.h>

#import "MCTManagedObject.h"
#import "MCTObjectStoreError.h"

@interface MCTManagedObject () {
    OSSpinLock volatile _spinLock;
}

@property (atomic, strong) NSCache *orderCache;

@end

@implementation MCTManagedObject
@synthesize orderCache = _orderCache;

- (instancetype)init {
    self = [super init];
    if (self) {
        _spinLock = OS_SPINLOCK_INIT;
    }
    return self;
}

// MARK: - Changes
- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    [self clearOrderCacheForName:inKey];
    [super didChangeValueForKey:inKey withSetMutation:inMutationKind usingObjects:inObjects];
}

// MARK: - Order Cache
- (NSArray *)cachedOrderedRelations:(NSString *)name sort:(NSArray *(^)(NSSet *))sort {
    NSCache *cache = nil;
    OSSpinLockLock(&_spinLock);
    cache = self.orderCache;
    if (!cache) {
        cache = [[NSCache alloc] init];
        self.orderCache = cache;
    }
    OSSpinLockUnlock(&_spinLock);

    NSArray *relation = [cache objectForKey:name];
    if (relation) {
        return relation;
    }

    NSSet *set = [self valueForKey:name];
    relation = sort(set);

    if (relation) {
        [cache setObject:relation forKey:name];
    }

    return relation;
}
- (void)clearOrderCache {
    OSSpinLockLock(&_spinLock);
    self.orderCache = nil;
    OSSpinLockUnlock(&_spinLock);
}
- (void)clearOrderCacheForName:(NSString *)name {
    [self.orderCache removeObjectForKey:name];
}

// MARK: - Callbacks
- (void)didSave {
    if (![[self objectID] isTemporaryID]) {
        if ([self hasChanges] && ![self isDeleted]) {
            [self mct_sendDidSaveNotification];
        } else if ([self isDeleted]) {
            [self mct_sendDeletedNotification];
        }
    }
    [super didSave];
}
- (void)mct_sendDidSaveNotification {
    NSManagedObjectID *objectID = [self objectID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MCTManagedObjectDidSaveChangesNotification object:objectID];
    });
}
- (void)mct_sendDeletedNotification {
    NSManagedObjectID *objectID = [self objectID];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MCTManagedObjectDidDeleteNotification object:objectID];
    });
}

// MARK: - Helpers
+ (id)objectForNotification:(NSNotification *)notification context:(NSManagedObjectContext *)context error:(NSError **)error {
    NSParameterAssert(notification);
    NSParameterAssert(context);
    if (![notification.name isEqualToString:MCTManagedObjectDidSaveChangesNotification]) {
        @throw [NSException exceptionWithName:MCTObjectStoreGenericException reason:[NSString stringWithFormat:@"Can't get object with notification of type %@",notification.name] userInfo:nil];
    }
    if (![notification.object isKindOfClass:[NSManagedObjectID class]]) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTObjectStoreErrorDomain
                                         code:MCTObjectStoreErrorNoObjectID
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"Can't fetch object without an objectID, got %@", nil),notification.object]
                                                }];
        }
        return nil;
    }
    id __block object = nil;
    [context performBlockAndWait:^{
        object = [context existingObjectWithID:notification.object error:error];
    }];
    return object;
}

@end


@implementation NSManagedObject (MCTManagedObjectHelpers)

+ (NSString *)entityName {
    return [self className];
}
+ (NSString *)className {
    return NSStringFromClass(self);
}
+ (NSEntityDescription *)entityInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
}
+ (instancetype)insertIntoContext:(NSManagedObjectContext *)context {
    return [[self alloc] initWithEntity:[self entityInContext:context] insertIntoManagedObjectContext:context];
}

// MARK: - Delete
- (void)destroy {
    [self.managedObjectContext deleteObject:self];
}

// MARK: - Info
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context error:(NSError **)error {
    return [self countInContext:context predicate:nil error:error];
}
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate error:(NSError **)error {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = predicate;
    return [context countForFetchRequest:fetchRequest error:error];
}

@end

NSString *const MCTManagedObjectDidSaveChangesNotification = @"MCTManagedObjectDidSaveChangesNotification";
NSString *const MCTManagedObjectDidDeleteNotification = @"MCTManagedObjectDidDeleteNotification";

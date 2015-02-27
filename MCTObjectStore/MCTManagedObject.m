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

#import "MCTManagedObject.h"

@interface MCTManagedObject ()

@property (atomic, strong) NSMutableDictionary *orderCache;

@end

@implementation MCTManagedObject
@synthesize orderCache = _orderCache;

// MARK: - Changes
- (void)didChangeValueForKey:(NSString *)inKey withSetMutation:(NSKeyValueSetMutationKind)inMutationKind usingObjects:(NSSet *)inObjects {
    [self clearOrderCacheForName:inKey];
    [super didChangeValueForKey:inKey withSetMutation:inMutationKind usingObjects:inObjects];
}

// MARK: - Order Cache
- (NSArray *)cachedOrderedRelations:(NSString *)name sort:(NSArray *(^)(NSSet *))sort {
    @synchronized([self class]) {
        NSMutableDictionary *table = self.orderCache;
        if (!table) {
            table = [NSMutableDictionary dictionaryWithCapacity:5];
            self.orderCache = table;
        }

        NSArray *rel = [table objectForKey:name];
        if (rel) {
            return rel;
        }

        NSSet *set = [self valueForKey:name];
        rel = sort(set);
        if (rel) {
            [table setObject:rel forKey:name];
        }

        return rel;
    }
}
- (void)clearOrderCache {
    @synchronized([self class]) {
        self.orderCache = nil;
    }
}
- (void)clearOrderCacheForName:(NSString *)name {
    @synchronized([self class]) {
        [self.orderCache removeObjectForKey:name];
    }
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

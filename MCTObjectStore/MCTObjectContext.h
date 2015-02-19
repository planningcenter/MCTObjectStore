/*!
 * MCTObjectContext.h
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

#ifndef MCTObjectStore_MCTObjectContext_h
#define MCTObjectStore_MCTObjectContext_h

@import Foundation;
@import CoreData;

/**
 *  Object that wraps a CoreData NSManagedObjectContext
 */
@interface MCTObjectContext : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 *  The backing context.
 */
@property (atomic, strong, readonly) NSManagedObjectContext *context;

/**
 *  The context is ready to read/write
 */
@property (atomic, assign, readonly, getter=isReady) BOOL ready;

/**
 *  Perform the block in the context queue
 *
 *  @param block The block to perform.
 */
- (void)performInContext:(void(^)(NSManagedObjectContext *ctx))block;
/**
 *  Perform the block in the context queue asynchronously.
 *
 *  @param block The block to perform
 */
- (void)performAsyncInContext:(void(^)(NSManagedObjectContext *ctx))block;
/**
 *  Perform the block in a disposable private context.
 *
 *  The context is created with a private queue type, using the store's NSPersistentStoreCoordinator.
 *
 *  After the block executes the context saves itself if it has changes.
 *
 *  @param block The block to perform.
 */
- (void)performInDisposable:(void(^)(NSManagedObjectContext *ctx))block;

/**
 *  Saves the backing context in the context's queue.
 *
 *  @param error Any save error that could be encountered
 *
 *  @return Save successful
 */
- (BOOL)save:(NSError **)error;

// MARK: - Prepare
- (BOOL)prepareWithModelName:(NSString *)modelName bundle:(NSBundle *)bundle storeURL:(NSURL *)URL;
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(NSURL *)URL;
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(NSURL *)URL persistentStoreType:(NSString *)storeType;
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(NSURL *)URL persistentStoreType:(NSString *)storeType contextType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error;

- (BOOL)prepareWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator contextType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error;

+ (NSManagedObjectModel *)modelWithName:(NSString *)name bundle:(NSBundle *)bundle;

- (instancetype)newObjectContextWithType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error;

// MARK: - Meta
- (BOOL)isMainThreadContext;

@end

@interface MCTObjectContext (ConvenienceMethods)

- (id)insertNewObject:(Class)type;

- (NSArray *)all:(Class)type;
- (NSArray *)all:(Class)type predicate:(NSPredicate *)predicate;
- (NSArray *)all:(Class)type predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sort;
- (NSArray *)all:(Class)type predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sort error:(NSError **)error;

- (NSArray *)all:(Class)type where:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);

@end

#endif

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
#if TARGET_OS_IPHONE
@import UIKit;
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 *  Object that wraps a CoreData NSManagedObjectContext
 *
 *  Merging from other contexts is handled for you by this object.
 */
@interface MCTObjectContext : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 *  The backing context.
 */
@property (atomic, strong, readonly, nullable) NSManagedObjectContext *context;

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

- (nullable id)performAndReturnInContext:(id _Nullable(^)(NSManagedObjectContext *ctx))block;

/**
 *  Saves the backing context in the context's queue.
 *
 *  @param error Any save error that could be encountered
 *
 *  @return Save successful
 */
- (BOOL)save:(NSError *__autoreleasing*)error;

/**
 *  Handle a save error in the passed context.
 *
 *  By default this will handle `NSManagedObjectMergeError` by using the `ObjectTrumpMergePolicyType`
 *
 *  @param error The error that occurred
 *  @param ctx   The context that failed to save
 *
 *  @return A BOOL indicating if the merge succeeded & the context was saved.
 */
+ (BOOL)handleSaveError:(NSError *)error inContext:(NSManagedObjectContext *)ctx;

// MARK: - Prepare
/**
 *  Prepare the context with a model file with the passed name
 *
 *  @param modelName The name of the model file
 *  @param bundle The bundle to find the model in.  If nil is passed the main app bundle is used.
 *  @param URL Where the store should be created.  If nil is passed an in-memory store will be created.
 *
 *  @return Success or failure
 */
- (BOOL)prepareWithModelName:(NSString *)modelName bundle:(nullable NSBundle *)bundle storeURL:(nullable NSURL *)URL;

- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(nullable NSURL *)URL;
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(nullable NSURL *)URL persistentStoreType:(nullable NSString *)storeType;
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(nullable NSURL *)URL persistentStoreType:(nullable NSString *)storeType contextType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error;

- (BOOL)prepareWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator contextType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error;

+ (nullable NSManagedObjectModel *)modelWithName:(NSString *)name bundle:(nullable NSBundle *)bundle;

- (nullable instancetype)newObjectContextWithType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error;

// MARK: - Meta
/**
 *  Check if the context is NSMainQueueConcurrencyType.
 *
 *  If the context is not ready NO will be returned
 */
- (BOOL)isMainThreadContext;

+ (NSDictionary *)defaultPersistentStoreOptions;

@end

@interface MCTObjectContext (ConvenienceMethods)

- (id)insertNewObject:(Class)type;

- (NSArray *)all:(Class)type;
- (NSArray *)all:(Class)type predicate:(nullable NSPredicate *)predicate;
- (NSArray *)all:(Class)type predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray *)sort;
- (NSArray *)all:(Class)type predicate:(nullable NSPredicate *)predicate sortDescriptors:(nullable NSArray *)sort error:(NSError **)error;

- (NSArray *)all:(Class)type where:(NSString *)fmt, ... NS_FORMAT_FUNCTION(2, 3);

@end

@interface NSManagedObjectContext (MCTObjectStoreAdditions)

- (BOOL)saveIfNeeded DEPRECATED_MSG_ATTRIBUTE("See saveIfNeeded: instead");
- (BOOL)saveIfNeeded:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

#endif

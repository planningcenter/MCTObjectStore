/*!
 * MCTObjectContext.m
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

#import "MCTObjectContext.h"
#import "MCTObjectStoreVersion.h"
#import "MCTObjectStoreLog.h"
#import "MCTObjectStoreError.h"

#define CHECK_TYPE_EXE(x_type) if (![type isSubclassOfClass:[NSManagedObject class]]) { \
@throw [NSException exceptionWithName:MCTObjectStoreGenericException \
                               reason:[NSString stringWithFormat:@"%@ is not of type %@",NSStringFromClass(type),NSStringFromClass([NSManagedObject class])] \
                             userInfo:nil]; \
}

@interface MCTObjectContext ()

@property (atomic, strong, readwrite) NSManagedObjectContext *context;
@property (atomic, assign, readwrite, getter=isReady) BOOL ready;

@property (atomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation MCTObjectContext
@synthesize context = _context;
@synthesize ready = _ready;

// MARK: - Getters/Setters
- (void)setContext:(NSManagedObjectContext *)context {
    dispatch_barrier_async(self.queue, ^{
        _context = context;
    });
}
- (NSManagedObjectContext *)context {
    NSManagedObjectContext __block *ctx = nil;
    dispatch_sync(self.queue, ^{
        ctx = _context;
    });
    return ctx;
}
- (void)setReady:(BOOL)ready {
    dispatch_barrier_async(self.queue, ^{
        _ready = ready;
    });
}
- (BOOL)isReady {
    BOOL __block r = NO;
    dispatch_sync(self.queue, ^{
        r = _ready;
    });
    return r;
}

// MARK: - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.ministrycentered.ObjectStore", DISPATCH_QUEUE_CONCURRENT);
        _ready = NO;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - Perform in Context
- (void)performInContext:(void(^)(NSManagedObjectContext *ctx))block {
    NSManagedObjectContext *ctx = self.context;
    [ctx performBlockAndWait:^{
        block(ctx);
    }];
}
- (void)performAsyncInContext:(void(^)(NSManagedObjectContext *ctx))block {
    NSManagedObjectContext *ctx = self.context;
    [ctx performBlock:^{
        block(ctx);
    }];
}
- (void)performInDisposable:(void(^)(NSManagedObjectContext *ctx))block {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    ctx.persistentStoreCoordinator = self.context.persistentStoreCoordinator;
    [ctx performBlockAndWait:^{
        block(ctx);
        NSError *error = nil;
        if ([ctx hasChanges] && ![ctx save:&error]) {
            MCTOSLog(@"Failed to save context: %@",error);
        }
    }];
}

- (BOOL)save:(NSError **)error {
    BOOL __block success = YES;
    [self performInContext:^(NSManagedObjectContext *ctx) {
        if ([ctx hasChanges]) {
            MCTOSLog(@"Saving store %@",self);
            if (![ctx save:error]) {
                MCTOSLog(@"Failed to save store");
                success = NO;
            }
        }
    }];
    return success;
}

- (instancetype)newObjectContextWithType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error {
    typeof(self) obj = [[[self class] alloc] init];
    if (![obj prepareWithPersistentStoreCoordinator:self.context.persistentStoreCoordinator contextType:contextType error:error]) {
        return nil;
    }
    return obj;
}

// MARK: - Prepare
- (BOOL)prepareWithModelName:(NSString *)modelName bundle:(NSBundle *)bundle storeURL:(NSURL *)URL {
    return [self prepareWithModel:[self.class modelWithName:modelName bundle:bundle] storeURL:URL];
}
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(NSURL *)URL {
    return [self prepareWithModel:model storeURL:URL persistentStoreType:nil];
}
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(NSURL *)URL persistentStoreType:(NSString *)storeType {
    return [self prepareWithModel:model storeURL:URL persistentStoreType:storeType contextType:NSMainQueueConcurrencyType error:NULL];
}
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model storeURL:(NSURL *)URL persistentStoreType:(NSString *)storeType contextType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error {
    if (!model) {
        return NO;
    }
    if (!storeType) {
        if (!URL) {
            storeType = NSInMemoryStoreType;
        } else {
            storeType = NSSQLiteStoreType;
        }
    }
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES
                              };

    if (![psc addPersistentStoreWithType:storeType configuration:nil URL:URL options:options error:error]) {
        return NO;
    }

    return [self prepareWithPersistentStoreCoordinator:psc contextType:contextType error:error];
}
- (BOOL)prepareWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator contextType:(NSManagedObjectContextConcurrencyType)contextType error:(NSError **)error {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] initWithConcurrencyType:contextType];
    ctx.persistentStoreCoordinator = coordinator;
    ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

    self.context = ctx;

    self.ready = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSaveNotification:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:nil];

    return YES;
}

+ (NSManagedObjectModel *)modelWithName:(NSString *)name bundle:(NSBundle *)bundle {
    NSURL *URL = [bundle URLForResource:name withExtension:@"momd"];
    if (!URL) {
        URL = [bundle URLForResource:name withExtension:@"mom"];
    }
    if (!URL) {
        return nil;
    }
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
}

// MARK: - Save Changes
- (void)contextDidSaveNotification:(NSNotification *)notification {
    NSManagedObjectContext *_ctx = [notification object];
    NSManagedObjectContext *lCtx = self.context;
    if (_ctx == lCtx) {
        // We don't care about self
        return;
    }
    if (_ctx.persistentStoreCoordinator != lCtx.persistentStoreCoordinator) {
        // Different database
        return;
    }
    [lCtx performBlockAndWait:^{
        [lCtx mergeChangesFromContextDidSaveNotification:notification];
    }];
}

// MARK: - Meta
- (BOOL)isMainThreadContext {
    return (self.context.concurrencyType == NSMainQueueConcurrencyType);
}

@end

@implementation MCTObjectContext (ConvenienceMethods)

- (id)insertNewObject:(Class)type {
    CHECK_TYPE_EXE(type);

    id __block obj = nil;
    [self performInContext:^(NSManagedObjectContext *ctx) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([type class]) inManagedObjectContext:ctx];
        obj = [[type alloc] initWithEntity:entity insertIntoManagedObjectContext:ctx];
    }];
    return obj;
}

- (NSArray *)all:(Class)type {
    return [self all:type predicate:nil];
}
- (NSArray *)all:(Class)type predicate:(NSPredicate *)predicate {
    return [self all:type predicate:predicate sortDescriptors:nil];
}
- (NSArray *)all:(Class)type predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sort {
    return [self all:type predicate:predicate sortDescriptors:sort error:NULL];
}
- (NSArray *)all:(Class)type predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sort error:(NSError **)error {
    CHECK_TYPE_EXE(type);
    NSArray __block *arr = nil;
    [self performInContext:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(type)];
        fetchRequest.predicate = predicate;
        fetchRequest.sortDescriptors = sort;
        arr = [ctx executeFetchRequest:fetchRequest error:error];
    }];
    return arr;
}

- (NSArray *)all:(Class)type where:(NSString *)fmt, ... {
    va_list arguments;
    va_start(arguments, fmt);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fmt arguments:arguments];
    va_end(arguments);
    return [self all:type predicate:predicate];
}

@end

NSUInteger const MCTObjectStoreCurrentVersion = MCTObjectStoreVersion_1_0_0;
NSString * const MCTObjectStoreErrorDomain = @"MCTObjectStoreErrorDomain";
NSString * const MCTObjectStoreGenericException = @"MCTObjectStoreGenericException";
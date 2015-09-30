/*!
 * MCTObjectStack.m
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

#import "MCTObjectStack.h"
#import "MCTObjectContext.h"
#import "MCTManagedObject.h"
#import "MCTObjectStoreError.h"
#import "MCTObjectStoreLog.h"

@interface MCTObjectStack ()

@property (atomic, strong, readwrite) MCTObjectContext *mainContext;
@property (atomic, strong, readwrite) MCTObjectContext *privateContext;

@property (atomic, strong, readonly) dispatch_queue_t queue;

@end

@implementation MCTObjectStack

+ (instancetype)sharedStack {
    static MCTObjectStack *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.ministrycentered.MCTObjectStack", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

// MARK: - Values
- (BOOL)isReady {
    return ([self.mainContext isReady] && [self.privateContext isReady]);
}

// MARK: - Context
- (BOOL)prepareModelWithName:(NSString *)name bundle:(NSBundle *)bundle location:(NSURL *)location error:(NSError **)error {
    NSManagedObjectModel *model = [MCTObjectContext modelWithName:name bundle:(bundle) ?: [NSBundle mainBundle]];
    if (!model) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:MCTObjectStoreErrorDomain code:MCTObjectStoreErrorModelNotFound userInfo:nil];
        }
        return NO;
    }

    return [self prepareWithModel:model location:location error:error];
}
- (BOOL)prepareWithModel:(NSManagedObjectModel *)model location:(NSURL *)location error:(NSError **)error {
    MCTObjectContext *main = [[MCTObjectContext alloc] init];
    if (![main prepareWithModel:model storeURL:location persistentStoreType:nil contextType:NSMainQueueConcurrencyType error:error]) {
        return NO;
    }

    MCTObjectContext *private = [main newObjectContextWithType:NSPrivateQueueConcurrencyType error:error];
    if (!private) {
        return NO;
    }

    self.mainContext = main;
    self.privateContext = private;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:MCTObjectStackDidBecomeReadyNotification object:self];
    });

    return YES;
}

// MARK: - Helpers
- (void)performInDisposable:(void(^)(NSManagedObjectContext *ctx))block {
#if DEBUG
    if (![self isReady]) {
        NSLog(@"Trying to call %@ before ready.  Call %@ first!",NSStringFromSelector(_cmd),NSStringFromSelector(@selector(prepareWithModel:location:error:)));
    }
#endif
    [self.mainContext performInDisposable:block];
}
- (void)performInMainContext:(void (^)(NSManagedObjectContext *))block {
#if DEBUG
    if (![self isReady]) {
        NSLog(@"Trying to call %@ before ready.  Call %@ first!",NSStringFromSelector(_cmd),NSStringFromSelector(@selector(prepareWithModel:location:error:)));
    }
#endif
    [self.mainContext performInContext:block];
}

// MARK: - Save
- (BOOL)save:(NSError **)error {
    if (![self.privateContext save:error]) {
        return NO;
    }
    return [self.mainContext save:error];
}

- (BOOL)destroyStoreAtLocation:(NSURL *)location type:(NSString *)type error:(NSError **)error {
    NSPersistentStoreCoordinator *psc = self.mainContext.context.persistentStoreCoordinator;
    if (!psc) {
        return NO;
    }
    if (![psc destroyPersistentStoreAtURL:location withType:type options:[MCTObjectContext defaultPersistentStoreOptions] error:error]) {
        return NO;
    }
    return [self hardResetCoreDataStack:error];
}
- (BOOL)hardResetCoreDataStack:(NSError **)error {
    [self.mainContext.context reset];
    [self.privateContext.context reset];
    self.mainContext = nil;
    self.privateContext = nil;
    return YES;
}

@end

NSString *const MCTObjectStackDidBecomeReadyNotification = @"MCTObjectStackDidBecomeReadyNotification";

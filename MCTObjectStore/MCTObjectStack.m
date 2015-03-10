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

    return YES;
}

@end

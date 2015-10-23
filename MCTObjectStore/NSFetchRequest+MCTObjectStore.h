/*!
 * NSFetchRequest+MCTObjectStore.h
 * MCTObjectStore
 *
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 10/23/15
 */

#ifndef MCTObjectStore_NSFetchRequest_MCTObjectStore_h
#define MCTObjectStore_NSFetchRequest_MCTObjectStore_h

@import Foundation;
@import CoreData;

NS_ASSUME_NONNULL_BEGIN

@interface NSFetchRequest (MCTObjectStore)

- (void)appendAndPredicateWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1, 2);

- (void)appendAndPredicate:(NSPredicate *)predicate;

- (void)appendOrPredicateWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1, 2);

- (void)appendOrPredicate:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END

#endif

/*!
 * NSPredicate+MCTObjectStore.h
 * MCTObjectStore
 *
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 10/23/15
 */

#ifndef MCTObjectStore_NSPredicate_MCTObjectStore_h
#define MCTObjectStore_NSPredicate_MCTObjectStore_h

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSPredicate (MCTObjectStore)

- (__kindof NSPredicate *)andPredicateWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1, 2);
- (__kindof NSPredicate *)andPredicate:(NSPredicate *)predicate;

- (__kindof NSPredicate *)orPredicateWithFormat:(NSString *)fmt, ... NS_FORMAT_FUNCTION(1, 2);
- (__kindof NSPredicate *)orPredicate:(NSPredicate *)predicate;

@end

NS_ASSUME_NONNULL_END

#endif

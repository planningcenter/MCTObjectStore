/*!
 * NSPredicate+MCTObjectStore.m
 * MCTObjectStore
 *
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 10/23/15
 */

#import "NSPredicate+MCTObjectStore.h"

@implementation NSPredicate (MCTObjectStore)

- (NSPredicate *)andPredicateWithFormat:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    return [self andPredicate:predicate];
}

- (NSPredicate *)andPredicate:(NSPredicate *)predicate {
    return [NSCompoundPredicate andPredicateWithSubpredicates:@[self, predicate]];
}

- (NSPredicate *)orPredicateWithFormat:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    return [self orPredicate:predicate];
}

- (NSPredicate *)orPredicate:(NSPredicate *)predicate {
    return [NSCompoundPredicate orPredicateWithSubpredicates:@[self, predicate]];
}

@end

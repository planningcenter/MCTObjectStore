/*!
 * NSFetchRequest+MCTObjectStore.m
 * MCTObjectStore
 *
 * Copyright (c) 2015 Ministry Centered Technology
 *
 * Created by Skylar Schipper on 10/23/15
 */

#import "NSFetchRequest+MCTObjectStore.h"

@implementation NSFetchRequest (MCTObjectStore)

- (void)appendAndPredicateWithFormat:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    [self appendAndPredicate:predicate];
}

- (void)appendAndPredicate:(NSPredicate *)predicate {
    if (!self.predicate) {
        self.predicate = predicate;
    } else {
        self.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[self.predicate copy],predicate]];
    }
}

- (void)appendOrPredicateWithFormat:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:fmt arguments:args];
    va_end(args);
    [self appendOrPredicate:predicate];
}

- (void)appendOrPredicate:(NSPredicate *)predicate {
    if (!self.predicate) {
        self.predicate = predicate;
    } else {
        self.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[[self.predicate copy],predicate]];
    }
}

@end

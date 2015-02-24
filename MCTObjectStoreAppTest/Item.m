//
//  Item.m
//  MCTObjectStore
//
//  Created by Skylar Schipper on 2/23/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#import "Item.h"


@implementation Item

@dynamic name;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic completedAt;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self willChangeValueForKey:@"createdAt"];
    [self setPrimitiveValue:[NSDate date] forKey:@"createdAt"];
    [self didChangeValueForKey:@"createdAt"];
}
- (void)willSave {
    if ([self hasChanges]) {
        [self setPrimitiveValue:[NSDate date] forKey:@"updatedAt"];
    }
    [super willSave];
}

@end

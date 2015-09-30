//
//  User.m
//  MCTObjectStore
//
//  Created by Skylar Schipper on 2/19/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#import "User.h"


@implementation User

@dynamic firstName;
@dynamic lastName;

- (void)awakeFromInsert {
    [super awakeFromInsert];

    [self setValue:[[NSUUID UUID] UUIDString] forKey:@"localID"];
}

@end

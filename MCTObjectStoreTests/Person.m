//
//  Person.m
//  MCTObjectStore
//
//  Created by Skylar Schipper on 2/15/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#import "Person.h"
#import "PhoneNumber.h"


@implementation Person

@dynamic firstName;
@dynamic lastName;
@dynamic email;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic remoteID;
@dynamic phoneNumbers;

- (NSArray *)orderedPhoneNumbers {
    return [self cachedOrderedRelations:@"phoneNumbers" sort:^NSArray *(NSSet *rel) {
        return [rel sortedArrayUsingDescriptors:@[
                                                  [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]
                                                  ]];
    }];
}

@end

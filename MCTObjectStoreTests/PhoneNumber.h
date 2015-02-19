//
//  PhoneNumber.h
//  MCTObjectStore
//
//  Created by Skylar Schipper on 2/15/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#import <MCTObjectStore/MCTObjectStore.h>

@class Person;

@interface PhoneNumber : MCTManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Person *person;

@end

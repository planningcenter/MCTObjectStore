//
//  User.h
//  MCTObjectStore
//
//  Created by Skylar Schipper on 2/19/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

#import <MCTObjectStore/MCTObjectStore.h>

@interface User : MCTManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

@end

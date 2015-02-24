//
//  Item.h
//  MCTObjectStore
//
//  Created by Skylar Schipper on 2/23/15.
//  Copyright (c) 2015 Ministry Centered Technology. All rights reserved.
//

@import MCTObjectStore;

@interface Item : MCTManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSDate * completedAt;

@end

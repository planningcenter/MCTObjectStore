//
//  Person.h
//  MCTObjectStore
//

#import <MCTObjectStore/MCTObjectStore.h>

@class PhoneNumber;

@interface Person : MCTManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSSet *phoneNumbers;

- (NSArray *)orderedPhoneNumbers;

@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;

@end

/*!
 * MCTObjectContextTests.m
 * MCTObjectStore
 *
 * Created by Skylar Schipper on 2/14/15
 */

#import <XCTest/XCTest.h>

#import "Person.h"
#import "User.h"

@interface MCTObjectContextTests : XCTestCase

@property (nonatomic, strong) MCTObjectContext *store;

@end

@implementation MCTObjectContextTests

- (void)setUp {
    [super setUp];
    self.store = [[MCTObjectContext alloc] init];

    XCTAssertTrue([self.store prepareWithModelName:@"TestModel" bundle:[NSBundle bundleForClass:self.class] storeURL:nil]);
}

- (void)tearDown {

    [super tearDown];
}

// MARK: - Testing
- (void)testBadType {
    XCTAssertThrowsSpecificNamed([self.store insertNewObject:[NSObject class]], NSException, MCTObjectStoreGenericException);
}

- (void)testAddingPeople {
    XCTAssertNotNil([self.store insertNewObject:[Person class]]);
}

- (void)testFindingPeople {
    Person *personOne = [self.store insertNewObject:[Person class]];
    Person *personTwo = [self.store insertNewObject:[Person class]];
    Person *personThree = [self.store insertNewObject:[Person class]];

    personOne.firstName = @"One";
    personTwo.firstName = @"Two";
    personThree.firstName = @"Three";

    XCTAssertTrue([self.store save:NULL]);

    NSArray *value = [self.store all:[Person class] where:@"firstName == %@",@"One"];
    XCTAssertNotNil(value);
    XCTAssertEqual(value.count, 1);
    XCTAssertEqualObjects([[value firstObject] firstName], @"One");

    NSArray *value2 = [self.store all:[Person class] where:@"firstName IN (%@)",@[@"One", @"Three"]];
    XCTAssertNotNil(value2);
    XCTAssertEqual(value2.count, 2);
}

- (void)testPrivateMerge {
    MCTObjectContext *private = [[MCTObjectContext alloc] init];
    XCTAssertTrue([private prepareWithPersistentStoreCoordinator:self.store.context.persistentStoreCoordinator contextType:NSPrivateQueueConcurrencyType error:NULL]);

    [private performInContext:^(NSManagedObjectContext *ctx) {
        Person *person = [Person insertIntoContext:ctx];
        person.firstName = @"First";
        Person *person_2 = [Person insertIntoContext:ctx];
        person_2.firstName = @"First 2";
    }];

    NSArray *find_1 = [self.store all:[Person class] where:@"firstName == %@",@"First 2"];
    XCTAssertEqual(find_1.count, 0);

    XCTAssertTrue([private save:NULL]);

    NSArray *find_2 = [self.store all:[Person class] where:@"firstName == %@",@"First 2"];
    XCTAssertEqual(find_2.count, 1);
}

- (void)testDisposableContext {
    Person *personOne = [self.store insertNewObject:[Person class]];
    personOne.firstName = @"Test";

    XCTAssertTrue([self.store save:NULL]);

    [self.store performInDisposable:^(NSManagedObjectContext *ctx) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Person className]];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"firstName == %@",@"Test"];
        fetchRequest.fetchLimit = 1;

        NSError *error = nil;
        NSArray *fetchedObjects = [ctx executeFetchRequest:fetchRequest error:&error];
        XCTAssertEqual(fetchedObjects.count, 1);

        Person *person = [fetchedObjects firstObject
                          ];
        person.firstName = @"Test Edit";
    }];

    XCTAssertEqualObjects(personOne.firstName, @"Test Edit");
}

- (void)testMergingSavesFromNewModel {
    MCTObjectContext *context = [[MCTObjectContext alloc] init];
    XCTAssertTrue([context prepareWithModelName:@"TestModel_2" bundle:[NSBundle bundleForClass:self.class] storeURL:nil]);
    
    User *user = [context insertNewObject:[User class]];
    Person *person = [self.store insertNewObject:[Person class]];
    
    user.firstName = @"User";
    person.firstName = @"Person";
    
    XCTAssertTrue([self.store save:NULL]);
    XCTAssertTrue([context save:NULL]);
}

- (void)testMergeConflicts {
    MCTObjectContext *context = [self.store newObjectContextWithType:NSMainQueueConcurrencyType error:NULL];
    XCTAssertNotNil(context);
    
    Person *person_1 = [context insertNewObject:[Person class]];
    person_1.firstName = @"Test";
    person_1.lastName = @"Person";
    
    XCTAssertTrue([context save:NULL]);
    
    Person *person_2 = [[self.store all:[Person class] where:@"firstName == %@",@"Test"] firstObject];
    
    person_1.firstName = @"Test 1";
    person_2.firstName = @"Test 2";
    
    XCTAssertTrue([context save:NULL]);
    XCTAssertTrue([self.store save:NULL]);
    
    XCTAssertEqualObjects(person_1.firstName, @"Test 2");
    XCTAssertEqualObjects(person_2.firstName, @"Test 2");
}

@end

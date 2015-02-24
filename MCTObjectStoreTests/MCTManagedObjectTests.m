/*!
 * MCTManagedObjectTests.m
 * MCTObjectStore
 *
 * Created by Skylar Schipper on 2/15/15
 */

#import <XCTest/XCTest.h>
#import <MCTObjectStore/MCTObjectStore.h>

#import "Person.h"
#import "PhoneNumber.h"

@interface MCTManagedObjectTests : XCTestCase

@property (nonatomic, strong) MCTObjectContext *store;

@end

@implementation MCTManagedObjectTests

- (void)setUp {
    [super setUp];
    self.store = [[MCTObjectContext alloc] init];

    XCTAssertTrue([self.store prepareWithModelName:@"TestModel" bundle:[NSBundle bundleForClass:self.class] storeURL:nil]);
}

- (void)tearDown {

    [super tearDown];
}

// MARK: - Tests
- (void)testOrderingCaches {
    Person *person = [self.store insertNewObject:[Person class]];
    person.firstName = @"First";
    person.lastName = @"Last";

    PhoneNumber *number_1 = [self.store insertNewObject:[PhoneNumber class]];
    number_1.name = @"a one";
    number_1.number = @"(123) 555-4567";

    PhoneNumber *number_2 = [self.store insertNewObject:[PhoneNumber class]];
    number_2.name = @"b two";
    number_2.number = @"(123) 555-4567";

    PhoneNumber *number_3 = [self.store insertNewObject:[PhoneNumber class]];
    number_3.name = @"c three";
    number_3.number = @"(123) 555-4567";

    [person addPhoneNumbersObject:number_1];

    XCTAssertEqual([[person orderedPhoneNumbers] count], 1);

    [person addPhoneNumbers:[NSSet setWithObjects:number_1, number_2, number_3, nil]];

    XCTAssertEqual([[person orderedPhoneNumbers] count], 3);

    XCTAssertTrue([self.store save:NULL]);

    XCTAssertEqual([[person orderedPhoneNumbers] count], 3);

    number_2.name = @"d two";

    [person clearOrderCacheForName:@"phoneNumbers"];

    NSArray *names = @[
                       @"a one",
                       @"c three",
                       @"d two"
                       ];
    NSInteger idx = 0;
    for (PhoneNumber *number in [person orderedPhoneNumbers]) {
        XCTAssertEqualObjects(number.name, names[idx]);
        idx++;
    }
}

- (void)testCount {
    [self.store insertNewObject:[Person class]];
    [self.store insertNewObject:[Person class]];
    
    XCTAssertEqual([Person countInContext:self.store.context error:NULL], 2);
    
    [self.store insertNewObject:[Person class]];
    [self.store insertNewObject:[Person class]];
    
    XCTAssertEqual([Person countInContext:self.store.context error:NULL], 4);
}

@end

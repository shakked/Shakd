//
//  testZSSCloudQuerier.m
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "testZSSCloudQuerier.h"
#import "ZSSCloudQuerier.h"
#import "ZSSLocalQuerier.h"
#import "ZSSLocalSyncer.h"
#import "ZSSMessage.h"
#import "ZSSLocalStore.h"

@implementation testZSSCloudQuerier
//+ (instancetype)sharedQuerier;
//- (void)fetchSentMessagesInBackgroundWithCompletionBlock:(void (^)(NSArray *sentMessages))completionBlock;
//- (void)fetchReceivedMessagesInBackgroundWithCompletionBlock:(void (^)(NSArray *receievedMessages))completionBlock;
//- (void)fetchSentFriendRequestsInBackgroundWithCompletionBlock:(void (^)(NSArray *sentFriendRequests))completionBlock;
//- (void)fetchReceivedFriendRequestsInBackgroundWithCompletionBlock:(void (^)(NSArray *receivedFriendRequests))completionBlock;
//- (void)fetchFriendsInBackgroundWithCompletionBlock:(void (^)(NSArray *friends))completionBlock;
//- (void)logInUserInBackgroundWithCompletionBlock:(void (^)(PFUser *user, NSError *error))completionBlock;

- (void)setUp {
    [PFUser logInWithUsername:@"zach" password:@"nets27"];
}

- (void)tearDown {
    [PFUser logOut];
}

- (void)testInitialization {
    XCTAssertNoThrow([ZSSCloudQuerier sharedQuerier]);
}

- (void)testFetchMessages {

    [[ZSSCloudQuerier sharedQuerier] fetchMessagesWithCompletionBlock:^(NSArray *messages, NSError *error) {
        XCTAssertNotNil(messages);
        XCTAssertNil(messages);
        XCTAssertFalse([messages count] == 0);
        for (int i = 0; i < messages.count; i++) {
            XCTAssertTrue([messages[i] isKindOfClass:[PFObject class]]);
            XCTAssertNotNil([[messages[i] valueForKey:@"receiver"] valueForKey:@"username"]);
        }
        
    }];
}

- (void)testFetchFriendRequests {
    
    XCTestExpectation *friendRequestExpectation = [self expectationWithDescription:@"friendRequests"];
    
    [[ZSSCloudQuerier sharedQuerier] fetchFriendRequestsWithCompletionBlock:^(NSArray *sentFriendRequests, NSError *error) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        XCTAssertNotNil(sentFriendRequests);
        XCTAssertNil(sentFriendRequests);
        XCTAssertFalse([sentFriendRequests count] == 0);
        for (int i = 0; i < sentFriendRequests.count; i++) {
            XCTAssertTrue([sentFriendRequests[i] isKindOfClass:[PFObject class]]);
            XCTAssertNotNil([[sentFriendRequests[i] valueForKey:@"receiver"] valueForKey:@"username"]);
        }
        [friendRequestExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:^(NSError *error) {
        
    }];
}


- (void)testLogInUser {
    [PFUser logOut];
    XCTAssertNoThrow([[ZSSCloudQuerier sharedQuerier] logInUserWithUsername:@"zach"
                                                                andPassword:@"nets27"
                                                        withCompletionBlock:^(PFUser *user, NSError *error) {
                               XCTAssertNotNil(user);
                           }]);
}

- (void)testSignUpUser {
    [PFUser logOut];
    
    PFUser *test_user = [PFUser user];
    test_user.username = @"test_user";
    test_user.password = @"test_password";
    test_user.email = @"test_user@test.com";
    [[ZSSCloudQuerier sharedQuerier] signUpUser:test_user withCompletionBlock:^(BOOL succeeded, NSError *error) {
        XCTAssertNil(error);
        XCTAssert(succeeded);
        [test_user delete];
    }];
}

- (void)testViewMessage {
    PFObject *cloudMessage = [PFObject objectWithClassName:@"ZSSMessage"];
    [cloudMessage save];
    ZSSMessage *localMessage = [[ZSSLocalQuerier sharedQuerier] localMessageForCloudMessage:cloudMessage];
    [[ZSSCloudQuerier sharedQuerier] viewMessage:localMessage withCompletionBlock:^(BOOL succeeded, NSError *error) {
        XCTAssert(succeeded);
        XCTAssertNotNil(cloudMessage[@"dateViewed"]);
        XCTAssertNotNil(localMessage.dateViewed);
        XCTAssertEqual(cloudMessage[@"dateViewed"], localMessage.dateViewed);
        XCTAssertNil(cloudMessage[@"dateViewed"]);
        [[ZSSLocalStore sharedStore] deleteMessage:localMessage];
        [[ZSSLocalStore sharedStore] saveCoreDataChanges];
        [cloudMessage delete];
        [cloudMessage save];
    }];
}

@end

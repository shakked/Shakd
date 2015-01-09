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

    [[ZSSCloudQuerier sharedQuerier] fetchMessagesInBackgroundWithCompletionBlock:^(NSArray *messages, NSError *error) {
        XCTAssertNotNil(messages);
        XCTAssertFalse([messages count] == 0);
        for (int i = 0; i < messages.count; i++) {
            XCTAssertTrue([messages[i] isKindOfClass:[PFObject class]]);
            XCTAssertNotNil([[messages[i] valueForKey:@"receiver"] valueForKey:@"username"]);
        }
        
    }];
}

- (void)testFetchFriendRequests {
    [[ZSSCloudQuerier sharedQuerier] fetchFriendRequestsInBackgroundWithCompletionBlock:^(NSArray *sentFriendRequests, NSError *error) {

        XCTAssertNotNil(sentFriendRequests);
        XCTAssertFalse([sentFriendRequests count] == 0);
        for (int i = 0; i < sentFriendRequests.count; i++) {
            XCTAssertTrue([sentFriendRequests[i] isKindOfClass:[PFObject class]]);
            XCTAssertNotNil([[sentFriendRequests[i] valueForKey:@"receiver"] valueForKey:@"username"]);
        }
    }];
}


- (void)testLogInUser {
    [PFUser logOut];
    XCTAssertNoThrow([[ZSSCloudQuerier sharedQuerier] logInUserWithUsername:@"zach"
                                                                andPassword:@"nets27"
                                            InBackgroundWithCompletionBlock:^(PFUser *user, NSError *error) {
                               XCTAssertNotNil(user);
                           }]);
}

- (void)testSignUpUser {
    [PFUser logOut];
    
    PFUser *test_user = [PFUser user];
    test_user.username = @"test_user";
    test_user.password = @"test_password";
    test_user.email = @"test_user@test.com";
    [[ZSSCloudQuerier sharedQuerier] signUpUser:test_user inBackgroundWithCompletionBlock:^(BOOL succeeded, NSError *error) {
        XCTAssertNil(error);
        XCTAssert(succeeded);
        [test_user delete];
    }];
}

@end

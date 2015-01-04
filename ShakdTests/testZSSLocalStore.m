//
//  testZSSLocalStore.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "testZSSLocalStore.h"
#import "ZSSLocalStore.h"
#import "CoreDataObjects.h"

@interface testZSSLocalStore ()

@property (nonatomic, strong) NSMutableArray *testUsers;

@end

@implementation testZSSLocalStore

- (void)tearDown {
    for (ZSSUser *user in self.testUsers) {
        [[ZSSLocalStore sharedStore] deleteUser:user];
    }
    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
}

- (void)testInitialization {
    XCTAssertNoThrow([ZSSLocalStore sharedStore]);
}

- (void)testUsersReturnsArray {
    XCTAssert([[[ZSSLocalStore sharedStore] users] isKindOfClass:[NSArray class]]);
}

- (void)testUsersReturnsUsers {
    NSArray *users = [[ZSSLocalStore sharedStore] users];
    if ([users count] != 0) {
        for (int i = 0; i < [users count]; i++) {
            XCTAssert([users[i] isKindOfClass:[ZSSUser class]]);
        }
    } else {
        XCTAssertFalse(users == nil);
    }
    
}

- (void)testMessagesReturnsArray {
    XCTAssert([[[ZSSLocalStore sharedStore] messages] isKindOfClass:[NSArray class]]);
}

- (void)testMessageReturnsMessages {
    NSArray *messages = [[ZSSLocalStore sharedStore] messages];
    if ([messages count] != 0) {
        for (int i = 0; i < [messages count]; i++) {
            XCTAssert([messages[i] isKindOfClass:[ZSSMessage class]]);
        }
    } else {
        XCTAssertFalse(messages == nil);
    }
}

- (void)testFriendRequestsReturnsArray {
    XCTAssert([[[ZSSLocalStore sharedStore] friendRequests] isKindOfClass:[NSArray class]]);
}

- (void)testFriendRequestsReturnsFriendRequests {
    NSArray *friendRequests = [[ZSSLocalStore sharedStore] friendRequests];
    if ([friendRequests count] != 0) {
        for (int i = 0; i < [friendRequests count]; i++) {
            XCTAssert([friendRequests[i] isKindOfClass:[ZSSFriendRequest class]]);
        }
    } else {
        XCTAssertFalse(friendRequests == nil);
    }
}

- (void)testNewUserIsNotNil {
    ZSSUser *newUser = [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSUser"];
    [self.testUsers addObject:newUser];
    XCTAssertFalse(newUser == nil);
    [[ZSSLocalStore sharedStore] deleteUser:newUser];
}

- (void)testNewMessageIsNotNil {
    ZSSMessage *newMessage = [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSMessage"];
    XCTAssertFalse(newMessage == nil);
    [[ZSSLocalStore sharedStore] deleteMessage:newMessage];
}

- (void)testNewFriendRequestIsNotNil {
    ZSSFriendRequest *newFriendRequest = [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSFriendRequest"];
    XCTAssertFalse(newFriendRequest == nil);
    [[ZSSLocalStore sharedStore] deleteFriendRequest:newFriendRequest];
}

- (void)testNewUserCreatesNewUser {
    NSInteger userCount = [[[ZSSLocalStore sharedStore] users] count];
    ZSSUser *newUser = [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSUser"];
    NSInteger userCountAfterNewUser = [[[ZSSLocalStore sharedStore] users] count];
    XCTAssert(userCount + 1 == userCountAfterNewUser);
    [self.testUsers addObject:newUser];
    [self testNewUserIsDeleted:newUser];
}

- (void)testNewUserIsDeleted:(ZSSUser *)newUser {
    NSInteger userCount = [[[ZSSLocalStore sharedStore] users] count];
    [[ZSSLocalStore sharedStore] deleteUser:newUser];
    NSInteger userCountAfterDeletion = [[[ZSSLocalStore sharedStore] users] count];
    XCTAssert(userCount - 1 == userCountAfterDeletion);
}

- (void)testNewMessageCreatesNewMessage {
    NSInteger messageCount = [[[ZSSLocalStore sharedStore] messages] count];
    ZSSMessage *newMessage = [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSMessage"];
    NSInteger messageCountAfterNewMessage = [[[ZSSLocalStore sharedStore] messages] count];
    XCTAssert(messageCount + 1 == messageCountAfterNewMessage);
    [self testNewMessageIsDeleted:newMessage];
}

- (void)testNewMessageIsDeleted:(ZSSMessage *)newMessage {
    NSInteger messageCount = [[[ZSSLocalStore sharedStore] messages] count];
    [[ZSSLocalStore sharedStore] deleteMessage:newMessage];
    NSInteger messageCountAfterDeletion = [[[ZSSLocalStore sharedStore] messages] count];
    XCTAssert(messageCount - 1 == messageCountAfterDeletion);
}

- (void)testNewFriendRequestCreatesNewFriendRequest {
    NSInteger friendRequestCount = [[[ZSSLocalStore sharedStore] friendRequests] count];
    ZSSFriendRequest *newFriendRequest = [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSFriendRequest"];
    NSInteger friendRequestCountAfterNewFriendRequest = [[[ZSSLocalStore sharedStore] friendRequests] count];
    XCTAssert(friendRequestCount + 1 == friendRequestCountAfterNewFriendRequest);
    [self testNewFriendRequestIsDeleted:newFriendRequest];
}

- (void)testNewFriendRequestIsDeleted:(ZSSFriendRequest *)newFriendRequest {
    NSInteger friendRequestCount = [[[ZSSLocalStore sharedStore] friendRequests] count];
    [[ZSSLocalStore sharedStore] deleteFriendRequest:newFriendRequest];
    NSInteger friendRequestCountAfterDeletion = [[[ZSSLocalStore sharedStore] friendRequests] count];
    XCTAssert(friendRequestCount - 1 == friendRequestCountAfterDeletion);
}

- (void)testSaveCoreDataChanges {
//    XCTAssert([[ZSSLocalStore sharedStore] saveCoreDataChanges]);
}

@end

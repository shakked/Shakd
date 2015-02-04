//
//  testZSSLocalQuerier.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "testZSSLocalQuerier.h"
#import "ZSSLocalQuerier.h"
#import "ZSSLocalFactory.h"
#import "ZSSLocalStore.h"
#import "ZSSCloudQuerier.h"
#import "CoreDataObjects.h"
#import <Parse/Parse.h>

@interface testZSSLocalQuerier ()

@property (nonatomic, strong) NSMutableArray *testUsers;
@property (nonatomic, strong) NSMutableArray *testMessages;
@property (nonatomic, strong) NSMutableArray *testFriendRequests;

@end

@implementation testZSSLocalQuerier

- (void)setUp {
    [PFUser logInWithUsername:@"zach" password:@"nets27"];
    [self createTestCoreDataObjects];
}

- (void)tearDown {
    [PFUser logOut];
    [self deleteCreatedCoreDataObjects];
}

- (void)testInitialization {
    XCTAssertNoThrow([ZSSLocalQuerier sharedQuerier]);
}

- (void)testFriends {
    NSArray *friends = [[ZSSLocalQuerier sharedQuerier] friends];
    XCTAssert([friends count] > 0);
    for (ZSSUser *friend in friends) {
        XCTAssertNotNil(friend.username);
        XCTAssertNotNil(friend.email);
        XCTAssertNotNil(friend.createdAt);
        XCTAssertNotNil(friend.lastSynced);
        XCTAssertNotNil(friend.objectId);
    }
    
}

- (void)testSentMessags {
    NSArray *sentMessages = [[ZSSLocalQuerier sharedQuerier] sentMessages];
    XCTAssert([sentMessages count] > 0);
    for (ZSSMessage *message in sentMessages) {
        XCTAssertNotNil(message.objectId);
        XCTAssertNotNil(message.sender);
        XCTAssertNotNil(message.receiver);
        XCTAssertNotNil(message.messageInfo);
        XCTAssertNotNil(message.dateSent);
        XCTAssertNotNil(message.dateReceived);
        XCTAssertNotNil(message.dateViewed);
        XCTAssertNotNil(message.lastSynced);
        
        XCTAssertNotNil(message.createdAt);
    }
}

- (void)testReceivedMessages {
    NSArray *receivedMessages = [[ZSSLocalQuerier sharedQuerier] receivedMessages];
    XCTAssert([receivedMessages count] > 0);
    for (ZSSMessage *message in receivedMessages) {
        XCTAssertNotNil(message.objectId);
        XCTAssertNotNil(message.sender);
        XCTAssertNotNil(message.receiver);
        XCTAssertNotNil(message.messageInfo);
        XCTAssertNotNil(message.dateSent);
        XCTAssertNotNil(message.dateReceived);
        XCTAssertNotNil(message.dateViewed);
        XCTAssertNotNil(message.lastSynced);
        XCTAssertNotNil(message.createdAt);
    }
}

- (void)testSentFriendRequests {
    NSArray *sentFriendRequests = [[ZSSLocalQuerier sharedQuerier] sentFriendRequests];
    XCTAssert([sentFriendRequests count] > 0);
    for (ZSSFriendRequest *friendRequest in sentFriendRequests) {
        XCTAssertNotNil(friendRequest.objectId);
        XCTAssertNotNil(friendRequest.sender);
        XCTAssertNotNil(friendRequest.receiver);
        XCTAssertNotNil(friendRequest.confirmed);
        XCTAssertNotNil(friendRequest.dateSent);
        XCTAssertNotNil(friendRequest.dateConfirmed);
        XCTAssertNotNil(friendRequest.lastSynced);
        XCTAssertNotNil(friendRequest.createdAt);
    }
}

- (void)testReceivedFriendRequests {
    NSArray *receivedFriendRequests = [[ZSSLocalQuerier sharedQuerier] receivedFriendRequests];
    XCTAssert([receivedFriendRequests count] > 0);
    for (ZSSFriendRequest *friendRequest in receivedFriendRequests) {
        XCTAssertNotNil(friendRequest.objectId);
        XCTAssertNotNil(friendRequest.sender);
        XCTAssertNotNil(friendRequest.receiver);
        XCTAssertNotNil(friendRequest.confirmed);
        XCTAssertNotNil(friendRequest.dateSent);
        XCTAssertNotNil(friendRequest.dateConfirmed);
        XCTAssertNotNil(friendRequest.lastSynced);
        XCTAssertNotNil(friendRequest.createdAt);
    }
}

- (void)testLocalUserForCloudUser {
    ZSSUser *currentLocalUser = [[ZSSLocalQuerier sharedQuerier] localUserForCloudUser:[PFUser currentUser]];
    XCTAssert([currentLocalUser.username isEqual:@"zach"]);
    XCTAssert([currentLocalUser.email isEqual:@"theshakked@gmail.com"]);
    XCTAssert([currentLocalUser.createdAt isEqual:[[PFUser currentUser] createdAt]]);
    XCTAssert([currentLocalUser.lastSynced isEqual:[[PFUser currentUser] valueForKey:@"lastSynced"]]);
    XCTAssert([currentLocalUser.objectId isEqual:[[PFUser currentUser] objectId]]);
}

- (void)testLocalMessageForCloudMessage {
    [[ZSSCloudQuerier sharedQuerier] fetchMessagesWithCompletionBlock:^(NSArray *messages, NSError *error) {
        XCTAssertNil(error);
        for (PFObject *message in messages) {
            ZSSMessage *localMessage = [[ZSSLocalQuerier sharedQuerier] localMessageForCloudMessage:message];
            [self.testMessages addObject:localMessage];
            
            XCTAssert([localMessage.objectId isEqual:[message objectId]]);
            XCTAssert([localMessage.sender isEqual:[[ZSSLocalQuerier sharedQuerier] localUserForCloudUser:message[@"sender"]]]);
            XCTAssert([localMessage.receiver isEqual:[[ZSSLocalQuerier sharedQuerier] localUserForCloudUser:message[@"receiver"]]]);
            XCTAssert([localMessage.messageInfo isEqual:message[@"messageInfo"]]);
            XCTAssert([localMessage.dateSent isEqual:message[@"dateSent"]]);
            XCTAssert([localMessage.dateReceived isEqual:message[@"dateReceived"]]);
            XCTAssert([localMessage.dateViewed isEqual:message[@"dateViewed"]]);
            XCTAssert([localMessage.lastSynced isEqual:message[@"lastSynced"]]);
            XCTAssert([localMessage.createdAt isEqual:[message createdAt]]);
        }
    }];
}


- (void)testLocalFriendRequestForCloudFriendRequest {
    [[ZSSCloudQuerier sharedQuerier] fetchFriendRequestsWithCompletionBlock:^(NSArray *friendRequests, NSError *error) {
        XCTAssertNil(error);
        for (PFObject *friendRequest in friendRequests) {
            ZSSFriendRequest *localFriendRequest = [[ZSSLocalQuerier sharedQuerier] localFriendRequestForCloudFriendRequest:friendRequest];
            [self.testFriendRequests addObject:localFriendRequest];
            
            XCTAssert([localFriendRequest.objectId isEqual:[friendRequest objectId]]);
            XCTAssert([localFriendRequest.sender isEqual:[[ZSSLocalQuerier sharedQuerier] localUserForCloudUser:friendRequest[@"sender"]]]);
            XCTAssert([localFriendRequest.receiver isEqual:[[ZSSLocalQuerier sharedQuerier] localUserForCloudUser:friendRequest[@"receiver"]]]);
            XCTAssert([localFriendRequest.confirmed isEqual:friendRequest[@"confirmed"]]);
            XCTAssert([localFriendRequest.dateSent isEqual:friendRequest[@"dateSent"]]);
            XCTAssert([localFriendRequest.dateConfirmed isEqual:friendRequest[@"dateReceived"]]);
            XCTAssert([localFriendRequest.lastSynced isEqual:friendRequest[@"lastSynced"]]);
            XCTAssert([localFriendRequest.createdAt isEqual:[friendRequest createdAt]]);
        }
    }];

}

- (void)createTestCoreDataObjects {
    ZSSUser *zach = [[ZSSLocalQuerier sharedQuerier] localUserForCloudUser:[PFUser currentUser]];
    
    ZSSUser *bob = [[ZSSLocalFactory sharedFactory] createUser];
    bob.username = @"bob";
    bob.email = @"bob@gmail.com";
    bob.createdAt = [NSDate date];
    bob.lastSynced = [NSDate date];
    bob.objectId = @"bob_id";
    
    ZSSUser *fred = [[ZSSLocalFactory sharedFactory] createUser];
    fred.username = @"fred";
    fred.email = @"fred@gmail.com";
    fred.createdAt = [NSDate date];
    fred.lastSynced = [NSDate date];
    fred.objectId = @"fred_id";
    
    [zach addFriendsObject:bob];
    [zach addFriendsObject:fred];
    
    ZSSFriendRequest *bobAndZach = [[ZSSLocalFactory sharedFactory] createFriendRequest];
    bobAndZach.objectId = @"bob_and_zach";
    bobAndZach.sender = bob;
    bobAndZach.receiver = zach;
    bobAndZach.confirmed = @YES;
    bobAndZach.dateSent = [NSDate date];
    bobAndZach.dateConfirmed = [NSDate date];
    bobAndZach.lastSynced = [NSDate date];
    bobAndZach.createdAt = [NSDate date];
    
    ZSSFriendRequest *zachAndFred = [[ZSSLocalFactory sharedFactory] createFriendRequest];
    zachAndFred.objectId = @"zach_and_fred";
    zachAndFred.sender = zach;
    zachAndFred.receiver = fred;
    zachAndFred.confirmed = @YES;
    zachAndFred.dateSent = [NSDate date];
    zachAndFred.dateConfirmed = [NSDate date];
    zachAndFred.lastSynced = [NSDate date];
    zachAndFred.createdAt = [NSDate date];
    
    ZSSMessage *bobToZach = [[ZSSLocalFactory sharedFactory] createMessage];
    bobToZach.objectId = @"bob_to_zach";
    bobToZach.sender = bob;
    bobToZach.receiver = zach;
    bobToZach.messageInfo = @{@"messageText" : @"you smell zach"};
    bobToZach.dateSent = [NSDate date];
    bobToZach.dateReceived = [NSDate date];
    bobToZach.dateViewed = [NSDate date];
    bobToZach.lastSynced = [NSDate date];
    bobToZach.createdAt = [NSDate date];
    
    ZSSMessage *zachToFred = [[ZSSLocalFactory sharedFactory] createMessage];
    zachToFred.objectId = @"zach_to_fred";
    zachToFred.sender = zach;
    zachToFred.receiver = fred;
    zachToFred.messageInfo = @{@"messageText" : @"you smell fred"};
    zachToFred.dateSent = [NSDate date];
    zachToFred.dateReceived = [NSDate date];
    zachToFred.dateViewed = [NSDate date];
    zachToFred.lastSynced = [NSDate date];
    zachToFred.createdAt = [NSDate date];
    
    self.testUsers = [[NSMutableArray alloc] initWithArray:@[zach, bob, fred]];
    self.testMessages = [[NSMutableArray alloc] initWithArray:@[zachToFred, bobToZach]];
    self.testFriendRequests = [[NSMutableArray alloc] initWithArray:@[bobAndZach, zachAndFred]];
}

- (void)deleteCreatedCoreDataObjects {
    for (ZSSUser *user in self.testUsers) {
        [[ZSSLocalStore sharedStore] deleteUser:user];
    }
    for (ZSSMessage *message in self.testMessages) {
        [[ZSSLocalStore sharedStore] deleteMessage:message];
    }
    for (ZSSFriendRequest *friendRequest in self.testFriendRequests) {
        [[ZSSLocalStore sharedStore] deleteFriendRequest:friendRequest];
    }
    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
}

@end

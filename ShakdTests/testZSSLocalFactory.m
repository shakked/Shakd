//
//  testZSSLocalFactory.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "testZSSLocalFactory.h"
#import "CoreDataObjects.h"
#import "ZSSLocalFactory.h"
#import "ZSSLocalStore.h"

@implementation testZSSLocalFactory

- (void)testInitialization {
    XCTAssertNoThrow([ZSSLocalFactory sharedFactory]);
}

- (void)testUserCreateAndDelete {
    NSUInteger userCount = [[[ZSSLocalStore sharedStore] users] count];
    ZSSUser *user = [[ZSSLocalFactory sharedFactory] createUser];
    NSUInteger userCountAfterCreation = [[[ZSSLocalStore sharedStore] users] count];
    XCTAssert(userCount + 1 == userCountAfterCreation);
    [[ZSSLocalFactory sharedFactory] deleteUser:user];
    NSUInteger userCountAfterDeletion = [[[ZSSLocalStore sharedStore]  users] count];
    XCTAssert(userCountAfterCreation - 1 == userCountAfterDeletion);
    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
}

- (void)testMessageCreateAndDelete {
    NSUInteger messageCount = [[[ZSSLocalStore sharedStore] messages] count];
    ZSSMessage *message = [[ZSSLocalFactory sharedFactory] createMessage];
    NSUInteger messageCountAfterCreation = [[[ZSSLocalStore sharedStore] messages] count];
    XCTAssert(messageCount + 1 == messageCountAfterCreation);
    [[ZSSLocalFactory sharedFactory] deleteMessage:message];
    NSUInteger messageCountAfterDeletion = [[[ZSSLocalStore sharedStore] messages] count];
    XCTAssert(messageCountAfterCreation - 1 == messageCountAfterDeletion);
    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
}

- (void)testFriendRequestCreateAndDelete {
    NSUInteger friendRequestCount = [[[ZSSLocalStore sharedStore] friendRequests] count];
    ZSSFriendRequest *friendRequest = [[ZSSLocalFactory sharedFactory] createFriendRequest];
    NSUInteger friendRequestCountAfterCreation = [[[ZSSLocalStore sharedStore] friendRequests] count];
    XCTAssert(friendRequestCount + 1 == friendRequestCountAfterCreation);
    [[ZSSLocalFactory sharedFactory] deleteFriendRequest:friendRequest];
    NSUInteger friendRequestCountAfterDeletion = [[[ZSSLocalStore sharedStore] friendRequests] count];
    XCTAssert(friendRequestCountAfterCreation - 1 == friendRequestCountAfterDeletion);
    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
}

@end

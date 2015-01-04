//
//  ShakdTests.m
//  ShakdTests
//
//  Created by Zachary Shakked on 12/27/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ZSSLocalStore.h"
#import "ZSSLocalQuerier.h"
@interface ShakdTests : XCTestCase

@end

@implementation ShakdTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [PFUser logOut];
}

- (void)testExample {
//    ZSSUser *bob = [[ZSSLocalStore sharedStore] fetchUserWithObjectId:@"bob_id"];
//    [[ZSSLocalStore sharedStore] deleteUser:bob];
//
//    ZSSUser *fred = [[ZSSLocalStore sharedStore] fetchUserWithObjectId:@"fred_id"];
//    [[ZSSLocalStore sharedStore] deleteUser:fred];
//
//    ZSSMessage *bobToZach = [[ZSSLocalStore sharedStore] fetchMessageWithObjectId:@"bob_to_zach"];
//    [[ZSSLocalStore sharedStore] deleteMessage:bobToZach];
//    ZSSMessage *zachToFred = [[ZSSLocalStore sharedStore] fetchMessageWithObjectId:@"zach_to_fred"];
//    [[ZSSLocalStore sharedStore] deleteMessage:zachToFred];
//    
//    ZSSFriendRequest *bobAndZach = [[ZSSLocalStore sharedStore] fetchFriendRequestWithObjectId:@"bob_and_zach"];
//    [[ZSSLocalStore sharedStore] deleteFriendRequest:bobAndZach];
//    ZSSFriendRequest *zachAndFred =[[ZSSLocalStore sharedStore] fetchFriendRequestWithObjectId:@"zach_and_fred"];
//    [[ZSSLocalStore sharedStore] deleteFriendRequest:zachAndFred];
//    
//    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

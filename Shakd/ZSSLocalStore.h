//
//  ZSSLocalStore.h
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataObjects.h"

@import CoreData;

@interface ZSSLocalStore : NSObject

+ (instancetype)sharedStore;
- (BOOL)saveCoreDataChanges;
- (void)logCoreDataStatus;


- (NSArray *)users;
- (NSArray *)messages;
- (NSArray *)friendRequests;

- (id)createNewObjectForEntity:(NSString *)entityName;
- (void)deleteUser:(ZSSUser *)user;
- (void)deleteMessage:(ZSSMessage *)message;
- (void)deleteFriendRequest:(ZSSFriendRequest *)friendRequest;
- (ZSSUser *)fetchUserWithObjectId:(NSString *)objectId;
- (ZSSMessage *)fetchMessageWithObjectId:(NSString *)objectId;
- (ZSSFriendRequest *)fetchFriendRequestWithObjectId:(NSString *)objectId;
@end

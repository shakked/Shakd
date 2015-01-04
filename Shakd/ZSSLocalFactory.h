//
//  ZSSLocalFactory.h
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZSSUser;
@class ZSSMessage;
@class ZSSFriendRequest;

@interface ZSSLocalFactory : NSObject

+ (instancetype)sharedFactory;

- (ZSSUser *)createUser;
- (ZSSMessage *)createMessage;
- (ZSSFriendRequest *)createFriendRequest;
- (void)deleteUser:(ZSSUser *)user;
- (void)deleteMessage:(ZSSMessage *)message;
- (void)deleteFriendRequest:(ZSSFriendRequest *)friendRequest;
@end

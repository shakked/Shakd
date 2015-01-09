//
//  ZSSLocalFactory.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSLocalFactory.h"
#import "ZSSUser.h"
#import "ZSSMessage.h"
#import "ZSSFriendRequest.h"
#import "ZSSLocalStore.h"


@implementation ZSSLocalFactory

+ (instancetype)sharedFactory {
    
    static ZSSLocalFactory *sharedFactory = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedFactory = [[self alloc] initPrivate];
    });
    return sharedFactory;
}

- (ZSSUser *)createUser {
    
    return [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSUser"];
}

- (ZSSMessage *)createMessage {
    
    return [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSMessage"];
}

- (ZSSFriendRequest *)createFriendRequest {
    
    return [[ZSSLocalStore sharedStore] createNewObjectForEntity:@"ZSSFriendRequest"];
}

- (void)deleteUser:(ZSSUser *)user {
    
    [[ZSSLocalStore sharedStore] deleteUser:user];
}

- (void)deleteMessage:(ZSSMessage *)message {
    
    [[ZSSLocalStore sharedStore] deleteMessage:message];
}

- (void)deleteFriendRequest:(ZSSFriendRequest *)friendRequest {
    
    [[ZSSLocalStore sharedStore] deleteFriendRequest:friendRequest];
}

- (instancetype)initPrivate {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)init {
    
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use [ZSSLocalFactory sharedFactory]"
                                 userInfo:nil];
    return nil;
}


@end

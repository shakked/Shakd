//
//  ZSSCloudQuerier.m
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSCloudQuerier.h"

@implementation ZSSCloudQuerier

+ (instancetype)sharedQuerier {
    static ZSSCloudQuerier *sharedQuerier = nil;
    if (!sharedQuerier) {
        sharedQuerier = [[self alloc] initPrivate];
    }
    return sharedQuerier;
}

- (void)fetchMessagesInBackgroundWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    PFQuery *sentMessagesQuery = [self sentMessagesQuery];
    PFQuery *receivedMessagesQuery = [self receivedMessagesQuery];
    PFQuery *messageQuery = [PFQuery orQueryWithSubqueries:@[sentMessagesQuery, receivedMessagesQuery]];
    [self executeQuery:messageQuery withCompletionBlock:completionBlock];
}

- (void)fetchFriendRequestsInBackgroundWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    PFQuery *sentFriendRequestQuery = [self sentFriendRequestsQuery];
    PFQuery *receivedFriendRequestsQuery = [self receivedFriendRequestQuery];
    PFQuery *friendRequestQuery = [PFQuery orQueryWithSubqueries:@[sentFriendRequestQuery, receivedFriendRequestsQuery]];
    [self executeQuery:friendRequestQuery withCompletionBlock:completionBlock];
}

- (void)logInUserWithUsername:(NSString *)username
                  andPassword:(NSString *)password
InBackgroundWithCompletionBlock:(void (^)(PFUser *, NSError *))completionBlock {
    if (![self userIsLoggedIn]) {
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            completionBlock(user, error);
        }];
    } else {
        [self throwAlreadyLoggedInException];
    }
}

- (void)signUpUser:(PFUser *)user inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    if (![self userIsLoggedIn]) {
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            completionBlock(succeeded, error);
        }];
    } else {
        [self throwAlreadyLoggedInException];
    }
}

- (void)executeQuery:(PFQuery *)query withCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    
    if ([self userIsLoggedIn]) {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                completionBlock(objects, error);
            } else {
                [self throwQueryFailedException:error];
            }
        }];
    } else {
        [self throwQueryNotPossibleException];
    }
}

- (void)throwQueryNotPossibleException {
    @throw [NSException exceptionWithName:@"QueryNotPossible"
                                   reason:@"[PFUser currentUser] does not exist"
                                 userInfo:nil];
}

- (void)throwAlreadyLoggedInException {
    @throw [NSException exceptionWithName:@"LogInNotPossible"
                                   reason:@"PFUser is already logged in"
                                 userInfo:nil];
}

- (void)throwQueryFailedException:(NSError *)error {
    @throw [NSException exceptionWithName:@"QueryFailed"
                                   reason:[error localizedDescription]
                                 userInfo:nil];
}


- (PFQuery *)sentMessagesQuery {
    PFQuery *sentMessagesQuery = [PFQuery queryWithClassName:@"ZSSMessage"];
    [sentMessagesQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [sentMessagesQuery orderByDescending:@"createdAt"];
    [sentMessagesQuery setLimit:100];
    [sentMessagesQuery includeKey:@"receiver"];
    return sentMessagesQuery;
}

- (PFQuery *)receivedMessagesQuery {
    PFQuery *receivedMessagesQuery = [PFQuery queryWithClassName:@"ZSSMessage"];
    [receivedMessagesQuery whereKey:@"receiver" equalTo:[PFUser currentUser]];
    [receivedMessagesQuery orderByDescending:@"createdAt"];
    [receivedMessagesQuery setLimit:100];
    [receivedMessagesQuery includeKey:@"sender"];
    return receivedMessagesQuery;
}

- (PFQuery *)sentFriendRequestsQuery {
    PFQuery *sentFriendRequestQuery = [PFQuery queryWithClassName:@"ZSSFriendRequest"];
    [sentFriendRequestQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    [sentFriendRequestQuery orderByDescending:@"createdAt"];
    [sentFriendRequestQuery setLimit:100];
    [sentFriendRequestQuery includeKey:@"receiver"];
    return sentFriendRequestQuery;
}

- (PFQuery *)receivedFriendRequestQuery {
    PFQuery *receivedFriendRequestQuery = [PFQuery queryWithClassName:@"ZSSFriendRequest"];
    [receivedFriendRequestQuery whereKey:@"receiver" equalTo:[PFUser currentUser]];
    [receivedFriendRequestQuery orderByDescending:@"createdAt"];
    [receivedFriendRequestQuery setLimit:100];
    [receivedFriendRequestQuery includeKey:@"sender"];
    return receivedFriendRequestQuery;
}




- (BOOL)userIsLoggedIn {
    if ([PFUser currentUser]) {
        return YES;
    } else {
        return NO;
    }
}

- (instancetype)initPrivate {
    
    self = [super init];
    if (self) {

    }
    return self;
}

- (instancetype)init {
    
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use [ZSSCloudQuerier sharedQuerier]"
                                 userInfo:nil];
    return nil;
}
@end


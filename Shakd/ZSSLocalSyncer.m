//
//  ZSSLocalSyncer.m
//  Shakd
//
//  Created by Zachary Shakked on 12/31/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSLocalSyncer.h"
#import "ZSSLocalQuerier.h"
#import "ZSSCloudQuerier.h"
#import "ZSSLocalStore.h"
#import "CoreDataObjects.h"
#import "ZSSLocalFactory.h"
#import <Parse/Parse.h>

@interface ZSSLocalSyncer ()

@property (nonatomic, strong) ZSSUser *currentLocalUser;

@end

@implementation ZSSLocalSyncer

#warning Remember to get rid of exceptions in CloudQuery methods to not crash app when no network is available

+ (instancetype)sharedSyncer {
    static ZSSLocalSyncer *sharedSyncer = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedSyncer = [[self alloc] initPrivate];
    });
    return sharedSyncer;
}

- (void)syncMessagesWithCompletionBlock:(void (^)(NSArray *,NSError *))completionBlock {
    [[ZSSCloudQuerier sharedQuerier] fetchMessagesInBackgroundWithCompletionBlock:^(NSArray *messages, NSError *error) {
        if (!error) {
            for (PFObject *message in messages) {
                [[ZSSLocalQuerier sharedQuerier] localMessageForCloudMessage:message];
            }
            [[ZSSLocalStore sharedStore] saveCoreDataChanges];
        }
        completionBlock(messages, error);
        
    }];
}

- (void)syncFriendRequestsWithCompletionBlock:(void (^)(NSArray *,NSError *))completionBlock {
    
    [[ZSSCloudQuerier sharedQuerier] fetchFriendRequestsInBackgroundWithCompletionBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            for (PFObject *friendRequest in friendRequests) {
                [[ZSSLocalQuerier sharedQuerier] localFriendRequestForCloudFriendRequest:friendRequest];
            }
            [[ZSSLocalStore sharedStore] saveCoreDataChanges];
        }
        
        completionBlock(friendRequests, error);
    }];
}

- (void)setCurrentLocalUser {
    if ([PFUser currentUser]) {
        self.currentLocalUser = [[ZSSLocalQuerier  sharedQuerier] localUserForCloudUser:[PFUser currentUser]];
    } else {
        [self throwPFUserIsNilException];
    }
}

- (void)throwPFUserIsNilException {
    @throw [NSException exceptionWithName:@"PFUser is nil"
                                   reason:@"[PFUser currentUser] does not exist"
                                 userInfo:nil];
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self setCurrentLocalUser];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use [ZSSLocalSyncer sharedSyncer]"
                                 userInfo:nil];
    return nil;
}

@end

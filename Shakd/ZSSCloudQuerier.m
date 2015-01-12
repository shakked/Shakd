//
//  ZSSCloudQuerier.m
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSCloudQuerier.h"
#import "RKDropdownAlert+CommonAlerts.h"
#import "UIColor+ShakdColors.h"
#import "ZSSMessage.h"
#import "ZSSLocalQuerier.h"
#import "ZSSLocalStore.h"

static int THROTTLE_TIME = 2;
@interface ZSSCloudQuerier ()

@property (nonatomic, strong) NSDate *timeOfLastFriendRequestFetch;
@property (nonatomic, strong) NSDate *timeOfLastMessageFetch;
@property (nonatomic, strong) NSDate *timeOfLastLogInAttempt;
@property (nonatomic, strong) NSDate *timeOfLastSignUpAttempt;
@property (nonatomic, strong) NSDate *timeOfLastPasswordResetAttempt;
@property (nonatomic, strong) NSDate *timeOfLastSendFriendRequestAttempt;

@end

@implementation ZSSCloudQuerier

+ (instancetype)sharedQuerier {
    static ZSSCloudQuerier *sharedQuerier = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedQuerier = [[self alloc] initPrivate];
    });
    
    return sharedQuerier;
}

- (void)fetchMessagesInBackgroundWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastMessageFetch]) {
        PFQuery *messagesQuery = [self messagesQuery];
        [self executeQuery:messagesQuery withCompletionBlock:completionBlock];
        self.timeOfLastMessageFetch = [NSDate date];
    }
}

- (void)fetchFriendRequestsInBackgroundWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastFriendRequestFetch]) {
        PFQuery *friendRequestsQuery = [self friendRequestsQuery];
        [self executeQuery:friendRequestsQuery withCompletionBlock:completionBlock];
        self.timeOfLastFriendRequestFetch = [NSDate date];
    }
}

- (void)logInUserWithUsername:(NSString *)username
                  andPassword:(NSString *)password
InBackgroundWithCompletionBlock:(void (^)(PFUser *, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastLogInAttempt]) {
        if (![self userIsLoggedIn]) {
            [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
                completionBlock(user, error);
            }];
        } else {
            [self throwAlreadyLoggedInException];
        }
        self.timeOfLastLogInAttempt = [NSDate date];
    } else {
        NSError *error = [self throttleError];
        completionBlock(nil, error);
    }
}

- (void)signUpUser:(PFUser *)user inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastSignUpAttempt]) {
        if (![self userIsLoggedIn]) {
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                completionBlock(succeeded, error);
            }];
        } else {
            [self throwAlreadyLoggedInException];
        }
        self.timeOfLastSignUpAttempt = [NSDate date];
    } else {
        NSError *error = [self throttleError];
        completionBlock(NO, error);
    }
    
}

- (void)resetPasswordForEmail:(NSString *)email inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastPasswordResetAttempt]) {
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
            completionBlock(succeeded, error);
        }];
    }
};

- (void)sendFriendRequestToUsername:(NSString *)username inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastSendFriendRequestAttempt]) {
        if ([self userIsLoggedIn]) {
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:username];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error && [objects count] == 1) {
                    PFObject *friendRequest = [self friendRequestToReceiver:(PFUser *)[objects firstObject]];
                    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        completionBlock(succeeded, error);
                    }];
                } else if ([objects count] == 0){
                    completionBlock(NO, error);
                } else {
                    [self throwMoreObjectsThanExpectedException];
                }
            }];
        }
        self.timeOfLastSendFriendRequestAttempt = [NSDate date];
    } else {
        NSError *error = [self throttleError];
        completionBlock(NO, error);
    }
}

- (void)viewMessage:(ZSSMessage *)localMessage inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    PFQuery *messageQuery = [self messageQueryForObjectId:localMessage.objectId];
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && [objects count] == 1) {
            PFObject *cloudMessage = [objects firstObject];
            NSDate *now = [NSDate date];
            cloudMessage[@"dateViewed"] = now;
            [cloudMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
 
                completionBlock(succeeded, error);
                localMessage.dateViewed = now;
                [self adjustBadge];
            }];
        } else if ([objects count] == 0){
            completionBlock(NO, error);
        } else {
            [self throwMoreObjectsThanExpectedException];
        }
    }];
}

- (void)sendMessageToUsers:(NSArray *)users withMessageInfo:(NSDictionary *)messageInfo withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    PFQuery *usersQuery = [PFUser query];
    NSArray *userIds = [self userObjectIds:users];
    [usersQuery whereKey:@"objectId" containedIn:userIds];
    [usersQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        NSMutableArray *messages = [[NSMutableArray alloc] init];

        for (PFUser *receiver in users) {
            PFObject *message = [self messageToUser:receiver withMessageInfo:messageInfo];
            [messages addObject:message];
        }
        
        [PFObject saveAllInBackground:messages block:^(BOOL succeeded, NSError *error) {
            completionBlock(succeeded, error);
        }];
    }];
}

- (void)adjustBadge {
    NSInteger unreadMessagesCount = [[[ZSSLocalQuerier sharedQuerier] unreadMessages] count];
    [[PFInstallation currentInstallation] setBadge:unreadMessagesCount];
}

- (void)executeQuery:(PFQuery *)query withCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    
    if ([self userIsLoggedIn]) { 
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            completionBlock(objects, error);
        }];
    } else {
        [self throwQueryNotPossibleException];
    }
}

- (PFObject *)friendRequestToReceiver:(PFUser *)receiver {
    PFObject *friendRequest = [PFObject objectWithClassName:@"ZSSFriendRequest"];
    friendRequest[@"sender"] = [PFUser currentUser];
    friendRequest[@"receiver"] = receiver;
    friendRequest[@"confirmed"] = @NO;
    friendRequest[@"dateSent"] = [NSDate date];
    return friendRequest;
}

- (NSArray *)filterUsers:(NSMutableArray *)users forSendlist:(NSArray *)sendlist {

    NSArray *sendlistObjectIds = [self userObjectIds:sendlist];
    for (PFUser *user in users) {
        if (![sendlistObjectIds containsObject:user.objectId]) {
            [users removeObject:user];
        }
    }
    return users;
}

- (NSArray *)userObjectIds:(NSArray *)users {
    NSMutableArray *objectIds = [[NSMutableArray alloc] init];
    for (ZSSUser *user in users) {
        [objectIds addObject:user.objectId];
    }
    return objectIds;
}

- (PFObject *)messageToUser:(PFUser *)receiver withMessageInfo:(NSDictionary *)messageInfo {
    PFObject *message = [PFObject objectWithClassName:@"ZSSMessage"];
    message[@"dateSent"] = [NSDate date];
    message[@"messageInfo"] = messageInfo;
    message[@"sender"] = [PFUser currentUser];
    message[@"receiver"] = receiver;
    return message;
}

- (void)throwQueryNotPossibleException {
    @throw [NSException exceptionWithName:@"QueryNotPossible"
                                   reason:@"[PFUser currentUser] does not exist"
                                 userInfo:nil];
}

- (void)throwMoreObjectsThanExpectedException {
    @throw [NSException exceptionWithName:@"MoreObjectsThanExpected"
                                   reason:@"More objects returned than expected"
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

- (NSError *)throttleError{
    NSError *error = [NSError errorWithDomain:@"Throttle" code:123 userInfo:@{@"error": @"Try again in a few seconds."}];
    return error;
}

- (PFQuery *)messagesQuery {
    PFQuery *sentMessagesQuery = [PFQuery queryWithClassName:@"ZSSMessage"];
    [sentMessagesQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    
    PFQuery *receivedMessagesQuery = [PFQuery queryWithClassName:@"ZSSMessage"];
    [receivedMessagesQuery whereKey:@"receiver" equalTo:[PFUser currentUser]];
    
    PFQuery *messagesQuery = [PFQuery orQueryWithSubqueries:@[sentMessagesQuery, receivedMessagesQuery]];
    [messagesQuery setLimit:100];
    [messagesQuery orderByDescending:@"createdAt"];
    [messagesQuery includeKey:@"sender"];
    [messagesQuery includeKey:@"receiver"];
    return messagesQuery;
}

- (PFQuery *)messageQueryForObjectId:(NSString *)objectId {
    PFQuery *messagesQuery = [self messagesQuery];
    [messagesQuery whereKey:@"objectId" equalTo:objectId];
    return messagesQuery;
}

- (PFQuery *)friendRequestsQuery {
    PFQuery *sentFriendRequestsQuery = [PFQuery queryWithClassName:@"ZSSFriendRequest"];
    [sentFriendRequestsQuery whereKey:@"sender" equalTo:[PFUser currentUser]];
    
    PFQuery *receivedFriendRequestsQuery = [PFQuery queryWithClassName:@"ZSSFriendRequest"];
    [receivedFriendRequestsQuery whereKey:@"receiver" equalTo:[PFUser currentUser]];
    
    PFQuery *friendRequestsQuery = [PFQuery orQueryWithSubqueries:@[sentFriendRequestsQuery, receivedFriendRequestsQuery]];
    [friendRequestsQuery includeKey:@"sender"];
    [friendRequestsQuery includeKey:@"receiver"];
    [friendRequestsQuery setLimit:100];
    [friendRequestsQuery orderByDescending:@"createdAt"];
    return friendRequestsQuery;
}

- (BOOL)userIsLoggedIn {
    if ([PFUser currentUser]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)hasBeenFiveSecondsSince:(NSDate *)time {
    NSDate *currentTime = [NSDate date];

    NSTimeInterval secs = [currentTime timeIntervalSinceDate:time];
    if (secs > THROTTLE_TIME) {
        return YES;
    } else {
        return NO;
    }
}

- (instancetype)initPrivate {
    
    self = [super init];
    if (self) {
        _timeOfLastMessageFetch = [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
        _timeOfLastFriendRequestFetch = [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
        _timeOfLastLogInAttempt = [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
        _timeOfLastSignUpAttempt = [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
        _timeOfLastPasswordResetAttempt = [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
        _timeOfLastSendFriendRequestAttempt = [NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970];
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


//
//  ZSSCloudQuerier.m
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSCloudQuerier.h"

@interface ZSSCloudQuerier ()

@property (nonatomic, strong) NSDate *timeOfLastFriendRequestFetch;
@property (nonatomic, strong) NSDate *timeOfLastMessageFetch;
@property (nonatomic, strong) NSDate *timeOfLastLogInAttempt;
@property (nonatomic, strong) NSDate *timeOfLastSignUpAttempt;
@property (nonatomic, strong) NSDate *timeOfLastPasswordResetAttempt;

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
    }
}

- (void)resetPasswordForEmail:(NSString *)email inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock {
    if ([self hasBeenFiveSecondsSince:self.timeOfLastPasswordResetAttempt]) {
        [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
            completionBlock(succeeded, error);
        }];
    }
};

- (void)executeQuery:(PFQuery *)query withCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock {
    
    if ([self userIsLoggedIn]) {
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            completionBlock(objects, error);
            
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
    NSLog(@"SECS: %f", secs);
    if (secs > 5) {
        NSLog(@"It's been five seconds..");
        return YES;
    } else {
        NSLog(@"NOPE");
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


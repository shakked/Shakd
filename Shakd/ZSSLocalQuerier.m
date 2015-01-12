//
//  ZSSLocalQuerier.m
//
//
//  Created by Zachary Shakked on 12/28/14.
//
//

#import "ZSSLocalQuerier.h"
#import "ZSSLocalStore.h"
#import <Parse/Parse.h>
#import "ZSSUser.h"
#import "ZSSMessage.h"
#import "ZSSFriendRequest.h"
#import "ZSSLocalFactory.h"

@interface ZSSLocalQuerier ()

@property (nonatomic, strong) ZSSUser *currentLocalUser;

@end

@implementation ZSSLocalQuerier

+ (instancetype)sharedQuerier {
    
    static ZSSLocalQuerier *sharedQuerier = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedQuerier = [[self alloc] initPrivate];
    });
    [sharedQuerier setCurrentLocalUser];
    return sharedQuerier;
}

- (ZSSUser *)localUserForCloudUser:(PFUser *)cloudUser {
    
    ZSSUser *userInSearchOf;
    NSArray *users = [[ZSSLocalStore sharedStore] users];
    for (ZSSUser *user in users) {
        if ([user.objectId isEqual:cloudUser.objectId]) {
            userInSearchOf = user;
        }
    }
    
    if (!userInSearchOf) {
        userInSearchOf = [[ZSSLocalFactory sharedFactory] createUser];
    }
    
    return [self updateLocalUser:userInSearchOf withDataOfCloudUser:cloudUser];
}

- (ZSSMessage *)localMessageForCloudMessage:(PFObject *)cloudMessage {
    ZSSMessage *messageInSearchOf = [[ZSSLocalStore sharedStore] fetchMessageWithObjectId:cloudMessage.objectId];
    
    if (!messageInSearchOf) {
        messageInSearchOf = [[ZSSLocalFactory sharedFactory] createMessage];
    }

    return [self updateLocalMessage:messageInSearchOf withDataOfCloudMessage:cloudMessage];
}


- (ZSSFriendRequest *)localFriendRequestForCloudFriendRequest:(PFObject *)cloudFriendRequest {
    
    ZSSFriendRequest *friendRequestInSearchOf;
    NSArray *friendRequests = [[ZSSLocalStore sharedStore] friendRequests];
    for (ZSSFriendRequest *friendRequest in friendRequests) {
        if ([friendRequest.objectId isEqual:cloudFriendRequest.objectId]) {
            friendRequestInSearchOf = friendRequest;
        }
    }
    
    if (!friendRequestInSearchOf) {
        friendRequestInSearchOf = [[ZSSLocalFactory sharedFactory] createFriendRequest];
    }
    
    return [self updateLocalFriendRequest:friendRequestInSearchOf withDataOfCloudFriendRequest:cloudFriendRequest];
}


- (NSArray *)friends {
    NSDictionary *confirmedFriendRequests = [self confirmedFriendRequests];
    
    NSArray *friends = [self extractFriendsFromConfirmedFriendRequests:confirmedFriendRequests];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortedFriends = [friends sortedArrayUsingDescriptors:@[sort]];
    return sortedFriends;
}

- (NSArray *)sentMessages {
    NSArray *messages = [[ZSSLocalStore sharedStore] messages];
    NSMutableArray *sentMessages = [[NSMutableArray alloc] init];
    
    for (ZSSMessage *message in messages) {
        if ([message.sender isEqual:self.currentLocalUser]) {
            [sentMessages addObject:message];
        }
    }
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateSent"
                                                                   ascending:NO];
    
    return [sentMessages sortedArrayUsingDescriptors:@[sortDescriptor]];;
}

- (NSArray *)receivedMessages {
    NSArray *messages = [[ZSSLocalStore sharedStore] messages];
    NSMutableArray *receivedMessages = [[NSMutableArray alloc] init];
    
    for (ZSSMessage *message in messages) {
        if ([message.receiver isEqual:self.currentLocalUser]) {
            [receivedMessages addObject:message];
        }
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateSent"
                                                                   ascending:NO];
    
    return [receivedMessages sortedArrayUsingDescriptors:@[sortDescriptor]];;
}

- (NSArray *)sentFriendRequests {
    NSArray *friendRequests = [[ZSSLocalStore sharedStore] friendRequests];
    NSMutableArray *sentFriendRequests = [[NSMutableArray alloc] init];
    
    for (ZSSFriendRequest *friendRequest in friendRequests) {
        if ([friendRequest.sender isEqual:self.currentLocalUser]) {
            [sentFriendRequests addObject:friendRequest];
        }
    }
    return sentFriendRequests;
}

- (NSArray *)receivedFriendRequests {
    NSArray *friendRequests = [[ZSSLocalStore sharedStore] friendRequests];
    NSMutableArray *receivedFriendRequests = [[NSMutableArray alloc] init];
    
    for (ZSSFriendRequest *friendRequest in friendRequests) {
        if ([friendRequest.receiver isEqual:self.currentLocalUser]) {
            [receivedFriendRequests addObject:friendRequest];
        }
    }
    return receivedFriendRequests;
}

- (NSArray *)friendRequests {
    return [[ZSSLocalStore sharedStore] friendRequests];
}

- (ZSSUser *)updateLocalUser:(ZSSUser *)localUser withDataOfCloudUser:(PFUser *)cloudUser {
    NSDate *startTime = [NSDate date];
    localUser.objectId = [cloudUser objectId];
    localUser.username = cloudUser[@"username"];
    localUser.email = cloudUser[@"email"];
    localUser.createdAt = [cloudUser createdAt];
    localUser.lastSynced = cloudUser[@"lastSynced"];

    return localUser;
}



- (ZSSMessage *)updateLocalMessage:(ZSSMessage *)localMessage withDataOfCloudMessage:(PFObject *)cloudMessage {
    localMessage.objectId = [cloudMessage objectId];
    localMessage.sender = [self localUserForCloudUser:cloudMessage[@"sender"]];
    localMessage.receiver = [self localUserForCloudUser:cloudMessage[@"receiver"]];
    localMessage.messageInfo = cloudMessage[@"messageInfo"];
    localMessage.createdAt = [cloudMessage createdAt];
    localMessage.dateSent = cloudMessage[@"dateSent"];
    localMessage.dateReceived = cloudMessage[@"dateReceived"];
    localMessage.dateViewed = cloudMessage[@"dateViewed"];
    localMessage.lastSynced = cloudMessage[@"lastSynced"];

    return localMessage;
    
}


- (ZSSFriendRequest *)updateLocalFriendRequest:(ZSSFriendRequest *)localFriendRequest withDataOfCloudFriendRequest:(PFObject *)cloudFriendRequest {
    localFriendRequest.objectId = [cloudFriendRequest objectId];
    localFriendRequest.sender = [self localUserForCloudUser:cloudFriendRequest[@"sender"]];
    localFriendRequest.receiver = [self localUserForCloudUser:cloudFriendRequest[@"receiver"]];
    localFriendRequest.confirmed = cloudFriendRequest[@"confirmed"];
    localFriendRequest.dateSent = cloudFriendRequest[@"dateSent"];
    localFriendRequest.dateConfirmed = cloudFriendRequest[@"dateConfirmed"];
    localFriendRequest.lastSynced = cloudFriendRequest[@"lastSynced"];
    localFriendRequest.createdAt = [cloudFriendRequest createdAt];
    return localFriendRequest;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        [self setCurrentLocalUser];
    }
    return self;
}

- (void)setCurrentLocalUser {
    if ([PFUser currentUser]) {
        self.currentLocalUser = [self localUserForCloudUser:[PFUser currentUser]];
    } else {
        [self throwPFUserIsNilException];
    }
}

- (NSDictionary *)confirmedFriendRequests {
    NSArray *sentFriendRequests = [self sentFriendRequests];
    NSArray *receivedFriendRequests = [self receivedFriendRequests];
    
    NSMutableArray *friendRequests = [[NSMutableArray alloc] init];
    [friendRequests addObjectsFromArray:sentFriendRequests];
    [friendRequests addObjectsFromArray:receivedFriendRequests];
    
    NSDictionary *confirmedFriendRequests = [self sortFriendRequests:friendRequests];
    return confirmedFriendRequests;
}

- (NSDictionary *)sortFriendRequests:(NSArray *)friendRequests {
    NSMutableArray *confirmedSentFriendRequests = [[NSMutableArray alloc] init];
    NSMutableArray *confirmedReceivedFriendRequests = [[NSMutableArray alloc] init];
    
    for (ZSSFriendRequest *friendRequest in friendRequests) {
        if ([friendRequest.confirmed isEqual:@YES]) {
            if ([friendRequest.sender isEqual:self.currentLocalUser]) {
                [confirmedSentFriendRequests addObject:friendRequest];
            } else if ([friendRequest.receiver isEqual:self.currentLocalUser]) {
                [confirmedReceivedFriendRequests addObject:friendRequest];
            } else {
                [self throwInvalidFriendRequestException];
            }
        }
    }
    
    return @{@"sentFriendRequests" : confirmedSentFriendRequests,
             @"receivedFriendRequests" : confirmedReceivedFriendRequests};
}

- (NSArray *)extractFriendsFromConfirmedFriendRequests:(NSDictionary *)confirmedFriendRequests {
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    NSArray *sentFriendRequests = confirmedFriendRequests[@"sentFriendRequests"];
    for (ZSSFriendRequest *sentFriendRequest in sentFriendRequests) {
        [friends addObject:sentFriendRequest.receiver];
    }
    
    NSArray *receivedFriendRequests = confirmedFriendRequests[@"receivedFriendRequests"];
    for (ZSSFriendRequest *receivedFriendRequest in receivedFriendRequests) {
        [friends addObject:receivedFriendRequest.sender];
    }
    return friends;
}

- (void)throwPFUserIsNilException {
    @throw [NSException exceptionWithName:@"PFUser is nil"
                                   reason:@"[PFUser currentUser] does not exist"
                                 userInfo:nil];
}

- (void)throwInvalidFriendRequestException {
    @throw [NSException exceptionWithName:@"InvalidFriendRequest"
                                   reason:@"Friend request receiver and sender is invalid"
                                 userInfo:nil];
}


- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use [ZSSLocalQuerier sharedQuerier]"
                                 userInfo:nil];
    return nil;
}

@end
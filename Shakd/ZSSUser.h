//
//  ZSSUser.h
//  Pods
//
//  Created by Zachary Shakked on 12/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZSSUser;

@interface ZSSUser : NSManagedObject

@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * lastSynced;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSSet *sentMessages;
@property (nonatomic, retain) NSSet *receievedMessages;
@property (nonatomic, retain) NSSet *sentFriendRequests;
@property (nonatomic, retain) NSSet *receivedFriendRequests;

@end

@interface ZSSUser (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(ZSSUser *)value;
- (void)removeFriendsObject:(ZSSUser *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)addSentMessagesObject:(NSManagedObject *)value;
- (void)removeSentMessagesObject:(NSManagedObject *)value;
- (void)addSentMessages:(NSSet *)values;
- (void)removeSentMessages:(NSSet *)values;

- (void)addReceievedMessagesObject:(NSManagedObject *)value;
- (void)removeReceievedMessagesObject:(NSManagedObject *)value;
- (void)addReceievedMessages:(NSSet *)values;
- (void)removeReceievedMessages:(NSSet *)values;

- (void)addSentFriendRequestsObject:(NSManagedObject *)value;
- (void)removeSentFriendRequestsObject:(NSManagedObject *)value;
- (void)addSentFriendRequests:(NSSet *)values;
- (void)removeSentFriendRequests:(NSSet *)values;

- (void)addReceivedFriendRequestsObject:(NSManagedObject *)value;
- (void)removeReceivedFriendRequestsObject:(NSManagedObject *)value;
- (void)addReceivedFriendRequests:(NSSet *)values;
- (void)removeReceivedFriendRequests:(NSSet *)values;

@end

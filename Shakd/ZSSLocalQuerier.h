//
//  ZSSLocalQuerier.h
//
//
//  Created by Zachary Shakked on 12/28/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@class ZSSUser;
@class ZSSMessage;
@class ZSSFriendRequest;

@interface ZSSLocalQuerier : NSObject

+ (instancetype)sharedQuerier;

- (ZSSUser *)localUserForCloudUser:(PFUser *)cloudUser;
- (ZSSMessage *)localMessageForCloudMessage:(PFObject *)cloudMessage;
- (ZSSFriendRequest *)localFriendRequestForCloudFriendRequest:(PFObject *)cloudFriendRequest;
- (NSArray *)friends;
- (NSArray *)sentMessages;
- (NSArray *)receivedMessages;
- (NSArray *)sentFriendRequests;
- (NSArray *)receivedFriendRequests;
- (NSArray *)friendRequests;
- (NSArray *)unreadMessages;

@end
//
//  ZSSCloudQuerier.h
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@class ZSSMessage;
@class ZSSFriendRequest;

@interface ZSSCloudQuerier : NSObject

+ (instancetype)sharedQuerier;
- (void)fetchMessagesWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock;
- (void)fetchFriendRequestsWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock;

- (void)logInUserWithUsername:(NSString *)username
            andPassword:(NSString *)password
          withCompletionBlock:(void (^)(PFUser *, NSError *))completionBlock;

- (void)signUpUser:(PFUser *)user withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock;

- (void)resetPasswordForEmail:(NSString *)email withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock;
- (void)sendFriendRequestToUsername:(NSString *)username withCompletionBlock:(void (^)(BOOL,NSError *))completionBlock;
- (void)viewMessage:(ZSSMessage *)message withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock;
- (void)acceptFriendRequest:(ZSSFriendRequest *)friendRequest withCompletionBlock:(void (^)(BOOL,NSError *))completionBlock;
- (void)sendMessageToUsers:(NSArray *)users
           withMessageInfo:(NSDictionary *)messageInfo
       withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock;
- (void)adjustBadge;
- (void)logOutUser;
- (void)deleteCloudMessagesForLocalMessages:(NSArray *)localMessage withCompletionBlock:(void (^)(BOOL, NSError *))completionBlock;

- (void)saveUserForCurrentInstallation;
@end

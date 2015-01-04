//
//  ZSSCloudQuerier.h
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ZSSCloudQuerier : NSObject

+ (instancetype)sharedQuerier;
- (void)fetchMessagesInBackgroundWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock;
- (void)fetchFriendRequestsInBackgroundWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock;
- (void)logInUserWithUsername:(NSString *)username
                  andPassword:(NSString *)password
InBackgroundWithCompletionBlock:(void (^)(PFUser *, NSError *))completionBlock;
- (void)signUpUser:(PFUser *)user inBackgroundWithCompletionBlock:(void (^)(BOOL, NSError *))completionBlock;

@end

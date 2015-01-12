//
//  ZSSLocalSyncer.h
//  Shakd
//
//  Created by Zachary Shakked on 12/31/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@class ZSSUser;

@interface ZSSLocalSyncer : NSObject

+ (instancetype)sharedSyncer;
- (void)syncMessagesWithCompletionBlock:(void (^)(NSArray *, NSError *))completionBlock;
- (void)syncFriendRequestsWithCompletionBlock:(void (^)(NSArray*, NSError *))completionBlock;

@end

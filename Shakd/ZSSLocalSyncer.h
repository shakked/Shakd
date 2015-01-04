//
//  ZSSLocalSyncer.h
//  Shakd
//
//  Created by Zachary Shakked on 12/31/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZSSUser;

@interface ZSSLocalSyncer : NSObject

+ (instancetype)sharedSyncer;
- (void)syncMessagesWithCompletionBlock:(void (^)(NSError *))completionBlock;
- (void)syncFriendRequestsWithCompletionBlock:(void (^)(NSError *))completionBlock;


@end

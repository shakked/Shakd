//
//  ZSSFriendRequest.h
//  Pods
//
//  Created by Zachary Shakked on 12/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZSSUser;

@interface ZSSFriendRequest : NSManagedObject

@property (nonatomic, retain) NSNumber * confirmed;
@property (nonatomic, retain) NSDate * dateSent;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDictionary *friendRequestInfo;
@property (nonatomic, retain) NSDate * dateConfirmed;
@property (nonatomic, retain) NSDate * lastSynced;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) ZSSUser *sender;
@property (nonatomic, retain) ZSSUser *receiver;

@end

//
//  ZSSMessage.h
//  Pods
//
//  Created by Zachary Shakked on 12/28/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZSSUser;

@interface ZSSMessage : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * dateSent;
@property (nonatomic, retain) NSDate * dateReceived;
@property (nonatomic, retain) NSDate * dateViewed;
@property (nonatomic, retain) id messageInfo;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSDate * lastSynced;
@property (nonatomic, retain) ZSSUser *sender;
@property (nonatomic, retain) ZSSUser *receiver;

@end

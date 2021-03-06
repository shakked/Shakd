//
//  ZSSMessage.m
//  Pods
//
//  Created by Zachary Shakked on 12/28/14.
//
//

#import "ZSSMessage.h"
#import "ZSSUser.h"


@implementation ZSSMessage

@dynamic objectId;
@dynamic sender;
@dynamic receiver;
@dynamic messageInfo;
@dynamic createdAt;
@dynamic dateSent;
@dynamic dateReceived;
@dynamic dateViewed;
@dynamic lastSynced;

- (BOOL)hasBeenViewed {
    if (self.dateViewed) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isNotTooLong {
    if ([self.messageInfo[@"messageText"] length] < 500) {
        return YES;
    }else {
        return NO;
    }
}

@end

//
//  ZSSMessagesTableViewController.h
//  Shakd
//
//  Created by Zachary Shakked on 1/9/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSMessagesTableViewController : UITableViewController

typedef NS_ENUM(NSInteger, ZSSMessagesTableState) {
    ZSSMessagesTableStateReceivedMessages,
    ZSSMessagesTableStateSentMessages
};

@end

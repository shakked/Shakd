//
//  ZSSFriendsTableViewController.h
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSSFriendsTableViewController : UITableViewController

typedef NS_ENUM(NSInteger, ZSSFriendsTableState) {
    ZSSFriendsTableStateViewing,
    ZSSFriendsTableStateSendingMessage
};

@property (nonatomic) ZSSFriendsTableState state;

@end

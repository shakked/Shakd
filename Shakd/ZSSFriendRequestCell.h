//
//  ZSSFriendRequestCell.h
//  Shakd
//
//  Created by Zachary Shakked on 1/8/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSSFriendRequest;

@interface ZSSFriendRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectFriendRequestButton;

@property (nonatomic, strong) void (^selectFriendRequestButtonBlock)(void);
@property (nonatomic, strong) ZSSFriendRequest *friendRequest;

typedef NS_ENUM(NSInteger, ZSSFriendRequestState) {
    ZSSFriendRequestCellSentDeniedState,
    ZSSFriendRequestCellSentConfirmedState,
    ZSSFriendRequestCellReceivedDeniedState,
    ZSSFriendRequestCellReceivedConfirmedState
};

@property (nonatomic) ZSSFriendRequestState state;

@end

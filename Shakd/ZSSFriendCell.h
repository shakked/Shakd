//
//  ZSSFriendCell.h
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSSUser;

@interface ZSSFriendCell : UITableViewCell

@property (nonatomic, strong) ZSSUser *friend;
@property (weak, nonatomic) IBOutlet UILabel *friendLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectFriendButton;
@property (nonatomic, strong) void (^selectFriendButtonPressedBlock)(void);
@end

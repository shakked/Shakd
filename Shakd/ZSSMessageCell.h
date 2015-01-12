//
//  ZSSMessageCell.h
//  Shakd
//
//  Created by Zachary Shakked on 1/9/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSSMessage.h"

@interface ZSSMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fromAndToLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIImageView *forwardImageView;
@property (weak, nonatomic) IBOutlet UILabel *forwardLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *playImageView;
@property (weak, nonatomic) IBOutlet UILabel *playLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressAndHoldLabel;


@property (nonatomic, strong) void (^playButtonPressedBlock)(void);
@property (nonatomic, strong) void (^replyButtonPressedBlock)(void);
@property (nonatomic, strong) void (^forwardButtonPressedBlock)(void);
@property (nonatomic, strong) void (^view)(void);

@property (nonatomic, strong) ZSSMessage *message;

@end

//
//  ZSSFriendCell.m
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSFriendCell.h"

@implementation ZSSFriendCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)selectFriendButtonPushed:(id)sender {
    self.selectFriendButtonPressedBlock();
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

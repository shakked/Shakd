//
//  ZSSMessageCell.m
//  Shakd
//
//  Created by Zachary Shakked on 1/9/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSMessageCell.h"

@implementation ZSSMessageCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)forwardButtonPressed:(id)sender {
    self.forwardButtonPressedBlock();
}

- (IBAction)playButtonPressed:(id)sender {
    self.playButtonPressedBlock();
}

- (IBAction)replyButtonPressed:(id)sender {
    self.replyButtonPressedBlock();
}

- (void)setFrame:(CGRect)frame {
    
    frame.origin.x += 5;
    frame.size.width -= 2 * 5;
    frame.size.height -= 5;
    [super setFrame:frame];
    
}


@end

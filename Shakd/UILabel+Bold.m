//
//  UILabel+Bold.m
//  Shakd
//
//  Created by Zachary Shakked on 1/12/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "UILabel+Bold.h"

@implementation UILabel (Bold)

- (void) boldRange: (NSRange) range {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"Avenir-Heavy" size:16.0]} range:range];
    
    self.attributedText = attributedText;
}

- (void) boldSubstring: (NSString*) substring {
    NSRange range = [self.text rangeOfString:substring];
    [self boldRange:range];
}

@end

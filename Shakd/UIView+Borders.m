//
//  UIView+Borders.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "UIView+Borders.h"

@implementation UIView (Borders)

- (void)addUpperBorder:(float)thickness withColor:(UIColor *)color {
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [color CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), thickness);
    [self.layer addSublayer:upperBorder];
}

- (void)addLowerBorder:(float)thickness withColor:(UIColor *)color {
    CALayer *lowerBorder = [CALayer layer];
    lowerBorder.backgroundColor = [color CGColor];
    lowerBorder.frame = CGRectMake(0, CGRectGetHeight(self.frame) - thickness, CGRectGetWidth(self.frame), thickness);
    [self.layer addSublayer:lowerBorder];
}

- (void)addRightBorder:(float)thickness withColor:(UIColor *)color {
    CALayer *rightBorder = [CALayer layer];
    rightBorder.backgroundColor = [color CGColor];
    rightBorder.frame = CGRectMake(CGRectGetWidth(self.frame) - thickness, 0, thickness, CGRectGetHeight(self.frame));
    [self.layer addSublayer:rightBorder];
}

- (void)addLeftBorder:(float)thickness withColor:(UIColor *)color {
    CALayer *leftBorder = [CALayer layer];
    leftBorder.backgroundColor = [color CGColor];
    leftBorder.frame = CGRectMake(0, 0, thickness, CGRectGetHeight(self.frame));
    [self.layer addSublayer:leftBorder];
}

@end

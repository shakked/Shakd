//
//  UIBarButtonItem+MyBarButtons.m
//  Shakd
//
//  Created by Zachary Shakked on 1/7/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "UIBarButtonItem+MyBarButtons.h"

@implementation UIBarButtonItem (MyBarButtons)

+ (instancetype)backBarButtonForVC:(UIViewController *)vc {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.bounds = CGRectMake(0, 0, 30, 30);
    [backButton setBackgroundImage:[UIImage imageNamed:@"BackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:vc action:@selector(showPreviousView) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

@end

//
//  ZSSHomeViewController.h
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GADBannerView;

@interface ZSSHomeViewController : UIViewController

- (void)configureViewForMessageInfo:(NSDictionary *)messageInfo;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

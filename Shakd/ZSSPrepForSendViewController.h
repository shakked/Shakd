//
//  ZSSPrepForSendViewController.h
//  Shakd
//
//  Created by Zachary Shakked on 1/12/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZSSMessage;
@class GADBannerView;
@interface ZSSPrepForSendViewController : UIViewController

@property (nonatomic, strong) ZSSMessage *message;
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

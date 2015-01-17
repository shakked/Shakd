//
//  ZSSSettingsViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/12/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSSettingsViewController.h"
#import "ZSSWelcomeViewController.h"
#import <Parse/Parse.h>
#import "ZSSCloudQuerier.h"
#import "ZSSLocalStore.h"

@interface ZSSSettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *greetingLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitFeedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (nonatomic, strong) NSArray *greetings;

@end

@implementation ZSSSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self generateGreeting];
}

- (void)generateGreeting {
    NSInteger greetingsCount = [self.greetings count];
    int random = arc4random() % greetingsCount;
    NSString *username = [[PFUser currentUser] username];
    NSString *greeting = self.greetings[random];
    self.greetingLabel.text = [NSString stringWithFormat:@"%@ %@",greeting, username];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitFeedbackButtonPressed:(id)sender {
#warning TODO
}

- (IBAction)logOutButtonPressed:(id)sender {
    [self logOut];
}

- (void)logOut {
    [[ZSSCloudQuerier sharedQuerier] logOutUser];
    [[ZSSLocalStore sharedStore] deleteAllObjects];
    [[PFInstallation currentInstallation] removeObjectForKey:@"user"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    ZSSWelcomeViewController *wvc = [[ZSSWelcomeViewController alloc] init];
    [self presentViewController:wvc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _greetings = @[@"Please don't go,", @"What's that smell,", @"Hey, don't I know you,", @"I heard you Shakd a frog once,", @"I hear you had a dream that you Shakd a squirrel,", @"Send me some feedback,", @"Isn't Shak-ing people fun? Glad you agree,", @"Writing these is fun..."];
    }
    return self;
}


@end

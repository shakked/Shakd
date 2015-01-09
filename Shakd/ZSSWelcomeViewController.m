//
//  ZSSWelcomeViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 12/28/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSWelcomeViewController.h"
#import "UIView+Borders.h"
#import "UIColor+ShakdColors.h"
#import "ZSSLoginViewController.h"
#import "ZSSSignUpViewController.h"

@interface ZSSWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *logoLabel;
@property (weak, nonatomic) IBOutlet UIView *loginSignupBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation ZSSWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
}
- (IBAction)logInPressed:(id)sender {
    [self showLoginView];
}

- (IBAction)signUpPressed:(id)sender {
    [self showSignUpView];
}

- (void)showLoginView {
    ZSSLoginViewController *loginViewController = [[ZSSLoginViewController alloc] init];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

- (void)showSignUpView {
    ZSSSignUpViewController *signUpViewController = [[ZSSSignUpViewController alloc] init];
    [self presentViewController:signUpViewController animated:YES completion:nil];
}

- (void)configureViews {
    [self.loginButton addLowerBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.loginButton setClipsToBounds:YES];
    [self.signUpButton addLowerBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.signUpButton setClipsToBounds:YES];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

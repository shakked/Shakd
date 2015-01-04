//
//  ZSSSignUpViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSSignUpViewController.h"
#import "UIColor+ShakdColors.h"
#import "UIView+Borders.h"

@interface ZSSSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation ZSSSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    
}

- (IBAction)signUpButtonPressed:(id)sender {
    
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureViews {
    [self configureTextFields];
}

- (void)configureTextFields {
    [self.emailTextField addLeftBorder:5.0 withColor:[UIColor lightGrayColor]];
    [self.emailTextField setClipsToBounds:YES];
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor lightGrayColor]];
    [self.usernameTextField setClipsToBounds:YES];
    [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor lightGrayColor]];
    [self.passwordTextField setClipsToBounds:YES];
}

@end

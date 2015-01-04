//
//  ZSSLoginViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 12/29/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "ZSSLoginViewController.h"
#import "UIColor+ShakdColors.h"
#import "UIView+Borders.h"
#import "ZSSCloudQuerier.h"
#import "RKDropdownAlert.h"
#import "NSString+Extras.h"

@interface ZSSLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation ZSSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    [self setDelegates];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logInButtonPressed:(id)sender {
    [self logInUser];
}

- (IBAction)signUpButtonPressed:(id)sender {
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
}

- (void)configureViews {
    [self configureTextFields];
}

- (void)setDelegates {
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)logInUser {
    [self dismissKeyboard];
    BOOL textFieldsAreFilledOut = [self textFieldsAreFilledOut];
    if (textFieldsAreFilledOut) {
         [[ZSSCloudQuerier sharedQuerier] logInUserWithUsername:self.usernameTextField.text
                                                    andPassword:self.passwordTextField.text
                                InBackgroundWithCompletionBlock:^(PFUser *user, NSError *error) {
                                    if (!error) {

                                    } else {
                                        [self showLogInError:error];
                                    }
                                }];
    } else {
        [self showEmptyFieldsError];
    }
}

- (void)configureTextFields {
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor lightGrayColor]];
    [self.usernameTextField setClipsToBounds:YES];
    [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor lightGrayColor]];
    [self.passwordTextField setClipsToBounds:YES];
}

#warning Log in makes local user?/ Banner dropdown for push notifications

- (BOOL)textFieldsAreFilledOut {
    if ([self.usernameTextField hasText] && [self.passwordTextField hasText]) {
         return YES;
    }else {
        return  NO;
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)showEmptyFieldsError {
    if (!self.usernameTextField.hasText) {
        [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    if (!self.passwordTextField.hasText) {
        [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    
    [RKDropdownAlert title:@"Ensure you fill out all fields" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
}

- (void)showLogInError:(NSError *)error {
    NSString *errorMessage = [error userInfo][@"error"];
    [RKDropdownAlert title:[errorMessage capitalString] backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
    
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField addLeftBorder:5.0 withColor:[UIColor lightGrayColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

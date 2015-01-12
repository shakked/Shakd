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
#import "ZSSSignUpViewController.h"
#import "AppDelegate.h"
#import "ZSSForgotPasswordViewController.h"
#import "ZSSHomeViewController.h"
#import "RKDropdownAlert+CommonAlerts.h"

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
    [self setDelegates];
    [self configureViews];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)logInButtonPressed:(id)sender {
    [self logInUser];
}

- (IBAction)signUpButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        ZSSSignUpViewController *signUpViewController = [[ZSSSignUpViewController alloc] init];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:signUpViewController animated:YES completion:nil];
    }];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    ZSSForgotPasswordViewController *fpvc = [[ZSSForgotPasswordViewController alloc] init];
    [self presentViewController:fpvc animated:YES completion:nil];
}

- (void)setDelegates {
    [self.usernameTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
}


- (void)configureViews {
    [self configureTextFields];
}

- (void)configureTextFields {
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.usernameTextField setClipsToBounds:YES];
    [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.passwordTextField setClipsToBounds:YES];
}

- (void)logInUser {
    BOOL preparedForLogInAttempt = [self preparedForLogInAttempt];
    if (preparedForLogInAttempt) {
         [[ZSSCloudQuerier sharedQuerier] logInUserWithUsername:self.usernameTextField.text
                                                    andPassword:self.passwordTextField.text
                                InBackgroundWithCompletionBlock:^(PFUser *user, NSError *error) {
                                    if (!error) {
                                        
                                        [self presentHomeViewController];
                                    } else {
                                        [RKDropdownAlert error:error];
                                        [self readyViewforAnotherLogInAttempt];
                                    }
                                }];
    } else {
        [self readyViewforAnotherLogInAttempt];
    }
    
}



- (BOOL)preparedForLogInAttempt {
    [self.logInButton setEnabled:NO];
    [self.signUpButton setEnabled:NO];
    [self.forgotPasswordButton setEnabled:NO];
    [self.dismissButton setEnabled:NO];
    [self dismissKeyboard];
    BOOL textFieldsAreFilledOut = [self textFieldsAreFilledOut];
    if (textFieldsAreFilledOut) {
        return YES;
    } else {
        [self showEmptyFieldsError];
        return NO;
    }
    
}

- (void)readyViewforAnotherLogInAttempt {
    [self.logInButton setEnabled:YES];
    [self.signUpButton setEnabled:YES];
    [self.forgotPasswordButton setEnabled:YES];
    [self.dismissButton setEnabled:YES];
}

- (void)presentHomeViewController {
    ZSSHomeViewController *hvc = [[ZSSHomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hvc];
    [self presentViewController:nav animated:YES completion:nil];
}

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
    [textField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

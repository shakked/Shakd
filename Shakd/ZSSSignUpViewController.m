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
#import "ZSSCloudQuerier.h"
#import "RKDropdownAlert.h"
#import "NSString+Extras.h"
#import "ZSSLoginViewController.h"
#import "ZSSHomeViewController.h"

@interface ZSSSignUpViewController () <UITextFieldDelegate>
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
    [self setDelegates];
    
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)signUpButtonPressed:(id)sender {
    [self signUp];
}

- (void)configureViews {
    [self configureTextFields];
}


- (void)setDelegates {
    self.emailTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)signUp {
    BOOL preparedForSignUpAttempt = [self preparedForSignUpAttempt];
    if (preparedForSignUpAttempt) {
        PFUser *user = [self createUserFromTextFields];
        [[ZSSCloudQuerier sharedQuerier] signUpUser:user withCompletionBlock:^(BOOL succeeded, NSError *error) {
            if (!error && succeeded) {
                [self showHomeView];
            } else {
                [self showSignUpError:error];
                [self readyViewForSignUpAttempt];
            }
        }];
    } else {
        [self readyViewForSignUpAttempt];
    }
}

- (PFUser *)createUserFromTextFields {
    PFUser *user = [PFUser user];
    user.email = self.emailTextField.text;
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    return user;
}

- (BOOL)preparedForSignUpAttempt {
    [self.signUpButton setEnabled:NO];
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

- (void)readyViewForSignUpAttempt {
    [self.signUpButton setEnabled:YES];
    [self.dismissButton setEnabled:YES];
}

- (void)configureTextFields {
    [self.emailTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.emailTextField setClipsToBounds:YES];
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.usernameTextField setClipsToBounds:YES];
    [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.passwordTextField setClipsToBounds:YES];
}

- (BOOL)textFieldsAreFilledOut {
    if ([self.emailTextField hasText] && [self.usernameTextField hasText] && [self.passwordTextField hasText]) {
        return YES;
    }else {
        return  NO;
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)showLogin {
    ZSSLoginViewController *lvc = [[ZSSLoginViewController alloc] init];
    [self presentViewController:lvc animated:YES completion:nil];
}

- (void)showHomeView {
    ZSSHomeViewController *hvc = [[ZSSHomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hvc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showEmptyFieldsError {
    if (!self.emailTextField.hasText) {
        [self.emailTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    if (!self.usernameTextField.hasText) {
        [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    if (!self.passwordTextField.hasText) {
        [self.passwordTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    
    [RKDropdownAlert title:@"Ensure you fill out all fields" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
}

- (void)showSignUpError:(NSError *)error {
    NSString *errorMessage = [error userInfo][@"error"];
    [RKDropdownAlert title:[errorMessage capitalString] backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
    
    [self.emailTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
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

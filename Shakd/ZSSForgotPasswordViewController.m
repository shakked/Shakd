//
//  ZSSForgotPasswordViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSForgotPasswordViewController.h"
#import "UIColor+ShakdColors.h"
#import "UIView+Borders.h"
#import "RKDropdownAlert.h"
#import "ZSSCloudQuerier.h"
#import "NSString+Extras.h"

@interface ZSSForgotPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
@end

@implementation ZSSForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    [self setDelegates];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)resetPasswordButtonPressed:(id)sender {
    [self resetPassword];
}

- (void)resetPassword {
    BOOL preparedForPasswordResetAttempt = [self preparedForPasswordResetAttempt];
    if (preparedForPasswordResetAttempt) {
        
        [[ZSSCloudQuerier sharedQuerier] resetPasswordForEmail:self.emailTextField.text
                               inBackgroundWithCompletionBlock:^(BOOL succeeded, NSError *error) {
                                   if (succeeded && !error) {
                                       [self showPasswordResetSuccess];
                                   } else {
                                       [self showPasswordResetError:error];
                                       [self readyViewsForAnotherPasswordResetAttempt];
                                   }
                               }];
        
    } else {
        [self readyViewsForAnotherPasswordResetAttempt];
    }
}

- (void)configureViews {
    [self configureTextFields];
}

- (void)configureTextFields {
    [self.emailTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
}

- (void)setDelegates {
    self.emailTextField.delegate = self;
}

- (BOOL)preparedForPasswordResetAttempt {
    [self.dismissButton setEnabled:NO];
    [self.resetPasswordButton setEnabled:NO];
    BOOL textFieldsAreFilledOut = [self textFieldsAreFilledOut];
    if (textFieldsAreFilledOut) {
        return YES;
    } else {
        [self showEmptyFieldsError];
        return NO;
    }
}

- (void)readyViewsForAnotherPasswordResetAttempt {
    [self.dismissButton setEnabled:YES];
    [self.resetPasswordButton setEnabled:YES];
}

- (BOOL)textFieldsAreFilledOut {
    if ([self.emailTextField hasText]) {
        return YES;
    }else {
        return  NO;
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)showEmptyFieldsError {
    if (!self.emailTextField.hasText) {
        [self.emailTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    
    [RKDropdownAlert title:@"Ensure you fill out all fields" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
}

- (void)showPasswordResetError:(NSError *)error {
    NSString *errorMessage = [error userInfo][@"error"];
    [RKDropdownAlert title:[errorMessage capitalString] backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
    
    [self.emailTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    
}

- (void)showPasswordResetSuccess {
    [self.emailTextField addLeftBorder:5.0 withColor:[UIColor turquoiseColor]];
    [RKDropdownAlert title:@"Success! Check your email!" backgroundColor:[UIColor turquoiseColor] textColor:[UIColor whiteColor]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

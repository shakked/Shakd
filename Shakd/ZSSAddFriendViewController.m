//
//  ZSSAddFriendViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/8/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSAddFriendViewController.h"
#import "UIView+Borders.h"
#import "UIColor+ShakdColors.h"
#import "RKDropdownAlert+CommonAlerts.h"
#import "ZSSCloudQuerier.h"


@interface ZSSAddFriendViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UIButton *sendFriendRequestButton;
@property (nonatomic, strong) IBOutlet UIButton *dismissButton;
@end

@implementation ZSSAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegates];
    [self configureViews];
}

- (IBAction)dismissButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendFriendRequestButton:(id)sender {
    [self sendFriendRequest];
}

- (void)setDelegates {
    [self.usernameTextField setDelegate:self];
}

- (void)configureViews {
    [self configureTextFields];
}

- (void)configureTextFields {
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
    [self.usernameTextField setClipsToBounds:YES];
}

- (void)sendFriendRequest {
    BOOL preparedForSendFriendRequestAttempt = [self preparedForSendFriendRequestAttempt];
    if (preparedForSendFriendRequestAttempt) {
        [[ZSSCloudQuerier sharedQuerier] sendFriendRequestToUsername:self.usernameTextField.text inBackgroundWithCompletionBlock:^(BOOL succeeded, NSError *error) {
            if (!error && succeeded) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [RKDropdownAlert title:@"Friend Request Sent!" backgroundColor:[UIColor turquoiseColor] textColor:[UIColor whiteColor]];
                }];
            } else if (!error && !succeeded) {
                [self readyViewForAnotherSendFriendRequestAttempt];
                [self showUserNotFoundError];
            } else {
                [self readyViewForAnotherSendFriendRequestAttempt];
                [self showOtherError:error];
            }
        }];
    } else {
        [self readyViewForAnotherSendFriendRequestAttempt];
    }
}

- (BOOL)preparedForSendFriendRequestAttempt {
    [self.dismissButton setEnabled:NO];
    [self.sendFriendRequestButton setEnabled:NO];
    BOOL textFieldsAreFilledOut = [self textFieldsAreFilledOut];
    if (textFieldsAreFilledOut) {
        return YES;
    } else {
        [self showEmptyFieldsError];
        return NO;
    }
}

- (void)readyViewForAnotherSendFriendRequestAttempt {
    [self.sendFriendRequestButton setEnabled:YES];
    [self.dismissButton setEnabled:YES];
}

- (BOOL)textFieldsAreFilledOut {
    if ([self.usernameTextField hasText]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField addLeftBorder:5.0 withColor:[UIColor lighterGrayColor]];
}

- (void)showEmptyFieldsError {
    if (!self.usernameTextField.hasText) {
        [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
    }
    
    [RKDropdownAlert title:@"Ensure you fill out all fields" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
}

- (void)showUserNotFoundError {
    [RKDropdownAlert title:@"User not found" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
}

- (void)showOtherError:(NSError *)error {
    [RKDropdownAlert error:error];
    [self.usernameTextField addLeftBorder:5.0 withColor:[UIColor salmonColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

//
//  ZSSFriendRequestsTableViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/8/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSFriendRequestsTableViewController.h"
#import "ZSSLocalStore.h"
#import "ZSSLocalSyncer.h"
#import "ZSSLocalQuerier.h"
#import "NSString+Extras.h"
#import "UIColor+ShakdColors.h"
#import "RKDropdownAlert.h"
#import "ZSSCloudQuerier.h"
#import <Parse/Parse.h>
#import "UIBarButtonItem+MyBarButtons.h"
#import "ZSSFriendRequest.h"
#import "ZSSFriendRequestCell.h"
#import "RKDropdownAlert+CommonAlerts.h"
#import "ZSSAddFriendViewController.h"

static NSString *FRIEND_REQUEST_CELL_CLASS = @"ZSSFriendRequestCell";
static NSString *CELL_IDENTIFIER = @"cell";

@interface ZSSFriendRequestsTableViewController ()

@property (nonatomic, strong) NSArray *friendRequests;
@property (nonatomic, strong) ZSSUser *currentLocalUser;


@end

@implementation ZSSFriendRequestsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    self.currentLocalUser = [[ZSSLocalStore sharedStore] fetchUserWithObjectId:[PFUser currentUser].objectId];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[ZSSLocalSyncer sharedSyncer] syncFriendRequestsWithCompletionBlock:^(NSArray *friendRequests, NSError *error) {
//        if (!error) {
//            [self loadFriendRequestData];
//            [self.tableView reloadData];
//        } else {
//            [RKDropdownAlert error:error];
//        }
//    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFriendRequestData];
}

- (void)configureViews {
    [self configureNavBar];
    [self.tableView registerNib:[UINib nibWithNibName:FRIEND_REQUEST_CELL_CLASS bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
}

- (void)configureNavBar {
    self.navigationItem.title = @"Friend Requests";
    [self configureNavBarButtons];
}

- (void)configureNavBarButtons {
    UIBarButtonItem *backButton = [UIBarButtonItem backBarButtonForVC:self];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *addFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addFriendButton.bounds = CGRectMake(0, 0, 30, 30);
    [addFriendButton setBackgroundImage:[UIImage imageNamed:@"AddFriendIcon"] forState:UIControlStateNormal];
    [addFriendButton addTarget:self action:@selector(showAddFriendView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addFriendBarButton = [[UIBarButtonItem alloc] initWithCustomView:addFriendButton];
    self.navigationItem.rightBarButtonItem = addFriendBarButton;
}

- (void)loadFriendRequestData {
    self.friendRequests = [[ZSSLocalQuerier sharedQuerier] friendRequests];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendRequests count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZSSFriendRequest *friendRequest = self.friendRequests[indexPath.row];
    ZSSFriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];

    BOOL isSentFriendRequest = [self isSentFriendRequest:friendRequest];
    BOOL isReceivedFriendRequest = [self isReceivedFriendRequest:friendRequest];
    
    if (isSentFriendRequest) {
        cell = [self configureCell:cell forSentFriendRequest:friendRequest];
    } else if (isReceivedFriendRequest) {
        cell = [self configureCell:cell forReceivedFriendRequest:friendRequest];
    } else {
        [self throwInvalidFriendRequestException];
    }
    
    cell = [self configureCell:cell forStatusOfFriendRequest:friendRequest];
    [[cell.friendRequestButton layer] setCornerRadius:5.0];
    
    return cell;
}

- (ZSSFriendRequestCell *)configureCell:(ZSSFriendRequestCell *)cell forSentFriendRequest:(ZSSFriendRequest *)friendRequest {
    [cell.friendLabel setText:friendRequest.receiver.username];
    [cell.friendRequestButton setImage:[UIImage imageNamed:@"FriendRequestPending"] forState:UIControlStateNormal];
    return cell;
}

- (ZSSFriendRequestCell *)configureCell:(ZSSFriendRequestCell *)cell forReceivedFriendRequest:(ZSSFriendRequest *)friendRequest {
    [cell.friendLabel setText:friendRequest.sender.username];
    [cell.friendRequestButton setImage:[UIImage imageNamed:@"FriendRequestApprove"] forState:UIControlStateNormal];
    return cell;
}

- (ZSSFriendRequestCell *)configureCell:(ZSSFriendRequestCell *)cell forStatusOfFriendRequest:(ZSSFriendRequest *)friendRequest {
    if ([self isConfirmedFriendRequest:friendRequest]) {
        [cell.friendRequestButton setImage:[UIImage imageNamed:@"FriendRequestConfirmed"] forState:UIControlStateNormal];
    } else {
    }
    return cell;
}


- (BOOL)isSentFriendRequest:(ZSSFriendRequest *)friendRequest {
    if ([friendRequest.sender isEqual:self.currentLocalUser]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isReceivedFriendRequest:(ZSSFriendRequest *)friendRequest {
    if ([friendRequest.receiver isEqual:self.currentLocalUser]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isConfirmedFriendRequest:(ZSSFriendRequest *)friendRequest {
    if ([friendRequest.confirmed isEqual:@YES]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)throwInvalidFriendRequestException {
    @throw [NSException exceptionWithName:@"InvalidFriendRequest"
                                   reason:@"User is not receiver or sender"
                                 userInfo:nil];
}

- (void)showPreviousView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAddFriendView {
    ZSSAddFriendViewController *afvc = [[ZSSAddFriendViewController alloc] init];
    [self presentViewController:afvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

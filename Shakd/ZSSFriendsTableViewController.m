//
//  ZSSFriendsTableViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSFriendsTableViewController.h"
#import "ZSSLocalSyncer.h"
#import "ZSSLocalStore.h"
#import "ZSSLocalQuerier.h"
#import "ZSSFriendCell.h"
#import "NSString+Extras.h"
#import "UIColor+ShakdColors.h"
#import "RKDropdownAlert.h"
#import "ZSSCloudQuerier.h"
#import <Parse/Parse.h>
#import "UIBarButtonItem+MyBarButtons.h"
#import "ZSSFriendRequestsTableViewController.h"

static NSString *FRIEND_CELL_CLASS = @"ZSSFriendCell";
static NSString *CELL_IDENTIFIER = @"cell";

@interface ZSSFriendsTableViewController ()

@property (nonatomic,strong) NSArray *friends;

@end

@implementation ZSSFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[ZSSLocalSyncer sharedSyncer] syncFriendRequestsWithCompletionBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self loadFriendData];
            [self.tableView reloadData];
        } else {
            [self showSyncError:error];
        }
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadFriendData];
}

- (void)configureViews {
    [self configureNavBar];
    [self.tableView registerNib:[UINib nibWithNibName:FRIEND_CELL_CLASS bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
}

- (void)configureNavBar {
    self.navigationItem.title = @"Friends";
    [self configureNavBarButtons];
}

- (void)configureNavBarButtons {
    UIBarButtonItem *backButton = [UIBarButtonItem backBarButtonForVC:self];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *friendRequestsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    friendRequestsButton.bounds = CGRectMake(0, 0, 30, 30);
    [friendRequestsButton setBackgroundImage:[UIImage imageNamed:@"FriendRequestsIcon"] forState:UIControlStateNormal];
    [friendRequestsButton addTarget:self action:@selector(showFriendRequestsView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *friendRequestsBarButton = [[UIBarButtonItem alloc] initWithCustomView:friendRequestsButton];
    self.navigationItem.rightBarButtonItem = friendRequestsBarButton;
    
    
}

- (void)loadFriendData {
    self.friends = [[ZSSLocalQuerier sharedQuerier] friends];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZSSUser *friend = self.friends[indexPath.row];
    ZSSFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell = [self configureCell:cell ForFriend:friend];
    return cell;
}

- (ZSSFriendCell *)configureCell:(ZSSFriendCell *)cell ForFriend:(ZSSUser *)friend {
    
    [cell.friendLabel setText:friend.username];
    if (self.state == ZSSFriendsTableStateViewing) {
        cell = [self configureCellForViewingState:cell];
    } else {
        cell = [self configureCellForSendingMessageState:cell];
    }
    return cell;
}

- (ZSSFriendCell *)configureCellForViewingState:(ZSSFriendCell *)cell {
    [cell.selectFriendButton setHidden:YES];
    return cell;
}

- (ZSSFriendCell *)configureCellForSendingMessageState:(ZSSFriendCell *)cell {
    [cell.selectFriendButton setHidden:NO];
    return cell;
}

- (void)showPreviousView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showFriendRequestsView {
    ZSSFriendRequestsTableViewController *frtvc = [[ZSSFriendRequestsTableViewController alloc] init];
    [self.navigationController pushViewController:frtvc animated:YES];
}

- (void)showSyncError:(NSError *)error {
    NSString *errorMessage = [error userInfo][@"error"];
    [RKDropdownAlert title:[errorMessage capitalString] backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

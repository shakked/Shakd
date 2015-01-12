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
    
    [[ZSSLocalSyncer sharedSyncer] syncFriendRequestsWithCompletionBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            [self loadFriendRequestData];
            [self.tableView reloadData];
        } else {
            [RKDropdownAlert error:error];
        }
    }];
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
    cell.friendRequest = friendRequest;
    [cell.selectFriendRequestButton setHidden:NO];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
     
    [self assignCellCorrectState:cell];
    [self configureBlocks:cell];
    [self configureCell:cell];
    
    return cell;
}

- (void)assignCellCorrectState:(ZSSFriendRequestCell *)cell {
    ZSSFriendRequest *friendRequest = cell.friendRequest;
    if ([friendRequest.sender isEqual:self.currentLocalUser]) {
        if ([friendRequest.confirmed isEqual:@YES]) {
            cell.state = ZSSFriendRequestCellSentConfirmedState;
        } else {
            cell.state = ZSSFriendRequestCellSentDeniedState;
        }
    } else if ([friendRequest.receiver isEqual:self.currentLocalUser]){
        if ([friendRequest.confirmed isEqual:@YES]) {
            cell.state = ZSSFriendRequestCellReceivedConfirmedState;
        } else {
            cell.state = ZSSFriendRequestCellReceivedDeniedState;
        }
    }
}

- (void)configureBlocks:(ZSSFriendRequestCell *)cell {
    if (cell.state == ZSSFriendRequestCellSentDeniedState || cell.state == ZSSFriendRequestCellSentConfirmedState || cell.state == ZSSFriendRequestCellReceivedConfirmedState) {
        __weak ZSSFriendRequestCell *weakCell = cell;
        cell.selectFriendRequestButtonBlock = ^{
            ZSSFriendRequestCell *strongCell = weakCell;
            [self showAlertController:strongCell];
        };
    } else if (cell.state == ZSSFriendRequestCellReceivedDeniedState) {
        __weak ZSSFriendRequestCell *weakCell = cell;
        cell.selectFriendRequestButtonBlock = ^{
            ZSSFriendRequestCell *strongCell = weakCell;
            [self confirmFriendRequestForCell:strongCell];
        };
    }
}

- (void)showAlertController:(ZSSFriendRequestCell *)cell {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Friend Request?" message:@"Do you want to delete this friend request?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete Friend Request"
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction *action) {
                                                       [self deleteFriendRequestForCell:cell];
                                                   }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action) {
                                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [alertController addAction:delete];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)confirmFriendRequestForCell:(ZSSFriendRequestCell *)cell {
    [RKDropdownAlert title:@"WOULD CONFIRM FQ" backgroundColor:[UIColor turquoiseColor] textColor:[UIColor whiteColor]];
}

- (void)deleteFriendRequestForCell:(ZSSFriendRequestCell *)cell {
    [RKDropdownAlert title:@"WOULD DELETE FQ"];
}

- (void)configureCell:(ZSSFriendRequestCell *)cell {
    if (cell.state == ZSSFriendRequestCellSentConfirmedState) {
        [cell.selectFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"FriendRequestConfirmed"] forState:UIControlStateNormal];
        [cell.friendLabel setText:cell.friendRequest.receiver.username];
        
    } else if (cell.state == ZSSFriendRequestCellReceivedConfirmedState) {
        [cell.selectFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"FriendRequestConfirmed"] forState:UIControlStateNormal];
        [cell.friendLabel setText:cell.friendRequest.sender.username];
        
    } else if (cell.state == ZSSFriendRequestCellReceivedDeniedState) {
        [cell.selectFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"FriendRequestApprove"] forState:UIControlStateNormal];
        [cell.friendLabel setText:cell.friendRequest.sender.username];
        
    } else if (cell.state == ZSSFriendRequestCellSentDeniedState) {
        [cell.selectFriendRequestButton setBackgroundImage:[UIImage imageNamed:@"FriendRequestPending"] forState:UIControlStateNormal];
        [cell.friendLabel setText:cell.friendRequest.receiver.username];
        
    } else {
        [RKDropdownAlert title:@"State not set for cell"];
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

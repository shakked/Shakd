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
#import "UIView+Borders.h"
#import "RKDropdownAlert+CommonAlerts.h"

static NSString *FRIEND_CELL_CLASS = @"ZSSFriendCell";
static NSString *CELL_IDENTIFIER = @"cell";

@interface ZSSFriendsTableViewController ()

@property (nonatomic,strong) NSArray *friends;
@property (nonatomic, strong) NSMutableArray *sendList;
@property (nonatomic, strong) NSDictionary *messageInfo;

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
    [self showToolbarIfNecessary];
}

- (void)configureViews {
    [self configureNavBar];
    [self.tableView registerNib:[UINib nibWithNibName:FRIEND_CELL_CLASS bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
}

- (void)configureNavBar {
    self.navigationItem.title = @"Friends";
    [self configureNavBarButtons];
    [self configureToolbar];
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
    [cell setFriend:friend];
    [self configureCell:cell ForFriend:friend];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.state == ZSSFriendsTableStateSendingMessage) {
        ZSSFriendCell *cell = (ZSSFriendCell *)[tableView cellForRowAtIndexPath:indexPath];
        ZSSUser *friend = cell.friend;
        if ([self.sendList containsObject:friend]) {
            [self.sendList removeObject:friend];
            [self configureUnselectedCell:cell];
        } else {
            [self.sendList addObject:friend];
            [self configureSelectedCell:cell];
        }
        [self showToolbarIfNecessary];
    }
}


- (void)configureCell:(ZSSFriendCell *)cell ForFriend:(ZSSUser *)friend {
    
    [cell.friendLabel setText:friend.username];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (self.state == ZSSFriendsTableStateViewing) {
        [self configureCellForViewingState:cell];
    } else {
        [self configureCellForSendingMessageState:cell];
    }
}

- (void)configureCellForViewingState:(ZSSFriendCell *)cell {
    [cell.selectFriendButton setHidden:YES];
}

- (void)configureCellForSendingMessageState:(ZSSFriendCell *)cell {
    [cell.selectFriendButton setHidden:NO];
    [[cell.selectFriendButton layer] setCornerRadius:5.0];
    if ([self.sendList containsObject:cell.friend]) {
        [self configureSelectedCell:cell];
    } else {
        [self configureUnselectedCell:cell];
    }
    
    [self configureCellBlocksForSendingMessageState:cell];
}

- (void)configureSelectedCell:(ZSSFriendCell *)cell {
    [cell.selectFriendButton setBackgroundColor:[UIColor charcoalColor]];
    [cell.friendLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:22.0]];
}

- (void)configureUnselectedCell:(ZSSFriendCell *)cell {
    [cell.selectFriendButton setBackgroundColor:[UIColor whiteColor]];
    [[cell.selectFriendButton layer] setBorderColor:[UIColor charcoalColor].CGColor];
    [[cell.selectFriendButton layer] setBorderWidth:2.0];
    [cell.friendLabel setFont:[UIFont fontWithName:@"Avenir" size:22.0]];
}

- (void)configureCellBlocksForSendingMessageState:(ZSSFriendCell *)cell {
    __weak ZSSFriendCell *weakCell = cell;
    cell.selectFriendButtonPressedBlock = ^{
        ZSSFriendCell *strongCell = weakCell;
        ZSSUser *friend = strongCell.friend;
        if ([self.sendList containsObject:friend]) {
            [self.sendList removeObject:friend];
            [self configureUnselectedCell:strongCell];
        } else {
            [self.sendList addObject:friend];
            [self configureSelectedCell:strongCell];
        }
        
        [self showToolbarIfNecessary];
    };
}

- (void)showToolbarIfNecessary {
    if ([self.sendList count] > 0) {
        [self.navigationController setToolbarHidden:NO animated:YES];
    } else {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)configureToolbar {
    UIBarButtonItem *flexibleSpaceBarButton = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                               target:nil
                                               action:nil];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton.titleLabel setFont:[UIFont fontWithName:@"Avenir-Heavy" size:16.0]];
    sendButton.bounds = CGRectMake(0, 0, 40, 30);
    [sendButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessages) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendBarButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    [self setToolbarItems:@[flexibleSpaceBarButton, sendBarButton] animated:NO];
    self.navigationController.toolbar.barTintColor = [UIColor charcoalColor];
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbar.tintColor = [UIColor whiteColor];
}

- (void)sendMessages {
    [[ZSSCloudQuerier sharedQuerier] sendMessageToUsers:self.sendList withMessageInfo:self.messageInfo withCompletionBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            [RKDropdownAlert title:@"Messages sent!" backgroundColor:[UIColor turquoiseColor] textColor:[UIColor whiteColor]];
        } else if (!succeeded && error) {
            [RKDropdownAlert error:error];
        } else {
            [RKDropdownAlert title:@"Somethign went wrong" backgroundColor:[UIColor charcoalColor] textColor:[UIColor whiteColor]];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
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

- (instancetype)init {
    self = [super init];
    if (self) {
        _sendList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithState:(ZSSFriendsTableState)state andMessageInfo:(NSDictionary *)messageInfo {
    self = [super init];
    if (self) {
        _state = state;
        _sendList = [[NSMutableArray alloc] init];
        _messageInfo = [[NSDictionary alloc] initWithDictionary:messageInfo];
    }
    return self;
}

@end

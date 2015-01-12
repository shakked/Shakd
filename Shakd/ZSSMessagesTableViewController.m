//
//  ZSSMessagesTableViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/9/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSMessagesTableViewController.h"
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
#import "ZSSMessageCell.h"
#import <AVFoundation/AVFoundation.h>
#import "NSDate+DateTools.h"
#import "UIView+Borders.h"

static NSString *MESSAGE_CELL_CLASS = @"ZSSMessageCell";
static NSString *CELL_IDENTIFIER = @"cell";

@interface ZSSMessagesTableViewController () <AVSpeechSynthesizerDelegate>

@property (nonatomic) ZSSMessagesTableState state;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) ZSSUser *currentLocalUser;
@property (nonatomic, strong) NSArray *messages;

@property (nonatomic, strong) AVSpeechSynthesizer *speaker;
@property (nonatomic, strong) ZSSMessageCell *currentlyPlayingCell;

@end

@implementation ZSSMessagesTableViewController

- (instancetype)initWithState:(ZSSMessagesTableState)state {
    self = [super init];
    if (self) {
        _state = state;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    self.currentLocalUser = [[ZSSLocalStore sharedStore] fetchUserWithObjectId:[PFUser currentUser].objectId];
    self.speaker = [[AVSpeechSynthesizer alloc] init];
    self.speaker.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[ZSSLocalSyncer sharedSyncer] syncMessagesWithCompletionBlock:^(NSArray *messages, NSError *error) {
        if (!error) {
            [self loadMessageData];
            [self.tableView reloadData];
        } else {
            [RKDropdownAlert error:error];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadMessageData];
}

- (void)configureViews {
    [self configureNavBar];
    [self.tableView registerNib:[UINib nibWithNibName:MESSAGE_CELL_CLASS bundle:nil] forCellReuseIdentifier:CELL_IDENTIFIER];
}

- (void)configureNavBar {
    self.navigationItem.title = @"Shakbox";
    [self configureNavBarButtons];
}

- (void)configureNavBarButtons {
    UIBarButtonItem *backButton = [UIBarButtonItem backBarButtonForVC:self];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (void)loadMessageData {
    if (self.state == ZSSMessagesTableStateReceivedMessages) {
        self.messages = [[ZSSLocalQuerier sharedQuerier] receivedMessages];
    } else if (self.state == ZSSMessagesTableStateSentMessages) {
        self.messages = [[ZSSLocalQuerier sharedQuerier] sentMessages];
    } else {
        [self throwInvalidMessageState];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    view.backgroundColor = [UIColor clearColor];
    
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Received", @"Sent"]];
    self.segmentedControl.frame = CGRectMake(10, 5, self.tableView.frame.size.width-20,35);
    [self.segmentedControl setBackgroundColor:[UIColor whiteColor]];
    [self.segmentedControl addTarget:self action:@selector(stateDidChange) forControlEvents:UIControlEventValueChanged];
    [view addSubview:self.segmentedControl];
    self.segmentedControl.tintColor = [UIColor charcoalColor];
    [self.segmentedControl setSelectedSegmentIndex:self.state];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 205;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZSSMessage *message = self.messages[indexPath.row];
    ZSSMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    cell.message = message;
    [cell setGestureRecognizers:nil];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.state == ZSSMessagesTableStateReceivedMessages) {
        [self configureReceivedMessageCell:cell];
    } else if (self.state == ZSSMessagesTableStateSentMessages) {
        [self configureSentMessageCell:cell];
    }
    [self configureBlocks:cell];

    [[cell layer] setBorderWidth:1.0];
    [[cell layer] setBorderColor:[UIColor lighterGrayColor].CGColor];

    return cell;
}

- (void)configureReceivedMessageCell:(ZSSMessageCell *)cell {
    [cell.fromAndToLabel setText:@"from"];
    [cell.usernameLabel setText:cell.message.sender.username];
    [cell.timeLabel setText:[NSDate shortTimeAgoSinceDate:cell.message.dateSent]];
    
    if (![cell.message hasBeenViewed]) {
        [self configureUnviewedMessageCell:cell];
    } else {
        [self configureViewedMessageCell:cell];
    }
    
}
- (void)configureUnviewedMessageCell:(ZSSMessageCell *)cell {
    [cell.messageTextView setHidden:YES];
    [cell.messageTextView setTextColor:[UIColor lighterGrayColor]];
    [cell.pressAndHoldLabel setHidden:NO];
    
    [cell.forwardButton setHidden:YES];
    [cell.forwardImageView setHidden:YES];
    [cell.forwardLabel setHidden:YES];
    [cell.playButton setHidden:YES];
    [cell.playImageView setHidden:YES];
    [cell.playLabel setHidden:YES];
    [cell.replyButton setHidden:YES];
    [cell.replyImageView setHidden:YES];
    [cell.replyLabel setHidden:YES];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(playUnviewedMessage:)];
    [cell addGestureRecognizer:longPress];
}

- (void)configureViewedMessageCell:(ZSSMessageCell *)cell {
    [cell.messageTextView setText:cell.message.messageInfo[@"messageText"]];
    [cell.messageTextView setTextColor:[UIColor charcoalColor]];
    [cell.pressAndHoldLabel setHidden:YES];
    [cell.forwardButton setHidden:NO];
    [cell.playButton setHidden:NO];
    [cell.replyButton setHidden:NO];
    [cell.forwardButton setHidden:NO];
    [cell.forwardImageView setHidden:NO];
    [cell.forwardLabel setHidden:NO];
    [cell.playButton setHidden:NO];
    [cell.playImageView setHidden:NO];
    [cell.playLabel setHidden:NO];
    [cell.replyButton setHidden:NO];
    [cell.replyImageView setHidden:NO];
    [cell.replyLabel setHidden:NO];
    
}

- (void)playUnviewedMessage:(id)sender {
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    ZSSMessageCell *cell = (ZSSMessageCell *)longPress.view;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (longPress.state == UIGestureRecognizerStateBegan){
        AVSpeechUtterance *utterance = [self speechUtteranceForMessage:cell.message];
        self.currentlyPlayingCell = cell;
        [self speakUtterance:utterance];
        NSLog(@"playing message...");
        
    }else if (longPress.state == UIGestureRecognizerStateEnded){
        [self.speaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        self.currentlyPlayingCell = nil;
    }
}


- (void)configureSentMessageCell:(ZSSMessageCell *)cell {
    [cell.fromAndToLabel setText:@"to"];
    [cell.usernameLabel setText:cell.message.receiver.username];
    [cell.pressAndHoldLabel setHidden:YES];
    [cell.messageTextView setText:cell.message.messageInfo[@"messageText"]];
    [cell.messageTextView setTextColor:[UIColor charcoalColor]];
    [cell.forwardButton setHidden:NO];
    [cell.playButton setHidden:NO];
    [cell.replyButton setHidden:NO];
    
    if (cell.message.dateViewed) {
        [cell.timeLabel setText:[cell.message.dateViewed formattedDateWithStyle:NSDateFormatterShortStyle]];
    } else {
        [cell.timeLabel setText:@"Not read"];
    }
}

- (void)configureBlocks:(ZSSMessageCell *)cell {
    __weak ZSSMessageCell *weakCell = cell;
    
    cell.forwardButtonPressedBlock = ^{
#warning TODO
        [RKDropdownAlert title:@"Will Present FORWARD Screen"];
    };
    
    cell.playButtonPressedBlock = ^{
        ZSSMessageCell *strongCell = weakCell;
        AVSpeechUtterance *utterance = [self speechUtteranceForMessage:strongCell.message];
        [self speakUtterance:utterance];
    };
    
    cell.replyButtonPressedBlock = ^{
        [RKDropdownAlert title:@"Will Present REPLY Screen"];
    };
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    NSLog(@"Started");
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    if (self.currentlyPlayingCell) {
        [[ZSSCloudQuerier sharedQuerier] viewMessage:self.currentlyPlayingCell.message inBackgroundWithCompletionBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded && !error) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:self.currentlyPlayingCell];
                self.currentlyPlayingCell.message.dateViewed = [NSDate date];
#warning NSDate Date may not be right.
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [RKDropdownAlert error:error];
            }
        }];
    }
}

- (void)speakUtterance:(AVSpeechUtterance *)utterance {
    [self.speaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    [self.speaker speakUtterance:utterance];
}

- (AVSpeechUtterance *)speechUtteranceForMessage:(ZSSMessage *)message {
    NSDictionary *messageInfo = message.messageInfo;
    
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:messageInfo[@"messageText"]];
    utterance.pitchMultiplier = [messageInfo[@"pitch"] floatValue];
    utterance.rate = [messageInfo[@"rate"] floatValue];
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:messageInfo[@"voice"]];
    utterance.voice = voice;
    return utterance;
}

- (void)stateDidChange {
    self.state = self.segmentedControl.selectedSegmentIndex;
    [self loadMessageData];
    [self.tableView reloadData];
}

- (void)throwInvalidMessageState {
    @throw [NSException exceptionWithName:@"InvalidMessageState"
                                   reason:@"Message state is not valid"
                                 userInfo:nil];
}



- (void)showPreviousView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
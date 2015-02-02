//
//  ZSSHomeViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/6/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSHomeViewController.h"
#import "UIColor+ShakdColors.h"
#import "UIView+Borders.h"
#import "ActionSheetStringPicker.h"
#import <AVFoundation/AVFoundation.h>
#import "ZSSFriendsTableViewController.h"
#import "ZSSCloudQuerier.h"
#import "ZSSMessagesTableViewController.h"
#import "RKNotificationHub.h"
#import "ZSSSettingsViewController.h"
#import "ZSSLocalSyncer.h"
#import "RKDropdownAlert.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "ZSSLocalQuerier.h"
#import "ZSSFriendRequestsTableViewController.h"

@interface ZSSHomeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;

@property (nonatomic, strong) AVSpeechSynthesizer *speaker;
@property (nonatomic, strong) NSString *voice;

@property (nonatomic, strong) NSArray *voiceShortCodes;
@property (nonatomic, strong) NSArray *voicesFullNames;
@property (nonatomic) NSInteger indexOfSelectedVoice;

@property (nonatomic, strong) RKNotificationHub *messageHub;
@property (nonatomic, strong) RKNotificationHub *friendRequestHub;

@end

@implementation ZSSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    [self configureSpeechSynthesizer];
    [self configureAccents];
    
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *keyDict = [NSDictionary dictionaryWithContentsOfFile:keyPath];
    
    self.bannerView.adUnitID = keyDict[@"HomeAdUnit"];
    self.bannerView.rootViewController = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [self.bannerView loadRequest:request];
    
    [[ZSSCloudQuerier sharedQuerier] saveUserForCurrentInstallation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.messageTextView becomeFirstResponder];

    [[ZSSLocalSyncer sharedSyncer] syncMessagesWithCompletionBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [[ZSSCloudQuerier sharedQuerier] adjustBadge];
            [self.messageHub setCount:(int)[[PFInstallation currentInstallation] badge]];
        } else {
            [RKDropdownAlert title:@"No Internet Connection" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
        }
    }];
    
    [[ZSSLocalSyncer sharedSyncer] syncFriendRequestsWithCompletionBlock:^(NSArray *friendRequests, NSError *error) {
        if (!error) {
            [self.friendRequestHub setCount:[[ZSSLocalQuerier sharedQuerier] friendRequestHubCount]];
        } else {
            [RKDropdownAlert title:@"No Internet Connection" backgroundColor:[UIColor salmonColor] textColor:[UIColor whiteColor]];
        }
    }];
}

- (void)configureViews {
    [self configureNavBar];
    [self configureButtons];
}

- (void)configureNavBar {
    self.navigationItem.title = @"Shakd";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setTranslucent:NO];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSFontAttributeName : [UIFont fontWithName:@"Avenir" size:26.0]}];
    [navBar setBarTintColor:[UIColor charcoalColor]];
    [self configureNavBarButtons];

}

- (void)configureNavBarButtons {
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    friendsButton.bounds = CGRectMake(0, 0, 30, 30);
    self.friendRequestHub = [[RKNotificationHub alloc] initWithView:friendsButton];
    [self.friendRequestHub scaleCircleSizeBy:0.6];
    [self.friendRequestHub setCount:[[ZSSLocalQuerier sharedQuerier] friendRequestHubCount]];
    [friendsButton setBackgroundImage:[UIImage imageNamed:@"FriendsIcon"] forState:UIControlStateNormal];
    [friendsButton addTarget:self action:@selector(showFriendRequestsView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *friendsBarButton = [[UIBarButtonItem alloc] initWithCustomView:friendsButton];
    

    UIButton *messagesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messagesButton.bounds = CGRectMake(0, 0, 30, 30);
    self.messageHub = [[RKNotificationHub alloc] initWithView:messagesButton];
    [self.messageHub scaleCircleSizeBy:0.6];
    [self.messageHub setCount:(int)[[PFInstallation currentInstallation] badge]];
    [messagesButton setBackgroundImage:[UIImage imageNamed:@"MessagesIcon"] forState:UIControlStateNormal];
    [messagesButton addTarget:self action:@selector(showMessagesView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *messagesBarButton = [[UIBarButtonItem alloc] initWithCustomView:messagesButton];
    
    UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    settingsButton.bounds = CGRectMake(0, 0, 30, 30);
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"SettingsIcon"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(showSettingsView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
    
    self.navigationItem.leftBarButtonItem = settingsBarButton;
    self.navigationItem.rightBarButtonItems = @[friendsBarButton, messagesBarButton];
}

- (void)configureSpeechSynthesizer {
    if (!self.speaker) {
        self.speaker = [[AVSpeechSynthesizer alloc] init];
    }
}

- (void)configureAccents {
    if (!self.voicesFullNames) {
        self.voiceShortCodes = @[@"ar-SA", @"en-ZA", @"nl-BE", @"en-AU", @"th-TH", @"de-DE", @"en-US", @"pt-BR", @"pl-PL", @"en-IE", @"el-GR", @"id-ID", @"sv-SE", @"tr-TR", @"pt-PT", @"ja-JP", @"ko-KR", @"hu-HU", @"cs-CZ", @"da-DK", @"es-MX", @"fr-CA", @"nl-NL", @"fi-FI", @"es-ES", @"it-IT", @"he-IL", @"no-NO", @"ro-RO", @"zh-HK", @"zh-TW", @"sk-SK", @"zh-CN", @"ru-RU", @"en-GB", @"fr-FR", @"hi-IN"];
    }
    if (!self.voicesFullNames) {
        self.voicesFullNames = @[@"Arabic (Saudi Arabia)", @"English (South Africa)", @"Dutch (Belgium)", @"English (Australian)", @"Thai (Thailand)", @"German (Germany)", @"English (United States)", @"Portuguese (Brazil)", @"Poland (Polish)", @"English (Ireland)", @"Modern Greek (Greece)", @"Indonesian (Indonesia)", @"Swedish (Sweden)", @"Turkish (Turkey)", @"Portuguese (Portugal)", @"Japan (Japanese)", @"Korean (South Korea)", @"Hungarian (Hungary)", @"Czech (Czech Republic)", @"Danish (Denmark)", @"Spanish (Mexico)", @"French (Canadian)", @"Dutch (Netherlands)", @"Finnish (Finland)", @"Spanish (Spain)", @"Italian (Italy)", @"Hebrew (Israel)", @"Norweigan (Norway)", @"Romanian (Romania)", @"Chinese (Hong Kong)", @"Chinese (Taiwan)",@"Slovak (Slovakia)", @"Chinese (China)", @"Russian (Russia)", @"English (Great Britain)", @"French (France)", @"Hindi (India)"];
    }
    if (!self.indexOfSelectedVoice) {
        self.indexOfSelectedVoice = [self.voiceShortCodes indexOfObjectIdenticalTo:self.voice];
    }
}

- (void)configureButtons {
    
}

- (IBAction)voicesButtonPressed:(id)sender {
    [self showVoices:sender];
}


- (IBAction)playButtonPressed:(id)sender {
    [self playCurrentShak];
}

- (IBAction)sendButtonPressed:(id)sender {
    NSDictionary *messageInfo = [self getMessageInfo];
    ZSSFriendsTableViewController *ftvc = [[ZSSFriendsTableViewController alloc] initWithState:ZSSFriendsTableStateSendingMessage andMessageInfo:messageInfo];
    [self.navigationController pushViewController:ftvc animated:YES];
}

- (NSDictionary *)getMessageInfo {
    NSNumber *pitch = [NSNumber numberWithFloat:self.pitchSlider.value];
    NSNumber *rate = [NSNumber numberWithFloat:self.rateSlider.value];
    NSString *voice = self.voice;
    NSString *messageText = self.messageTextView.text;
    NSDictionary *messsageInfo = @{@"pitch" : pitch,
                                   @"rate" : rate,
                                   @"voice" : voice,
                                   @"messageText" : messageText};
    return messsageInfo;
}
- (void)playCurrentShak {
    [self.speaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    float pitchMultiplier = self.pitchSlider.value;
    float rate = self.rateSlider.value;
    NSString *messageText = self.messageTextView.text;
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:messageText];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.voice];
    [utterance setVoice:voice];
    [utterance setPitchMultiplier:pitchMultiplier];
    [utterance setRate:rate];
    [self.speaker speakUtterance:utterance];
}

- (void)showVoices:(id)sender {
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Voice"
                                            rows:self.voicesFullNames
                                initialSelection:self.indexOfSelectedVoice
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.voice = self.voiceShortCodes[selectedIndex];
                                           self.indexOfSelectedVoice = selectedIndex;
                                       }
                                     cancelBlock:nil
                                          origin:sender];
}

- (void)showSettingsView {
    ZSSSettingsViewController *svc = [[ZSSSettingsViewController alloc] init];
    [self presentViewController:svc animated:YES completion:nil];
}

- (void)showFriendRequestsView {
    ZSSFriendRequestsTableViewController *frtvc = [[ZSSFriendRequestsTableViewController alloc] init];
    [self.navigationController pushViewController:frtvc animated:YES];
}

- (void)showMessagesView {
    ZSSMessagesTableViewController *mtvc = [[ZSSMessagesTableViewController alloc] init];
    [self.navigationController pushViewController:mtvc animated:YES];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _voice = @"en-GB";
    }
    return self;
}

@end

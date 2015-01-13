//
//  ZSSPrepForSendViewController.m
//  Shakd
//
//  Created by Zachary Shakked on 1/12/15.
//  Copyright (c) 2015 Shakked Inc. All rights reserved.
//

#import "ZSSPrepForSendViewController.h"
#import "ActionSheetStringPicker.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+ShakdColors.h"
#import "ZSSFriendsTableViewController.h"
#import "ZSSMessage.h"

@interface ZSSPrepForSendViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;

@property (nonatomic, strong) AVSpeechSynthesizer *speaker;
@property (nonatomic, strong) NSString *voice;

@property (nonatomic, strong) NSArray *voiceShortCodes;
@property (nonatomic, strong) NSArray *voicesFullNames;
@property (nonatomic) NSInteger indexOfSelectedVoice;

@end

@implementation ZSSPrepForSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    [self configureSpeechSynthesizer];
    [self configureAccents];
    [self configureMessageViews];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.messageTextView becomeFirstResponder];
}

- (IBAction)accentsButtonPressed:(id)sender {
    
    
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

- (void)configureViews {
    [self configureNavBar];
    [self configureButtons];
}

- (void)configureNavBar {
    self.navigationItem.title = @"Shakd";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    [navBar setTranslucent:NO];
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                     NSFontAttributeName : [UIFont fontWithName:@"Avenir" size:26.0]}];
    [navBar setBarTintColor:[UIColor charcoalColor]];
    [self configureNavBarButtons];
    
}

- (void)configureNavBarButtons {

    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(cancelView)];
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setBounds:CGRectMake(0, 0, 30, 30)];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"SendIconWhite"] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sendBarButton = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    self.navigationItem.rightBarButtonItem = sendBarButton;
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

- (void)configureMessageViews {
    ZSSMessage *message = self.message;
    if (message) {
        NSDictionary *messageInfo = message.messageInfo;
        [self.rateSlider setValue:[messageInfo[@"rate"] floatValue] animated:YES];
        [self.pitchSlider setValue:[messageInfo[@"pitch"] floatValue] animated:YES];
        [self.messageTextView setText:messageInfo[@"messageText"]];
        [self setVoice:messageInfo[@"voice"]];
        [self setIndexOfSelectedVoice:[self.voiceShortCodes indexOfObject:messageInfo[@"voice"]]];
    } else {
        [self configureDefaultMessageInfo];
    }
}

- (void)configureButtons {
    
}

- (void)configureDefaultMessageInfo {
    [self setVoice: @"en-GB"];
    [self setIndexOfSelectedVoice:[self.voiceShortCodes indexOfObject:@"en-GB"]];
}

- (IBAction)playButtonPressed:(id)sender {
    [self playCurrentShak];
}

- (IBAction)sendButtonPressed:(id)sender {
    [self sendMessage];
}

- (void)sendMessage {
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

- (void)showFriendsView {
    ZSSFriendsTableViewController *ftvc = [[ZSSFriendsTableViewController alloc] init];
    [self.navigationController pushViewController:ftvc animated:YES];
}

- (void)cancelView {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)throwMessageIsntSetException {
    @throw [NSException exceptionWithName:@"MessageIsntSetException"
                                   reason:@"A message needs to be set for this view controller"
                                 userInfo:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}


@end

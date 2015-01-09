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

@interface ZSSHomeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *shakTextView;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;

@property (nonatomic, strong) AVSpeechSynthesizer *speaker;
@property (nonatomic, strong) NSString *accent;

@property (nonatomic, strong) NSArray *accentsShortCodes;
@property (nonatomic, strong) NSArray *accentsFullNames;
@property (nonatomic) NSInteger indexOfSelectedAccent;

@end

@implementation ZSSHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViews];
    [self configureSpeechSynthesizer];
    [self configureAccents];
}

- (void)configureViews {
    [self configureNavBar];
    [self configureButtons];
}

- (void)configureSpeechSynthesizer {
    if (!self.speaker) {
        self.speaker = [[AVSpeechSynthesizer alloc] init];
    }
}

- (IBAction)accentsButtonPressed:(id)sender {

    
    [ActionSheetStringPicker showPickerWithTitle:@"Select an Accent"
                                            rows:self.accentsFullNames
                                initialSelection:self.indexOfSelectedAccent
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           self.accent = self.accentsShortCodes[selectedIndex];
                                           self.indexOfSelectedAccent = selectedIndex;
                                       }
                                     cancelBlock:nil
                                          origin:sender];
    
}

- (IBAction)playButtonPressed:(id)sender {
    [self playCurrentShak];
}

- (IBAction)sendButtonPressed:(id)sender {
}

- (void)playCurrentShak {
    [self.speaker stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    float pitchMultiplier = self.pitchSlider.value;
    float rate = self.speedSlider.value;
    NSString *shakText = self.shakTextView.text;
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:shakText];
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:self.accent];
    [utterance setVoice:voice];
    [utterance setPitchMultiplier:pitchMultiplier];
    [utterance setRate:rate];
    [self.speaker speakUtterance:utterance];
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

- (void)configureButtons {

}

- (void)configureNavBarButtons {
    UIButton *friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    friendsButton.bounds = CGRectMake(0, 0, 30, 30);
    [friendsButton setBackgroundImage:[UIImage imageNamed:@"FriendsIcon"] forState:UIControlStateNormal];
    [friendsButton addTarget:self action:@selector(showFriendsView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *friendsBarButton = [[UIBarButtonItem alloc] initWithCustomView:friendsButton];
    self.navigationItem.rightBarButtonItem = friendsBarButton;
}

- (void)configureAccents {
    if (!self.accentsShortCodes) {
        self.accentsShortCodes = @[@"ar-SA", @"en-ZA", @"nl-BE", @"en-AU", @"th-TH", @"de-DE", @"en-US", @"pt-BR", @"pl-PL", @"en-IE", @"el-GR", @"id-ID", @"sv-SE", @"tr-TR", @"pt-PT", @"ja-JP", @"ko-KR", @"hu-HU", @"cs-CZ", @"da-DK", @"es-MX", @"fr-CA", @"nl-NL", @"fi-FI", @"es-ES", @"it-IT", @"he-IL", @"no-NO", @"ro-RO", @"zh-HK", @"zh-TW", @"sk-SK", @"zh-CN", @"ru-RU", @"en-GB", @"fr-FR", @"hi-IN"];
    }
    if (!self.accentsFullNames) {
        self.accentsFullNames = @[@"Arabic (Saudi Arabia)", @"English (South Africa)", @"Dutch (Belgium)", @"English (Australian)", @"Thai (Thailand)", @"German (Germany)", @"English (United States)", @"Portuguese (Brazil)", @"Poland (Polish)", @"English (Ireland)", @"Modern Greek (Greece)", @"Indonesian (Indonesia)", @"Swedish (Sweden)", @"Turkish (Turkey)", @"Portuguese (Portugal)", @"Japan (Japanese)", @"Korean (South Korea)", @"Hungarian (Hungary)", @"Czech (Czech Republic)", @"Danish (Denmark)", @"Spanish (Mexico)", @"French (Canadian)", @"Dutch (Netherlands)", @"Finnish (Finland)", @"Spanish (Spain)", @"Italian (Italy)", @"Hebrew (Israel)", @"Norweigan (Norway)", @"Romanian (Romania)", @"Chinese (Hong Kong)", @"Chinese (Taiwan)",@"Slovak (Slovakia)", @"Chinese (China)", @"Russian (Russia)", @"English (Great Britain)", @"French (France)", @"Hindi (India)"];
    }
}

- (void)showFriendsView {
    ZSSFriendsTableViewController *ftvc = [[ZSSFriendsTableViewController alloc] init];
    [self.navigationController pushViewController:ftvc animated:YES];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TESTING MY FUCKING BROKEN FUNCTIONS

@end

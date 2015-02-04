//
//  AppDelegate.m
//  Shakd
//
//  Created by Zachary Shakked on 12/27/14.
//  Copyright (c) 2014 Shakked Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ZSSWelcomeViewController.h"
#import <Parse/Parse.h>
#import "ZSSLocalStore.h"
#import "ZSSHomeViewController.h"
#import "ZSSCloudQuerier.h"
#import "ZSSLocalSyncer.h"
#import "RKDropdownAlert+CommonAlerts.h"
#import "UIColor+ShakdColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
#warning BEGINE UPDATES/END UPDATES

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configureParse:application];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    if ([PFUser currentUser]) {
        [[ZSSCloudQuerier sharedQuerier] saveUserForCurrentInstallation];
        ZSSHomeViewController *hvc = [[ZSSHomeViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hvc];
        self.window.rootViewController = nav;
    } else {
        ZSSWelcomeViewController *wvc = [[ZSSWelcomeViewController alloc] init];
        self.window.rootViewController = wvc;
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[ZSSLocalStore sharedStore] saveCoreDataChanges];
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}
 
- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    // user tapped notification while app was in background
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        // go to screen relevant to Notification content
        
    } else {
        NSString *alertMessage = userInfo[@"aps"][@"alert"];
        [RKDropdownAlert title:alertMessage backgroundColor:[UIColor charcoalColor] textColor:[UIColor whiteColor]];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)configureParse:(UIApplication *)application {
    NSString *keyPath = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSDictionary *keyDict = [NSDictionary dictionaryWithContentsOfFile:keyPath];
    NSString *parseApplicationId = keyDict[@"ParseApplicationId"];
    NSString *parseClientKey = keyDict[@"ParseClientKey"];
    [Parse setApplicationId:parseApplicationId
                  clientKey:parseClientKey];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}


@end
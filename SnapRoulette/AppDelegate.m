//
//  AppDelegate.m
//  SnapRoulette
//
//  Created by Nikolas Gelo on 11/8/14.
//  Copyright (c) 2014 Nikolas Gelo. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure the applicaiton with the Parse SDK.
    [Parse setApplicationId:@"KaobAtZ2RN71vQlWoZWPKVD51cqCIPirGfTsSq8m"
                  clientKey:@"AuyBC5IMWQttOIhhoQ44mxEMpQ0IelFsDyX8gFTO"];
    
    // Track applicaion launches with the Parse SDK
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register application for remote notifications.
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    // Save current installation with the Parse SDK.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation saveInBackground];
    
    // Override point for customization after application launch.
    return YES;
}

#pragma mark Handling Remote Notifications

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

@end

//
//  PQAppDelegate.m
//  Perq
//
//  Created by Dan Kwon on 8/1/14.
//  Copyright (c) 2014 TheGridMedia. All rights reserved.
//

#import "PQAppDelegate.h"
#import "PQContainerViewController.h"
#import "PQSession.h"

@interface PQAppDelegate ()
@property (strong, nonatomic) PQSession *session;
@end

@implementation PQAppDelegate
@synthesize showStatusBar;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.session = [PQSession sharedSession]; // start the session
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"deviceToken"]; // check for stored token
    if (token)
        self.session.device.deviceToken = token;

    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    

    self.showStatusBar = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    PQContainerViewController *containerVc = [[PQContainerViewController alloc] init];
    self.window.rootViewController = containerVc;


    [self.window makeKeyAndVisible];
    return YES;
}


-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"application didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    
    if (!deviceToken)
        return;
    
//    UALOG(@"APN device token: %@", deviceToken);
//    [[UAPush shared] registerDeviceToken:deviceToken];
    
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"deviceToken"];
    [defaults synchronize];
    
    NSLog(@"DEVICE TOKEN: %@", token);
    if ([self.session.device.deviceToken isEqualToString:token]) // no need to update
        return;
    
    
    self.session.device.deviceToken = token;
    [self.session.device updateDevice]; // send token info to backend
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    for (id key in userInfo)
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

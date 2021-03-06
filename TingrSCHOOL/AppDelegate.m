//
//  AppDelegate.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/6/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "PostDetailedViewController.h"
#import "FromDetailViewController.h"
#import "MessageDetailViewController.h"
#import "ProfileKidsTOCV2ViewController.h"
@import UserNotifications;
@import Firebase;

@interface AppDelegate ()<FIRMessagingDelegate,UNUserNotificationCenterDelegate>
{
    NSString *notifiUID;
    NSDictionary *userDict;
}
@end

@implementation AppDelegate
@synthesize leftMenu;
@synthesize bottomSafeAreaInset;
@synthesize topSafeAreaInset;
@synthesize isPushCalled;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[SingletonClass sharedInstance] setUserDetails];
    
    
     bottomSafeAreaInset = 0;
     topSafeAreaInset = 0;
    if (@available(iOS 11, *)) {
        UIEdgeInsets inset = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
        bottomSafeAreaInset = inset.bottom;
        topSafeAreaInset = inset.top;
    }

    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor darkGrayColor],
                                                                                                  NSForegroundColorAttributeName,
                                                                                                  [UIColor whiteColor],
                                                                                                  NSForegroundColorAttributeName,
                                                                                                  [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                                                                  NSForegroundColorAttributeName,
                                                                                                  nil]
                                                                                        forState:UIControlStateNormal];
    
    //set the nav bar appearance for the entire application
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:186/255.0 green:189/255.0 blue:194/255.0 alpha:1]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           UIColorFromRGB(0x6fa8dc), NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0], NSFontAttributeName, nil]];

    
    [self setSliderMenu];
    
    [FIRApp configure];
    
  /*
    if (launchOptions != nil)
    {
        
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            if(!isPushCalled)
            {
                isPushCalled = YES;
                notifiUID = [dictionary objectForKey:@"notification_id"];
                userDict = dictionary;
                
            }
        }
        
    }
   */
    return YES;
}
-(void)setSliderMenu {
    
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    leftMenu = (MenuViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier: @"MenuViewController"];
    
    
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    BOOL key = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemember"];
    
    if(key)
    {
        [self askForNotificationPermission];
        [self subscribeUserToFirebase];
    }
    
    self.vcheck = [[VersionCheck alloc]init];
    [self.vcheck checkforApplicationUpgrade];

    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark Notification Permission
-(void)askForNotificationPermission
{
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        
        
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].remoteMessageDelegate = self;
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    // Print full message.
/*
    if ( (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) && ![[userInfo objectForKey:@"notification_id"] isEqualToString:notifiUID] )
    {
        AccessToken* token = [[ModelManager sharedModel] accessToken];
        if(token != nil || token.access_token != nil)
        {
            [self actUponNotification:userInfo];
        }
    }
    */
    
    DebugLog(@"%@", userInfo);
}
-(void)pushNotificationClicked {
    
   // [self actUponNotification:userDict];
}

- (void)actUponNotification:(NSDictionary*)userInfo {
    
    DebugLog(@"in  has notifications %s",__func__);
    /*
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"killed"];
    
    NSString *type = [[userInfo valueForKey:@"type"] lowercaseString];
    
    
    if([type isEqualToString:@"post"] || [type isEqualToString:@"comment"] || [type isEqualToString:@"vote"]) {
        
        NSString *post_id = [userInfo valueForKey:@"post_id"];
        NSString *comment_id = [userInfo valueForKey:@"comment_id"];
        
        if(post_id != nil && post_id.length > 0)
        {
            [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
            
            PostDetailedViewController *postCntrl = (PostDetailedViewController*)[mainStoryboard
                                             instantiateViewControllerWithIdentifier: @"PostDetailedViewController"];
            postCntrl.post_ID = post_id;
            postCntrl.comment_ID = comment_id;
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SlideNavigationController sharedInstance] pushViewController:postCntrl animated:YES];
            });
        }
        
    }
    else if([type isEqualToString:@"message"]) {
        
        [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        MessageDetailViewController *msgCntrl = (MessageDetailViewController*)[mainStoryboard
                                                                              instantiateViewControllerWithIdentifier: @"MessageDetailViewController"];

        msgCntrl.messageDictFromLastPage = [userInfo mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SlideNavigationController sharedInstance] pushViewController:msgCntrl animated:YES];
        });
        
    }
    else if([type isEqualToString:@"form"] || [type isEqualToString:@"document"]) {
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        FromDetailViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FromDetailViewController"];
        vc.detailDict = userInfo;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        });
        
    }
    else if([type isEqualToString:@"new_kid"]) {
        
        NSString *kid_klid = [userInfo valueForKey:@"kid_klid"];

        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        ProfileKidsTOCV2ViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ProfileKidsTOCV2ViewController"];
        vc.kid_klid = kid_klid;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[SlideNavigationController sharedInstance] pushViewController:vc animated:YES];
        });
        
    }
     
     */
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:NO_INTERNET_CONNECTION
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        
#ifdef DEBUG
        [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
#else
        [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];
#endif
        
        
        
        // Store the deviceToken in the current installation and save it to Parse.
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
}
-(void)subscribeUserToFirebase {
    
    
    NSString *string = [NSString stringWithFormat:@"/topics/tingr_%@",[[[ModelManager sharedModel] userProfile] teacher_klid]];
    [[FIRMessaging messaging] subscribeToTopic:string];
    
    
    NSString *fcmToken  = [[FIRInstanceID instanceID] token];
    NSLog(@"FCM registration token: %@", fcmToken);

}




@end

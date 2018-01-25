//
//  AppDelegate.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/6/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VersionCheck.h"

@class MenuViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) VersionCheck *vcheck;
@property (nonatomic, strong) MenuViewController *leftMenu;
@property (nonatomic, assign) float bottomSafeAreaInset;
@property (nonatomic, assign) float topSafeAreaInset;

-(void)askForNotificationPermission;
-(void)subscribeUserToFirebase;

@end


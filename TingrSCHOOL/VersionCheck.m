//
//  VersionCheck.m
//  KidsLink
//
//  Created by Dale McIntyre on 12/5/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "VersionCheck.h"
#import "ProfileDateUtils.h"

@implementation VersionCheck


-(id)init {
    
    //alert view
    
    self = [super init];
    
    return self;
    
}

-(void)checkforApplicationUpgrade
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    if(token.access_token == nil || token.access_token.length == 0)
        return;
    
    NSMutableDictionary *bodyRequest = [NSMutableDictionary dictionary];
    
    NSString *app_version = APP_VERSION;
    NSString *device_id = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [bodyRequest setValue:app_version   forKey:@"version"];
    [bodyRequest setValue:device_id   forKey:@"UUID"];
    
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"command": @"iOSVersionCheck",
                               @"access_token": token.access_token,
                               @"body": bodyRequest};
    
    NSDictionary *userInfo = @{@"command":@"iOSVersionCheck"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    
    __weak __typeof(self)weakSelf = self;
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf didReceiveVersion:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
    } failure:^(NSDictionary *json) {
        

    }];

    
}

- (void)didReceiveVersion:(NSDictionary *)versionData
{
    //TODO: PUT IN THE CALL TO GET THE DATA HERE FOR THE VERSION CHECK
    //WE ARE INTERCEPTING BEFORE LOGIN/WELCOME, ETC
    NSString *currentVersion = APP_VERSION;
    NSString *latestVersion = [versionData valueForKey:@"version"];

    BOOL upgrade = [[versionData valueForKey:@"upgrade"] boolValue];
    BOOL isRequired = [[versionData valueForKey:@"required"] boolValue];
    
    if (upgrade && (![currentVersion isEqualToString:latestVersion]))
    {
        if (!isRequired && ![self hasSeenMessageInDays:7])
        {
            //popup an alert
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Update available!"
                                                           message:@"Don't miss out on the latest TingrSCHOOL features and fixes."
                                                          delegate:self
                                                 cancelButtonTitle:@"Skip"
                                                 otherButtonTitles:@"Update", nil];
            alert.tag = 1;
            [alert show];
        }
        else if(isRequired)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Update required!"
                                                           message:@"There's a new version of TingrSCHOOL. You must update to continue using the app."
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"Update", nil];
            alert.tag = 2;
            [alert show];
            
        }
    }
}

- (void)fetchingVersionFailedWithError:(NSError *)error
{
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1)
    {
    switch (buttonIndex)
    {
        case 0:
        {
            
            break;
        }
        case 1:
        {
            NSString *iTunesLink = @"itms-apps://itunes.apple.com/us/app/tingr-app-for-schools/id1191484581?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
            
            break;
        }
        default:
        {
            
            break;
        }
    }
    }
    else
    {
        NSString *iTunesLink = @"itms-apps://itunes.apple.com/us/app/tingr-app-for-schools/id1191484581?mt=8";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];

    }
    
}

-(BOOL)hasSeenMessageInDays:(int)days
{
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSDate *lastViewDate = [defaults objectForKey:@"LAST_UPGRADE_VIEW_DATE"];

    NSLog(@"Last viewed date %@", lastViewDate);
    
    NSInteger daysBetween = 0;
    if (lastViewDate != nil)
    {
        daysBetween = [ProfileDateUtils daysBetweenDate:lastViewDate andDate:[NSDate date]];
    }
    
    if (lastViewDate == nil || daysBetween > days)
    {
        [defaults setObject:[NSDate date] forKey:@"LAST_UPGRADE_VIEW_DATE"];
        [defaults synchronize];
        return FALSE;
    }
    
    return (daysBetween < days);
}

@end

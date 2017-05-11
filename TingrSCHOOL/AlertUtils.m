//
//  AlertUtils.m
//  KidsLink
//
//  Created by Dale McIntyre on 2/11/15.
//  Copyright (c) 2015 Kids Link. All rights reserved.
//

#import "AlertUtils.h"

@implementation AlertUtils

+(void)errorAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TingrSCHOOL"
                                                    message:@"Opps...we detected there is some technical glitch. While we investigate it, you can try re-launching app. Sometimes it helps that way!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

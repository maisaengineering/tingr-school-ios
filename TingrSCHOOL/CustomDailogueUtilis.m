//
//  CustomDailogueUtilis.m
//  Tingr
//
//  Created by Maisa Pride on 1/18/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "CustomDailogueUtilis.h"

@implementation CustomDailogueUtilis

@synthesize indicator;
+ (id)sharedInstance
{
    static CustomDailogueUtilis *singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        singletonObject = [[self alloc] init];
    });
    return singletonObject;
}


#pragma mark -
#pragma mark Methods To Show Activity Indicator
- (void)showIndicator:(BOOL)show
{

    if(!indicator)
    {
        indicator = [[MBProgressHUD alloc] initWithView:MainWindow];
        indicator.mode = MBProgressHUDAnimationFade;
    }
    
    if(show)
    {
        [MainWindow addSubview:indicator];
        [indicator show:YES];
    }
    else
    {
        [indicator hide:YES];
        [indicator setLabelText:@""];
        [indicator removeFromSuperview];
    }
    
}

- (void)showIndicator:(BOOL)show withMessage:(NSString *)message{
    
    if(show)
    {
        
        [MainWindow addSubview:indicator];
        [indicator show:YES];
        [indicator setLabelText:message];
        
    }
    else
    {
        [indicator removeFromSuperview];
        [indicator hide:YES];
        [indicator setLabelText:@""];
    }
}

@end

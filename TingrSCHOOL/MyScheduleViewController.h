//
//  MyScheduleViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/6/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
@class AppDelegate;

@interface MyScheduleViewController : UIViewController<SlideNavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UIScrollView *schoolNameScrollView;
@property (nonatomic, strong) UIPageControl * pageControl;
@property (nonnull, strong) UIButton *dateButton;
@property (nonatomic, strong) NSString *selectedDate;

@end

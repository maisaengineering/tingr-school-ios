//
//  MyClassViewController.h
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/7/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "AppDelegate.h"
@class AppDelegate;

@interface MyClassViewController : UIViewController<SlideNavigationControllerDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, retain) UIScrollView *schoolNameScrollView;
@property (nonatomic, retain) UIPageControl * pageControl;
@property (retain, nonatomic) IBOutlet UITableView *tableViewProfile;
@property (retain, nonatomic) NSMutableArray *kidsArray;



@end

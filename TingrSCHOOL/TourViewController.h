//
//  TourViewController.h
//  KidsLink
//
//  Created by Maisa Solutions on 7/23/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QHTTPOperation.h"
@class QWatchedOperationQueue;
@interface TourViewController : UIViewController<QHTTPOperationAuthenticationDelegate,UIScrollViewDelegate>
{
    UIImageView *imageView;
    QWatchedOperationQueue * watch;
    NSDictionary *tour_Dict;
    NSString *base_Url;
}
@property (nonatomic, strong)  UIScrollView *scrollView;
@property (nonatomic, strong) UIButton *continueButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *addKidButton;
@property (nonatomic, strong) UIButton *inviteFriendsButton;
@property (nonatomic, strong) UIButton *justExploreButton;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, retain) UIPageControl * pageControl;
@property BOOL isFromMoreTab;

- (void)continueButtonTapped:(UIButton *)sender;
@end

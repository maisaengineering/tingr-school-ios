//
//  TourViewController.m
//  KidsLink
//
//  Created by Maisa Solutions on 7/23/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "TourViewController.h"
#import "SVWebViewController.h"
#import "ProfilePhotoUtils.h"
#import "UIImageView+AFNetworking.h"
#import "QHTTPOperation.h"
#import "QWatchedOperationQueue.h"

@interface TourViewController ()
{
    int imageID;
    ModelManager *sharedModel;
    ProfilePhotoUtils *photoUtils;
    MBProgressHUD *HUD;
    int downloadingImagesCount;
    int downloadedImagesCount;
    AppDelegate *appDelegate;
}
@end

@implementation TourViewController
@synthesize scrollView;
@synthesize imageArray;
@synthesize continueButton;
@synthesize addKidButton;
@synthesize inviteFriendsButton;
@synthesize justExploreButton;
@synthesize isFromMoreTab;
@synthesize backButton;
@synthesize pageControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    
    CGRect frame = scrollView.frame;
    frame.size = CGSizeMake(Devicewidth, Deviceheight);
    frame.origin.y = 0;
    scrollView.frame = frame;


    photoUtils = [ProfilePhotoUtils alloc];
    imageID = 0;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    sharedModel = [ModelManager sharedModel];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(downloadImages)
     name:@"TourImages_API"
     object:nil ];
    
    tour_Dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PromptImages"] objectForKey:@"welcome_tour"];
    base_Url = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PromptImages"] objectForKey:@"asset_base_url"];
    imageArray = [tour_Dict objectForKey:@"assets"];
    
    
    if([imageArray count] >= 1)
    {
        
        [self downloadImages];
    }
    [self.navigationController setNavigationBarHidden:YES];
    
    [self loadLocalImages];
    [self addScrollviewWithLocalImages];
}

-(void)downloadImages
{
    

    downloadedImagesCount = 0;
    downloadingImagesCount = 0;
    watch = [[QWatchedOperationQueue alloc]init];
    watch.maxConcurrentOperationCount = 10;
    for ( int i=0; i<[imageArray count]; i++)
    {
        NSString *urlstriing =[NSString stringWithFormat:@"%@%@",base_Url,[[imageArray objectAtIndex:i] objectForKey:@"url"]];
        
        UIImage *thumb = [photoUtils getImageFromCache:urlstriing];
        
        if (thumb == nil)
        {
            downloadingImagesCount ++;
            NSURL *url = [NSURL URLWithString:[NSString stringWithString:urlstriing]];
            QHTTPOperation * op = [[QHTTPOperation alloc]initWithURL:url withKey:urlstriing];
            op.authenticationDelegate = self;
            [watch addOperation:op];
        }
        else
        {
            downloadedImagesCount++;
        }
    }
    if(downloadedImagesCount == imageArray.count)
    {
        [[NSUserDefaults standardUserDefaults] setObject:tour_Dict forKey:@"lastTour"];
        [self addScrollView];
    }
    else if([[NSUserDefaults standardUserDefaults] objectForKey:@"lastTour"])
    {
        imageArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lastTour"] objectForKey:@"assets"];
        [self addScrollView];
        
    }
    else
    {
        ///load local images when api images are not downloaded
        [self loadLocalImages];
        [self addScrollviewWithLocalImages];
    }
   /* else {
        HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:HUD];
        [HUD show:YES];
    }
    */
    
}
-(void)loadLocalImages
{
    imageArray = @[[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour_0.jpg",@"name",[NSNumber numberWithBool:NO],@"perm_notification",nil],[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour_1.jpg",@"name",[NSNumber numberWithBool:NO],@"perm_notification",nil],[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour_2.jpg",@"name",[NSNumber numberWithBool:NO],@"perm_notification",nil],[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour_3.jpg",@"name",[NSNumber numberWithBool:YES],@"perm_notification",nil],[NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"continue", nil],@"actions",@"tour_4.jpg",@"name",[NSNumber numberWithBool:YES],@"perm_notification",nil]];
}
-(void)finishImageDownload:(NSString *)key withImage:(UIImage *)image
{
    [photoUtils saveImageToCache:key :image];
    downloadingImagesCount--;
    if(downloadingImagesCount == 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:tour_Dict forKey:@"lastTour"];
        [self addScrollView];
    }
    DebugLog(@"downloadingImagesCount %i",downloadingImagesCount);
    
}
-(void)failedToDownload
{
    if(isFromMoreTab)
    {
        [HUD hide:YES];
        [self loadLocalImages];
        [self addScrollviewWithLocalImages];
    }
}
-(void)addScrollviewWithLocalImages
{
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(70, Deviceheight-46, Devicewidth-140, 38);
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    pageControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
    pageControl.numberOfPages = 5;
   
    [self.view addSubview:self.pageControl];

    
    for (int i = 0; i < [imageArray count]; i++)
    {
        //We'll create an imageView object in every 'page' of our scrollView.
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *tour_ImageView = [[UIImageView alloc] initWithFrame:frame];
        tour_ImageView.image = [UIImage imageNamed:[[imageArray objectAtIndex:i] objectForKey:@"name"]];
        [self.scrollView addSubview:tour_ImageView];
    }
    
    //Set the content size of our scrollview according to the total width of our imageView objects.
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [imageArray count], scrollView.frame.size.height);
    scrollView.bounces = NO;
    // Continue
    continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueButton.frame = CGRectMake(Devicewidth-122+10, Deviceheight-46, 122, 38);
    continueButton.tag = 1;
    [continueButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [continueButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    // Back
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(-10, Deviceheight-46, 122, 38);
    backButton.tag = 2;
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    backButton.hidden = YES;
    
    // Add Kid + Spouse
    addKidButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addKidButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [addKidButton setTag:234];
//    [self.view addSubview:addKidButton];

    // Invite  Friends
    inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteFriendsButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [inviteFriendsButton setTag:235];
   // [self.view addSubview:inviteFriendsButton];
    
    // Just Explore
    justExploreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [justExploreButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [justExploreButton setTag:236];
    [justExploreButton setImage:[UIImage imageNamed:@"getStarted"] forState:UIControlStateNormal];
    [justExploreButton setFrame:CGRectMake(Devicewidth-107-10, Deviceheight-46, 107, 38)];
    justExploreButton.hidden = YES;
    [self.view addSubview:justExploreButton];
    
}
- (void)changePage:(id)sender {
    
    
    UIPageControl *pager=sender;
   long int page = pager.currentPage;
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    
    
    long int index = page;
    if(index <= 0)
    {
        index = 0;
    }
    if(index > imageID)
    {
        if ([[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue])
        {
            [self askForNotificationPermission];
        }
    }
    imageID = (int)index;
    
    
    if(index > 0)
        backButton.hidden = NO;
    else
        backButton.hidden = YES;
    if(index + 1 == imageArray.count)
    {
        continueButton.hidden = YES;
        justExploreButton.hidden = NO;
    }
    else
    {
        continueButton.hidden = NO;
        justExploreButton.hidden = YES;
        
    }

    
}

-(void)addScrollView
{
    downloadedImagesCount = 0;
    downloadingImagesCount = 0;
    
    
    for (int i = 0; i < [imageArray count]; i++)
    {
        
        //We'll create an imageView object in every 'page' of our scrollView.
        CGRect frame;
        frame.origin.x = self.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scrollView.frame.size;
        
        UIImageView *tour_ImageView = [[UIImageView alloc] initWithFrame:frame];
        
        NSString *url =[NSString stringWithFormat:@"%@%@",base_Url,[[imageArray objectAtIndex:i] objectForKey:@"url"]];
        
        UIImage *thumb = [photoUtils getImageFromCache:url];
        
        if (thumb == nil)
        {
            downloadingImagesCount ++;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                           {
                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                               
                               UIImage* image = [[UIImage alloc] initWithData:imageData];
                               if (image) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       downloadingImagesCount--;
                                       tour_ImageView.image = image;
                                       //save it to cache
                                       [photoUtils saveImageToCache:url :tour_ImageView.image];                                              [tour_ImageView setNeedsLayout];
                                       if(downloadingImagesCount == 0)
                                       {
                                           [HUD hide:YES];
                                       }
                                   });
                               }
                           });
        }
        else
        {
            downloadedImagesCount++;
            tour_ImageView.image = thumb;
        }
        
        [self.scrollView addSubview:tour_ImageView];
    }
    
    if(downloadedImagesCount == imageArray.count)
    {
        [HUD hide:YES];
        
    }
    //Set the content size of our scrollview according to the total width of our imageView objects.
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [imageArray count], 300);
    
    // Continue
    continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueButton.frame = CGRectMake(190, Deviceheight-53, 110, 40);
    continueButton.tag = 1;
    [continueButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
    
    // Back
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(20, Deviceheight-53, 110, 40);
    backButton.tag = 2;
    [backButton addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // Add Kid + Spouse
    addKidButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addKidButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [addKidButton setTag:234];
    [self.view addSubview:addKidButton];
    
    // Invite  Friends
    inviteFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteFriendsButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [inviteFriendsButton setTag:235];
    [self.view addSubview:inviteFriendsButton];
    
    // Just Explore
    justExploreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [justExploreButton addTarget:self action:@selector(addKidButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [justExploreButton setTag:236];
    [self.view addSubview:justExploreButton];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"back"])
        [self.view addSubview:backButton];
    else
        [backButton removeFromSuperview];
    
    if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] count] > 0 && ![[[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] firstObject] isEqualToString:@"continue"])
    {
        [continueButton removeFromSuperview];
        
        [addKidButton setFrame:CGRectMake(105, Deviceheight-215, 175, 46)];
        [inviteFriendsButton setFrame:CGRectMake(105, Deviceheight-145, 140, 46)];
        if (Deviceheight<568)
            [justExploreButton setFrame:CGRectMake(105, Deviceheight-82, 120, 46)];
        else
            [justExploreButton setFrame:CGRectMake(105, 485, 120, 46)];
        
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"add_kid"])
            [self.view addSubview:addKidButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"invite_friends"])
            [self.view addSubview:inviteFriendsButton];
        if([[[imageArray objectAtIndex:imageID] objectForKey:@"actions"] containsObject:@"just_explore"])
            [self.view addSubview:justExploreButton];
    }
    else
    {
        [self.view addSubview:continueButton];
        
        [addKidButton removeFromSuperview];
        [inviteFriendsButton removeFromSuperview];
        [justExploreButton removeFromSuperview];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    SingletonClass *singletonObj = [SingletonClass sharedInstance];
    singletonObj.streamCallCount = 0;
    singletonObj.isStreamsDownloaded = NO;
    NSMutableArray *array = [[self.navigationController viewControllers] mutableCopy];
    [array removeObject:self];
    self.navigationController.viewControllers = array;
    
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark- UIScrollView Delegate
#pragma mark-
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1;
{
    
    int index = scrollView1.contentOffset.x / scrollView1.frame.size.width;
    
    pageControl.currentPage = index;
    
    if(index <= 0)
    {
        index = 0;
    }
    if(index > imageID)
    {
        if ([[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue])
        {
            [self askForNotificationPermission];
        }
    }
    imageID = index;
    
    
    if(index > 0)
        backButton.hidden = NO;
    else
        backButton.hidden = YES;
    if(index + 1 == imageArray.count)
    {
        continueButton.hidden = YES;
        justExploreButton.hidden = NO;
    }
    else
    {
        continueButton.hidden = NO;
        justExploreButton.hidden = YES;
        
    }
    
        
    
    
}

- (void)continueButtonTapped:(UIButton *)sender
{
    if([sender tag] == 1)
    {
        if ([[[imageArray objectAtIndex:imageID] objectForKey:@"perm_notification"] boolValue])
        {
            [self askForNotificationPermission];
        }
        
        imageID++;
        
    if(imageID == imageArray.count)
        {
            if(isFromMoreTab)
            {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            else
            {
                [self goToMainTabs];
            return;
            }
        }
        
        
        pageControl.currentPage = imageID;
        [scrollView setContentOffset:CGPointMake(imageID*scrollView.frame.size.width, 0) animated:YES];
        if(imageID > 0)
            backButton.hidden = NO;
        else
            backButton.hidden = YES;
        if(imageID + 1 == imageArray.count)
        {
            continueButton.hidden = YES;
            justExploreButton.hidden = NO;
        }
        else
        {
            continueButton.hidden = NO;
            justExploreButton.hidden = YES;
            
        }
        
    }
    else
    {
        imageID--;
        
        pageControl.currentPage = imageID;
        
        [scrollView setContentOffset:CGPointMake(imageID*scrollView.frame.size.width, 0) animated:YES];
        if(imageID > 0)
            backButton.hidden = NO;
        else
            backButton.hidden = YES;
        if(imageID + 1 == imageArray.count)
        {
            continueButton.hidden = YES;
            justExploreButton.hidden = NO;
        }
        else
        {
            continueButton.hidden = NO;
            justExploreButton.hidden = YES;
            
        }
    }
    
}

-(void) askForNotificationPermission
{
    //[appDelegate askForNotificationPermission];
}

-(void)addKidButtonTapped:(UIButton *)sender
{
   
    
    if(isFromMoreTab)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    else
    {
        
        //[appDelegate setUpTimer];
        [self goToMainTabs];
    }
  
}

-(void)goToMainTabs
{
    
    [appDelegate askForNotificationPermission];
    [appDelegate subscribeUserToFirebase];
    [self performSegueWithIdentifier: @"MainAppSegue" sender: self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

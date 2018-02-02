//
//  AddPostViewController.m
//  KidsLink
//
//  Created by Maisa Solutions on 4/17/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "AddPostViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "StreamDisplayView.h"
#import "ProfileKidsTOCV2ViewController.h"
#import "PostDataUpload.h"
@interface AddPostViewController () {
    //****
    //Milestone specific input control
    //****
    MilestoneView *mileStoneView;
    
    
    
   // HeightWeight *heightWeightView;

    //****
    //Standard property to hold shared model
    //****
    ModelManager *sharedModel;
    
    //****
    //Standard property to hold shared singleton
    //****
    SingletonClass *sharedInstance;
    
    float topSpace;
}
@end

@implementation AddPostViewController

//****
// This is used to auto tag the profile when we click add post form profile dash board
//****
@synthesize profileId;

//****
//This holds the tag id of the top button that was clicked
//1 = moment
//2 = milestone
//3 = ask friends
//****
@synthesize index;

//****
//holds the selected image FROM the milestone and moment views
//****
@synthesize attachedImage;

//****
//holds the message image FROM the milestone and moment views
//****
@synthesize attachedMessage;

//****
//This seems to be how the post view controller tells if this is your first post or not
//TODO: we may want to engineer a little differently
//****
@synthesize isSharing;

//****
//How the post controller knows this post is from the first added child
//TODO: put more here about what happens when it is TRUE
//****
@synthesize isFromFirstAddedChild;

///Used to hold details of moment/milestone when came form streams dropdown->edit
@synthesize detailsDictionary;
@synthesize steamDisplayView;
@synthesize momentImage;
@synthesize childDetails;
@synthesize videoUrl;

//This is from adding any child
@synthesize isFromAddedChild;

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
    
    sharedModel   = [ModelManager sharedModel];
    sharedInstance = [SingletonClass sharedInstance];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    topSpace = appDelegate.topSafeAreaInset >0?15:0;
    [[PostDataUpload sharedInstance] clearData];
    
    self.navigationController.navigationBarHidden = YES;
    
    // Do any additional setup after loading the view.
    int height = Deviceheight-64-topSpace;
    DebugLog(@"id:%@",self.profileId);
    self.view.backgroundColor = [UIColor colorWithRed:229/255.0 green:225/255.0f blue:221/255.0 alpha:1.0];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,screenWidth, 64+topSpace)];
    [topView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:topView];
    UIImageView *lineImage = [[UIImageView alloc] init];
    [lineImage setBackgroundColor:[UIColor colorWithRed:192/255.0 green:184/255.0 blue:176/255.0 alpha:1.0]];
    [lineImage setFrame:CGRectMake(0, topSpace+63.5f, screenWidth, 0.5f)];
    [self.view addSubview:lineImage];
    
    
    
    CGRect frame = CGRectMake(0, topSpace+20, screenWidth, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColorFromRGB(0x6fa8dc);
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    [topView addSubview:label];
    
    if (isFromAddedChild == TRUE)
    {
        
    }
    else
    {
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setImage:[UIImage imageNamed:@"back_arrow.png"] forState:UIControlStateNormal];

        [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(0, topSpace+22.5, 40, 40)];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:17]];
        [topView addSubview:cancelButton];
    }
    
    UIButton *tickMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tickMarkButton setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
    [tickMarkButton addTarget:self action:@selector(postClicked:) forControlEvents:UIControlEventTouchUpInside];
    [tickMarkButton setFrame:CGRectMake(Devicewidth-50, topSpace+24.5, 49, 35)];
    [topView addSubview:tickMarkButton];

    
    if (isFromAddedChild != TRUE)
    {
        isFromAddedChild = FALSE;
    }
    if(index==3)
    {
      /*  label.text  = @"Quotes";
        
        askFriendsView = [[AskFriendsView alloc] initWithFrame:CGRectMake(0, 64, 320, height)];
        
        [self.view addSubview:askFriendsView];
        askFriendsView.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:askFriendsView
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
     */
    }
    else if(index==5)
    {
        label.text  = @"Height + weight";
        
     /*   heightWeightView = [[HeightWeight alloc] initWithFrame:CGRectMake(0, 64, 320, height)];
        
        [self.view addSubview:heightWeightView];
        heightWeightView.delegate = self;

        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"Save" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(saveClicked) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitleColor:[UIColor colorWithRed:(251/255.f) green:(176/255.f) blue:(64/255.f) alpha:1] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(240, 20.5, 80, 44)];
        [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Roman" size:17]];
        [topView addSubview:cancelButton];
      */
    }
    else
    {
        label.text  = @"Capture a moment";
        mileStoneView = [MilestoneView alloc];
        [mileStoneView setDelegate:self];
        mileStoneView.profileID = self.profileId;
        mileStoneView.isFromAddedChild = self.isFromAddedChild;
        mileStoneView.isTextOnly = self.isTextOnly;
        if(detailsDictionary != nil)
        {
            mileStoneView.isUpdate = YES;
            label.text  = @"Edit moment";
            mileStoneView = [mileStoneView initWithFrame:CGRectMake(0, topSpace+64, Devicewidth, height)];
            [mileStoneView setData:detailsDictionary];
        }
        else if(momentImage != nil)
        {
            mileStoneView = [mileStoneView initWithFrame:CGRectMake(0, topSpace+64, Devicewidth, height)];
            [mileStoneView finishedEditingImage:momentImage];
        }
        else if(videoUrl != nil)
        {
            mileStoneView = [mileStoneView initWithFrame:CGRectMake(0, topSpace+64, Devicewidth, height)];
            [mileStoneView videoRecordCompletedWithOutputUrl:videoUrl];
        }
        else
            mileStoneView = [mileStoneView initWithFrame:CGRectMake(0, topSpace+64, Devicewidth, height)];
        
        
        [self.view addSubview:mileStoneView];
    }
    
}
-(void)saveClicked
{
 //   [heightWeightView postClicked];
}
- (void)keyboardDidShow:(NSNotification*)notification {
}
-(IBAction)postClicked:(id)sender
{
    //send event to track first post
    
    if( mileStoneView.hidden == NO)
    {
        [mileStoneView postClicked:sender];
    }
    
  /*  else if( askFriendsView.hidden == NO)
    {
        [askFriendsView postClicked:sender];
    }
 */
}

-(void)viewWillAppear:(BOOL)animated
{
    //calls out to moment and mileston views
    [[NSNotificationCenter defaultCenter]
     addObserver:mileStoneView
     selector:@selector(checkFacebookButton:)
     name:FACEBOOK_CHECK
     object:nil ];
    self.navigationController.navigationBarHidden = YES;

    [super viewWillAppear:YES];
    
    [[SingletonClass sharedInstance] setPlusButtonTapped:NO];

}
- (void)checkMomentFacebookButton:(id)sender
{
    
}
- (void)checkFacebookButton:(id)sender
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:mileStoneView name:FACEBOOK_CHECK object:nil];
    [super viewWillDisappear:YES];
}



-(void)cancelClicked:(id)sender
{
    [[SingletonClass sharedInstance] setIsInstagramShareEnabled:NO];
    if(detailsDictionary != nil)
    {
        self.steamDisplayView.isEdited = YES;
    }
    //Tracking
    //[Flurry logEvent:@"Stream_Post_Cancel"];
    
    sharedModel.facebookShare = FALSE;
    [mileStoneView destroyView];
    
    if(childDetails != nil)
    {
        [self gotoChildDashBoard];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//called when an item has completed posting
- (void)mileStoneClick
{
    if(detailsDictionary != nil)
    {
        self.steamDisplayView.isEdited = YES;
        [self.steamDisplayView.storiesArray replaceObjectAtIndex:self.steamDisplayView.editIndex withObject:detailsDictionary];
    }
    
    UIBarButtonItem *postButton = (UIBarButtonItem *)[self.view viewWithTag:98765];
    [postButton setEnabled:YES];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"STREAM_ITEM_POSTED" object:nil];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];});
    
    if(childDetails != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}
- (void)gotoChildDashBoard
{

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ProfileKidsTOCV2ViewController *profileKidsTOCV2ViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ProfileKidsTOCV2ViewController"];
    
    profileKidsTOCV2ViewController.person = [childDetails mutableCopy];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SHOW_TABS" object:nil];
    
    [self.navigationController pushViewController:profileKidsTOCV2ViewController animated:YES];
}
#pragma mark- Instagram Method
#pragma mark-
-(void)showInstagramMessage
{
    
}

#pragma mark- MilestonesCreateManagerDelegate Methods
#pragma mark-
- (void)didReceiveCreateMilestones:(NSArray *)milestone
{
    DebugLog(@"%@",milestone);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];});
}
- (void)fetchingCreateMilestonesFailedWithError:(NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];});
    DebugLog(@"Error %@; %@", error, [error localizedDescription]);
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

-(void)checkShareStatus
{
    
}



@end

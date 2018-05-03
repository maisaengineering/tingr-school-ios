//
//  ProfileKidsTOCV2ViewController.m
//  KidsLink
//
//  Created by Dale McIntyre on 4/18/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "ProfileKidsTOCV2ViewController.h"
#import "KidProfileView.h"
#import "ProfilePhotoUtils.h"
#import "StreamDisplayView.h"
#import "CommentViewController.h"
#import "SVWebViewController.h"
#import "KLTextFormatter.h"
#import "HeartersViewController.h"
#import "MessageDetailViewController.h"
#import "NotesListViewController.h"
#import "RemindersViewController.h"
#import "FormsDocsViewController.h"
#import "MessageToParentViewController.h"
//#import "DocumentPagesViewController.h"
@interface ProfileKidsTOCV2ViewController ()<StreamDisplayViewDelegate>
{
    KidProfileView *profileView;
    ProfilePhotoUtils *photoUtils;
    AppDelegate *appDelegate;
    StreamDisplayView *streamView;
    NSMutableArray *storiesArray;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    UIImageView *profileImageBackgroundView;
    UIView *animatedTopView;
    UIView *animatedBackView;
    BOOL animated;
    float currentIndex;
    float upstart;
    float downstart;
    CGRect originalPosition;
    UIImageView *firstPostImage;
    UIView *addPopUpView;
    //UIView *addPopUpViewForNewKidWhenStreamEmpty;

    UIButton *btnFacebook;
    
}


@property (nonatomic) BOOL isScrolledWithAnimation;

@end

@implementation ProfileKidsTOCV2ViewController

@synthesize person;
@synthesize profileImage;
@synthesize lblName, lblGrouping;
@synthesize statusBarHidden;
@synthesize isFromFirstAddedChild;
@synthesize isKidTocView;
@synthesize isFromPinView;
@synthesize profileDetails;
@synthesize kid_klid;
// To avoid the memory leaks declare a global alert
@synthesize globalAlert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View controller Life cycle
#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController setNavigationBarHidden:YES];
    
     sharedInstance = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    photoUtils  = [ProfilePhotoUtils alloc];
    
    upstart = 0;
    downstart = 0;
     animated = FALSE;
    self.isScrolledWithAnimation = false;

    
    [self callProfileDetailsAPI];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //animated top view
    animatedTopView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 220)];
    //top wallpaper
    UIImageView *wallpaperImage = [[UIImageView alloc] init];
    wallpaperImage.contentMode = UIViewContentModeScaleAspectFill;
    wallpaperImage.frame = CGRectMake(0,0,screenWidth,150);
    wallpaperImage.backgroundColor = [UIColor whiteColor];
    [animatedTopView addSubview:wallpaperImage];

    //name
    lblName = [[UILabel alloc] initWithFrame: CGRectMake(20, 55, Devicewidth-20-96.5, 45)];
    lblName.font =[UIFont fontWithName:@"Archer-MediumItalic" size:25];
    [lblName setTextAlignment:NSTextAlignmentCenter];
    lblName.textColor = UIColorFromRGB(0x6fa8dc);
    
    
    
    NSString *displayName;
    
    NSString *parentFname = [self.person valueForKey:@"fname"];
    NSString *parentLname = [self.person valueForKey:@"lname"];

    if (parentFname.length>0 && parentLname.length >0)
    {
        displayName = [NSString stringWithFormat:@"%@ %@",parentFname,parentLname];
    }
    else if(parentFname.length >0)
    {
        displayName = parentFname;
    }
    else if(parentLname.length >0)
    {
        displayName = parentLname;
    }
    else if([[self.person valueForKey:@"nickname"] length] >0)
    {
        displayName = [self.person valueForKey:@"nickname"];
    }
    
  
    lblName.text = displayName;

    [animatedTopView addSubview:lblName];
    
    profileImageBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile_pic_icon.png"]];
    profileImageBackgroundView.frame = CGRectMake(215.5,28.5,92.5,92.5);
    [animatedTopView addSubview:profileImageBackgroundView];
    [profileImageBackgroundView setHidden:TRUE];
    
    //image photo
    profileImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"EmptyProfile.png"]];
    profileImage.frame = CGRectMake(Devicewidth-76.5-20,36.5,76.5,76.5);
    [animatedTopView addSubview:profileImage];
    [self AddPhotoToControl];

    //bar background
    UIView *buttonBar = [[UIView alloc] initWithFrame:CGRectMake(0,130,screenWidth,45)];
    [buttonBar setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
    [animatedTopView addSubview:buttonBar];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1]];
    
      float width = Devicewidth/3.0;
    
    //button1
    UIButton *btnDetail = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDetail addTarget:self action:@selector(detailsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnDetail setImage:[UIImage imageNamed:@"profile_details"] forState:UIControlStateNormal];
    btnDetail.frame = CGRectMake((width-35)/2.0,120,35,35);
    [animatedTopView addSubview:btnDetail];
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 155, width, 15)];
    [detailLabel setText:@"Profile details"];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    detailLabel.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [animatedTopView addSubview:detailLabel];
    
    //button2
    UIButton *btnDocs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDocs addTarget:self action:@selector(documentsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnDocs setImage:[UIImage imageNamed:@"forms.png"] forState:UIControlStateNormal];
    btnDocs.frame = CGRectMake(width + (width-35)/2.0, 120, 35,35);
    [animatedTopView addSubview:btnDocs];
    
    UILabel *docLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, 155, width, 15)];
    [docLabel setText:@"Forms&docs"];
    docLabel.textAlignment = NSTextAlignmentCenter;
    docLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    docLabel.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [animatedTopView addSubview:docLabel];


    //button3
   UIButton *btnOrg = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnOrg addTarget:self action:@selector(organizationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btnOrg setImage:[UIImage imageNamed:@"notes.png"] forState:UIControlStateNormal];
    btnOrg.frame = CGRectMake(2*width+(width-35)/2.0, 120, 35,35);
    [animatedTopView addSubview:btnOrg];
    
    UILabel *schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*width, 155, width, 15)];
    [schoolLabel setText:@"Notes"];
    schoolLabel.textAlignment = NSTextAlignmentCenter;
    schoolLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
    schoolLabel.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [animatedTopView addSubview:schoolLabel];

   float y = 180;
    if(IDIOM == IPAD) {
        
      
        btnDetail.frame = CGRectMake((width-50)/2.0,120,50,50);
        detailLabel.frame = CGRectMake(0, 170, width, 20);
        btnDocs.frame = CGRectMake(width+(width-50)/2.0, 120, 50,50);
        docLabel.frame = CGRectMake(width, 170, width, 20);
        btnOrg.frame = CGRectMake(2*width+(width-50)/2.0, 120, 50,50);
        schoolLabel.frame = CGRectMake(2*width, 170, width, 20);
        
        detailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        docLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        schoolLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
        
        wallpaperImage.frame = CGRectMake(0,0,screenWidth,195);

        y = 198.5;
    }
    
    
    UIImageView *myImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"TopButtonNavBackground.png"]];
    UIView *myUIView = [[UIImageView alloc] initWithFrame :CGRectMake(0,y,Devicewidth,68)];
    [myUIView addSubview: myImageView];
    [animatedTopView addSubview:myUIView];
    
    streamView = [StreamDisplayView alloc];
    streamView.isMainView = NO;
    streamView.canShowSpinner = YES;
    [streamView setDelegate:self];
    streamView.profileID = [self.person objectForKey:@"kid_klid"];
    streamView = [streamView initWithFrame:CGRectMake(0, 200, Devicewidth, Deviceheight-242 - appDelegate.bottomSafeAreaInset)];
    

    
    originalPosition = CGRectMake(0, 200, Devicewidth, Deviceheight-242);
    
    [self.view addSubview:animatedTopView]; //added here for z-index
    
    
   
    UIView *remindersBgView = [[UIView alloc] initWithFrame:CGRectMake(0, y, Devicewidth, 40.0)];
    [remindersBgView setBackgroundColor:[UIColor whiteColor]];
    [animatedTopView addSubview:remindersBgView];
    
    UIImageView *reminderImagevIew = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth/2.0f)-120, 10, 20, 20)];
    [reminderImagevIew setBackgroundColor:[UIColor orangeColor]];
    [reminderImagevIew.layer setCornerRadius:10];
    [reminderImagevIew setClipsToBounds:YES];
    [remindersBgView addSubview:reminderImagevIew];
    
    UIButton *reminderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [reminderBtn setFrame:CGRectMake(reminderImagevIew.frame.origin.x+reminderImagevIew.frame.size.width+3, 10, 78 , 20)];
    [reminderBtn setTitle:@"Reminders" forState:UIControlStateNormal];
    [reminderBtn setTitleColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1] forState:UIControlStateNormal];
    [reminderBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [reminderBtn addTarget:self action:@selector(reminderTapped) forControlEvents:UIControlEventTouchUpInside];
    [remindersBgView addSubview:reminderBtn];

    
    UIImageView *messageImagevIew = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth/2.0f)+20, 10, 20, 20)];
    [messageImagevIew setBackgroundColor:UIColorFromRGB(0x1B7EF9)];
    [messageImagevIew.layer setCornerRadius:10];
    [messageImagevIew setClipsToBounds:YES];
    [remindersBgView addSubview:messageImagevIew];
    
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBtn setFrame:CGRectMake(messageImagevIew.frame.origin.x+messageImagevIew.frame.size.width+1, 10, 78 , 20)];
    [messageBtn setTitle:@"Messages" forState:UIControlStateNormal];
    [messageBtn setTitleColor:[UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1] forState:UIControlStateNormal];
    [messageBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [messageBtn addTarget:self action:@selector(messageTapped) forControlEvents:UIControlEventTouchUpInside];
    [remindersBgView addSubview:messageBtn];

    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake((Devicewidth-0.5f)/2.0f, 10, 0.5f, 20)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [remindersBgView addSubview:lineView];
    
    
    
    
        y += 42.5;
    
    animatedTopView.frame = CGRectMake(0, 0, screenWidth, 220+42.5);

        myUIView.frame = CGRectMake(0,y,Devicewidth,68);

        streamView.frame = CGRectMake(0, 200+42.5+30, Devicewidth, Deviceheight-252-appDelegate.bottomSafeAreaInset);
        streamView.streamTableView.frame = CGRectMake(0, 0, Devicewidth, screenHeight-135- appDelegate.bottomSafeAreaInset);

        originalPosition = CGRectMake(0, 200+42.5+30, Devicewidth, Deviceheight-252);

   
    
    UIButton *btnAddPost = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAddPost addTarget:self action:@selector(addPostButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnAddPost setTitleEdgeInsets:UIEdgeInsetsMake(25.0f, 0.0f, 0.0f, 0.0f)];
    [btnAddPost setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnAddPost.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:16.0f]];
    [btnAddPost setTitle:@"capture a moment, share with parent(s)..." forState:UIControlStateNormal];
    btnAddPost.backgroundColor = [UIColor whiteColor];
    btnAddPost.frame = CGRectMake(0, y, Devicewidth, 50);
    
 
    UIImageView *momentImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth-30)/2, 5, 25, 25)];
    [momentImageView setImage:[UIImage imageNamed:@"add_moment.png"]];
    [btnAddPost addSubview:momentImageView];

    
    UIImageView *lineUnderPostBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, Devicewidth, .5)];
    lineUnderPostBar.backgroundColor = [UIColor colorWithRed:(204/255.f) green:(204/255.f) blue:(204/255.f) alpha:1];
    [btnAddPost addSubview:lineUnderPostBar];
    
    
    
    //[animatedTopView addSubview:btnViewAll];
    //[animatedTopView addSubview:lblViewing];
    [animatedTopView addSubview:lblGrouping];
    [animatedTopView addSubview:btnAddPost];
    
    animatedBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 55)];
    [animatedBackView setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:0]];
    [self.view addSubview:animatedBackView];
    
    //back button
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageNamed:@"back_arrow.png"] forState:UIControlStateNormal];
    btnBack.frame = CGRectMake(10, 25, 40, 40);
    [self.view addSubview:btnBack];
    
    
    profileView = [KidProfileView alloc];
    profileView.person = self.person;
    profileView.parent = self;
    profileView = [profileView initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
    
    if(IDIOM == IPAD) {
        
        
        animatedTopView.frame = CGRectMake(0, 0, screenWidth, y+42.5);
        myUIView.frame = CGRectMake(0,y,Devicewidth,68);
        
        [btnAddPost.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15.0f]];

        streamView.frame = CGRectMake(0, 200+42.5+70, Devicewidth, Deviceheight-252-40);
        
        originalPosition = CGRectMake(0, 200+42.5+70, Devicewidth, Deviceheight-252-40);
        
        [btnAddPost setTitleEdgeInsets:UIEdgeInsetsMake(48.0f, 0.0f, 0.0f, 0.0f)];

        btnAddPost.frame = CGRectMake(0, y, Devicewidth, 70);
        momentImageView.frame = CGRectMake((Devicewidth-50)/2, 0, 50, 50);

        lineUnderPostBar.frame = CGRectMake(0, 70, Devicewidth, .5);

    }

    [self.view addSubview:streamView];

    //[self getSharedUserThenShowPopop];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    sharedInstance.isInKidsTOC = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarHit) name:kStatusBarTappedNotification object:nil];
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        
        [alert show];
    }
    else
    {
        if(streamView.isCommented)
        {
            streamView.isCommented = NO;
            
            [streamView.streamTableView reloadData];
        }
        else
        {
            if(streamView.isEdited)
            {
                streamView.isEdited = NO;
                [streamView.streamTableView reloadData];
            }
            else
            {
                if(!streamView.isAddPostClicked)
                {
                [streamView resetData];
                streamView.timeStamp = @"";
                streamView.etag = @"";
                [streamView performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];
                }
                streamView.isAddPostClicked = NO;
            }
            
        }
    }
    
/*    if(sharedInstance.isPostFromFirstAddedChild)
    {
        sharedInstance.isPostFromFirstAddedChild = NO;
        isFromFirstAddedChild = NO;
        [self performSelector:@selector(getSharedUserThenShowPopop) withObject:nil afterDelay:4.0];
    }
    
    if(sharedInstance.firstKidFirstPostKL_id.length >0 && sharedInstance.isFirstKidFirstPost == YES)
    {
       

        [self performSelector:@selector(displayFirstStoryPopUp) withObject:nil afterDelay:4.0];
    }
    if(sharedInstance.willShowPopUp)
    {
        sharedInstance.willShowPopUp = NO;
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];;
    }
 */
    [self.navigationController setNavigationBarHidden:YES];

    
    //[self getSharedUserThenShowPopop];

}
-(void)viewWillDisappear:(BOOL)animated
{
    isPromptAdded = NO;
    [addPopUpView removeFromSuperview];
    [profileView removeFromSuperview];
    [super viewWillDisappear:YES];
    if(!isKidTocView)
        [self.navigationController setNavigationBarHidden:NO];
    isKidTocView = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
/*    if(sharedInstance.isInstagramShareEnabled && !(sharedInstance.firstKidFirstPostKL_id.length >0 && sharedInstance.isFirstKidFirstPost == YES) && addPopUpView.superview == nil)
    {
        [sharedInstance shareToInstagram];
    }
   */ 
    [self.navigationController setNavigationBarHidden:YES];
    
}
//you have to remove the subview from the base UIApplication when this view disappears
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    // [profileView removeFromSuperview];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    self.globalAlert = nil;
}

-(void)reminderTapped {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    RemindersViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"RemindersViewController"];
    vc.kid_klid = [self.person objectForKey:@"kid_klid"];
    [self.navigationController pushViewController:vc animated:YES];

}
-(void)messageTapped {
    
    NSDictionary *dict = @{@"conversation_klid":@"",
                           @"organization_id":([[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"organization_id"])?[[[SingletonClass sharedInstance] selecteRoom] objectForKey:@"organization_id"]:@"",
                           @"kid_klid":[self.person objectForKey:@"kid_klid"]};

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    MessageDetailViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
    vc.messageDictFromLastPage = [dict mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];
    

    
}
#pragma mark status bar tap
- (void) statusBarHit {
    
    if (self.isScrolledWithAnimation) {
        [self animateTopDown];
        animated = FALSE;
    }

}

- (BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (actionSheet.tag) {
        case 1:
        {
            switch (buttonIndex) {
                case 0:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        imagePicker.delegate = self;
                        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        //imagePicker.allowsEditing = YES;
                        [self presentViewController:imagePicker animated:YES completion:NULL];
                    }
                    else
                    {
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:NO_CAMERA
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        self.globalAlert = alert;
                        [alert show];
                    }
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        //imagePicker.allowsEditing = YES;
                        [self presentViewController:imagePicker animated:YES completion:NULL];
                    }
                    else {
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:NO_PHOTO_LIBRARIES
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        self.globalAlert = alert;
                        [alert show];
                    }
                    break;
                }
                default:
                    break;
                    
            }
    }
            break;
            
        case 2:
        {
            switch (buttonIndex)
            {
                case 0:
                case 1:
                case 2:
                    [self gotoAddpost];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            

            
        default:
            break;
    }
}
#pragma mark- ImagePickerControlle Delegate methods
#pragma mark-
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  /*  [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *imageOrg = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    sharedInstance.whoseProfileId = @"";
    sharedInstance.whoseCategoryId = @"";
    sharedInstance.customCategory = @"";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    DocumentPagesViewController *documentPagesViewController = [storyBoard instantiateViewControllerWithIdentifier:@"DocumentPagesViewController"];
    documentPagesViewController.pickedImage = imageOrg;
    
    [self.navigationController pushViewController:documentPagesViewController animated:YES];
   */
}


-(void)displayPromptForDoneALot:(NSDictionary *)newDic
{
    if(self.navigationController)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
        [addPopUpView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *myWhiteBack = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
        [myWhiteBack setBackgroundColor:[UIColor blackColor]];
        [addPopUpView addSubview:myWhiteBack];
        
        UIView *animateView = [[UIView alloc] initWithFrame:CGRectMake(0,screenHeight,screenWidth,screenHeight)];
        [animateView setBackgroundColor:[UIColor clearColor]];
        animateView.userInteractionEnabled = YES;
        [addPopUpView addSubview:animateView];
        
        //MARK:POP Up image
        UIImageView *popUpContent = [[UIImageView alloc] init];
        [popUpContent setImage:[UIImage imageNamed:@"who_should_see_back.png"]];
        [animateView addSubview:popUpContent];
        
        /* ------------------------ First Line ----------------------------------------- */
        
        //firstLine
        NSString *firstLine = [NSString stringWithFormat:@"%@",[newDic valueForKey:@"firstLine"]];
        
        //NSString *firstLine = @"Sweeet.  You made a post.";
        
        NSString *concatMessageTop = [NSString stringWithFormat:@"%@",firstLine];
        
        NSMutableAttributedString *formattedMessageTop = [KLTextFormatter formatTextString:concatMessageTop];
        
        
        UILabel *lblShareTop = [[UILabel alloc] init];
        [lblShareTop setTextAlignment:NSTextAlignmentCenter];
        lblShareTop.text = concatMessageTop;
        lblShareTop.lineBreakMode = NSLineBreakByWordWrapping;
        lblShareTop.numberOfLines = 2;
        lblShareTop.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        lblShareTop.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:15.0f];
        [popUpContent addSubview:lblShareTop];
        
        lblShareTop.attributedText = formattedMessageTop;
        
        
        // secondLine
        NSString *secondLine = [NSString stringWithFormat:@"%@",[newDic valueForKey:@"secondLine"]];
        /* ------------------------ Second Line ----------------------------------------- */
        //NSString *secondLine = @"And Alicia J can see it.";
        
        NSString *concatMessageBottom = [NSString stringWithFormat:@"%@",secondLine];
        
        NSMutableAttributedString *formattedMessageBottom = [KLTextFormatter formatTextString:concatMessageBottom];
        
        
        UILabel *lblShareBottom = [[UILabel alloc] init];
        [lblShareBottom setTextAlignment:NSTextAlignmentCenter];
        lblShareBottom.text = concatMessageBottom;
        lblShareBottom.lineBreakMode = NSLineBreakByWordWrapping;
        lblShareBottom.numberOfLines = 2;
        lblShareBottom.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
        lblShareBottom.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:15.0f];
        [popUpContent addSubview:lblShareBottom];
        
        lblShareBottom.attributedText = formattedMessageBottom;
        
        /* ------------------------ Spouse ----------------------------------------- */
        //
        UIImageView *btnSpouse = [[UIImageView alloc]init];
        [btnSpouse setImage:[UIImage imageNamed:@"who_should_see_spouse.png"]];
        
        UIButton *spouseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [spouseButton addTarget:self action:@selector(shareWithFamily) forControlEvents:UIControlEventTouchUpInside];
        [animateView addSubview:spouseButton];
        
        [popUpContent addSubview:btnSpouse];
        
        /* ---------------------- Friends ------------------------------------------ */
        
        UIImageView *btnFriends = [[UIImageView alloc]init];
        [btnFriends setImage:[UIImage imageNamed:@"who_should_see_friends.png"]];
        
        UIButton *friendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [friendButton addTarget:self action:@selector(shareWithFriends) forControlEvents:UIControlEventTouchUpInside];
        [animateView addSubview:friendButton];
        
        [popUpContent addSubview:btnFriends];
        
        /* ---------------------------- Facebook---------------------------------------- */
        
        btnFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *facebookImage = [[UIImageView alloc] init];
        
        if (sharedInstance.isFaceBookChecked == YES)
        {
            [sharedInstance setIsFaceBookChecked:NO];
            [facebookImage setImage:[UIImage imageNamed:@"facebook_on@2x.png"]];
            //[btnFacebook setImage:[UIImage imageNamed:@"facebook_on@2x.png"] forState:UIControlStateNormal];
            [btnFacebook setEnabled:NO];
            [btnFacebook setUserInteractionEnabled:NO];
        }
        else
        {
            //[btnFacebook setImage:[UIImage imageNamed:@"facebook_off@2x.png"] forState:UIControlStateNormal];
            [btnFacebook setEnabled:YES];
            [facebookImage setImage:[UIImage imageNamed:@"facebook_off@2x.png"]];
            [btnFacebook setUserInteractionEnabled:YES];
        }
        
        [btnFacebook addTarget:self action:@selector(postToFacebook) forControlEvents:UIControlEventTouchUpInside];
        [addPopUpView addSubview:btnFacebook];
        [animateView addSubview:facebookImage];
        
        /* ------------------------- Instagram --------------------------------- */
        
        UIButton *btnInstagram = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImageView *instagramImage = [[UIImageView alloc] init];
        if (sharedInstance.isInstagramChecked)
        {
            sharedInstance.isInstagramChecked = NO;
            [btnInstagram setEnabled:NO];
            [btnInstagram setUserInteractionEnabled:NO];

            [instagramImage setImage:[UIImage imageNamed:@"instagram_on@2x.png"]];
            //[btnInstagram setImage:[UIImage imageNamed:@"instagram_on@2x.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btnInstagram setEnabled:YES];
            [btnInstagram setUserInteractionEnabled:YES];

            [instagramImage setImage:[UIImage imageNamed:@"instagram_off@2x.png"]];
            //[btnInstagram setImage:[UIImage imageNamed:@"instagram_off@2x.png"] forState:UIControlStateNormal];
        }
        
        [btnInstagram addTarget:self action:@selector(postToInstagram) forControlEvents:UIControlEventTouchUpInside];
        [addPopUpView addSubview:btnInstagram];
        [animateView addSubview:instagramImage];
        
        
        /* ------------------------- Nobody else --------------------------------- */
        
        UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *closeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"who_should_see_nobody_btn@2x.png"]];
        
        [btnClose addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        //[btnClose setImage:[UIImage imageNamed:@"who_should_see_nobody_btn@2x.png"] forState:UIControlStateNormal];
        btnClose.tag = 0;
        [addPopUpView addSubview:btnClose];
        [animateView addSubview:closeImage];
        
        
        if (Deviceheight <568)
        {
            [popUpContent setFrame:CGRectMake(19, screenHeight-446, 283, 378.5)];
            lblShareTop.frame = CGRectMake(0, 8, 283, 65);
            lblShareBottom.frame = CGRectMake(-2, 26, 283, 65);
            btnSpouse.frame = CGRectMake(41.5,142,77,143);
            spouseButton.frame = CGRectMake(60,175,77,143);
            btnFriends.frame = CGRectMake(158,141+3.5,85.5,138.5);
            friendButton.frame = CGRectMake(175,175,88,145);
            btnClose.frame = CGRectMake(114.5,420,91,28.5);
            btnInstagram.frame = CGRectMake(248,360,33,33);
            btnFacebook.frame = CGRectMake(200.5,360,33,33);
            
            closeImage.frame = CGRectMake(114.5,420,91,28.5);
            instagramImage.frame = CGRectMake(248,360,33,33);
            facebookImage.frame = CGRectMake(200.5,360,33,33);
            
            
        }
        else
        {
            btnFacebook.frame = CGRectMake(200.5,426,33,33);
            [popUpContent setFrame:CGRectMake(19, screenHeight-470, 283, 378.5)];
            lblShareTop.frame = CGRectMake(0, 8, 283, 65);
            lblShareBottom.frame = CGRectMake(-2, 26, 283, 65);
            btnSpouse.frame = CGRectMake(41.5,142,77,143);
            spouseButton.frame = CGRectMake(60,238,77,143);
            btnFriends.frame = CGRectMake(158,141+3.5,85.5,138.5);
            friendButton.frame = CGRectMake(175,200,88,145);
            btnClose.frame = CGRectMake(114.5,486.5,91,28.5);
            btnInstagram.frame = CGRectMake(248,426,33,33);
            
            closeImage.frame = CGRectMake(114.5,486.5,91,28.5);
            instagramImage.frame = CGRectMake(248,426,33,33);
            facebookImage.frame = CGRectMake(200.5,426,33,33);
            
            
        }
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];;
        
        myWhiteBack.alpha = 0.0f;
        [UIView animateWithDuration:1.0f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             myWhiteBack.alpha = 0.65f;
                             [animateView setFrame:CGRectMake(0, 0, screenHeight, screenWidth)];
                             
                         }
                         completion:nil];
    }
}

-(void)closeButtonClick:(id)sender
{
    [addPopUpView removeFromSuperview];
    isPromptAdded = NO;
    
    [streamView resetData];
    streamView.timeStamp = @"";
    streamView.etag = @"";
    [streamView performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];
//    if(sharedInstance.isInstagramShareEnabled)
//    {
//        [Flurry logEvent:@"Stream_Post_Social_IG"];
//        [sharedInstance shareToInstagram];
//    }
}

-(void)tabClicked:(id)sender
{
    isPromptAdded = NO;
    [addPopUpView removeFromSuperview];
    [self.tabBarController setSelectedIndex:[sender tag]];
}
//DM: called from the StreamDisplayView delegate
- (void)streamCountReturned:(int)total
{
    firstPostImage.hidden = TRUE;
    streamView.hidden = FALSE;
    //DebugLog(@"%d",total);

    
}

-(void)displayPromptForNewKidWhenStreamDataEmpty
{
    if([self.tabBarController selectedIndex] == 1 && [[self.navigationController viewControllers] lastObject] == self)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        addPopUpView = [[UIView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
        [addPopUpView setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *myWhiteBack = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,screenWidth,screenHeight)];
        [myWhiteBack setBackgroundColor:[UIColor blackColor]];
        [addPopUpView addSubview:myWhiteBack];
        
        //MARK:POP Up image
        UIImageView *popUpContent = [[UIImageView alloc] init];
        [popUpContent setFrame:CGRectMake(19, screenHeight, 283, 377)];
        
        NSString *newKidStreamsEmptyPopupFromServer = [[NSUserDefaults standardUserDefaults] objectForKey:@"NewKidStreamsEmptyPopup"];
        
        if (newKidStreamsEmptyPopupFromServer.length >0)
        {
            
            UIImage *thumb = [photoUtils getImageFromCache:newKidStreamsEmptyPopupFromServer];
            
            if (thumb == nil)
            {
                [popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(queue, ^(void)
                               {
                                   NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:newKidStreamsEmptyPopupFromServer]];
                                   UIImage* image = [[UIImage alloc] initWithData:imageData];
                                   if (image) {
                                       [photoUtils saveRoundedRectImageToCache:newKidStreamsEmptyPopupFromServer :image];
                                   }
                               });
                
            }
            else
            {
                [popUpContent setImage:thumb];
            }
        }
        else
        {
            [popUpContent setImage:[UIImage imageNamed:@"New_Child_Stream_Empty.png"]];
        }
        [addPopUpView addSubview:popUpContent];
        
        // MARK:Top orange pumpkin button
        UIButton *orangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [orangeButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (Deviceheight <568)
        {
            orangeButton.frame = CGRectMake(24,45,272,272);
        }
        else
        {
            orangeButton.frame = CGRectMake(24,screenHeight-433,272,272);
        }
        //[orangeButton setBackgroundColor:[UIColor yellowColor]];
        
        orangeButton.tag = 0;
        [addPopUpView addSubview:orangeButton];
        
        // MARK:Bottom gray button
        UIButton *grayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [grayButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (Deviceheight <568)
        {
            grayButton.frame = CGRectMake(24,330,272,76);
        }
        else
        {
            grayButton.frame = CGRectMake(24,screenHeight-151,272,76);
        }
        //[grayButton setBackgroundColor:[UIColor greenColor]];
        
        grayButton.tag = 1;
        [addPopUpView addSubview:grayButton];
        
        
        [[[[UIApplication sharedApplication] delegate] window] addSubview:addPopUpView];;
        
        myWhiteBack.alpha = 0.0f;
        [UIView animateWithDuration:1.0f
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             myWhiteBack.alpha = 0.65f;
                             if (Deviceheight <568)
                             {
                                 orangeButton.frame = CGRectMake(24,45,272,272);
                                 grayButton.frame = CGRectMake(24,330,272,76);
                                 [popUpContent setFrame:CGRectMake(19, screenHeight-446, 283, 377)];
                             }
                             else
                             {
                                 orangeButton.frame = CGRectMake(24,135,272,272);
                                 grayButton.frame = CGRectMake(24,417,272,76);
                                 [popUpContent setFrame:CGRectMake(19, screenHeight-446, 283, 377)];
                             }
                             
                         }
                         completion:nil];
    }
}

- (void)buttonClicked:(UIButton *)sender
{
    isPromptAdded = NO;
    [addPopUpView removeFromSuperview];
    
    NSMutableArray *oldArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"NewKidStreamEmptyData"] mutableCopy];
    if (oldArray.count >0)
    {
        [oldArray addObject:[NSString stringWithFormat:@"%@",[self.person objectForKey:@"kl_id"]]];

        [[NSUserDefaults standardUserDefaults] setObject:oldArray forKey:@"NewKidStreamEmptyData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSMutableArray *newKidStreamEmpty = [[NSMutableArray alloc]init];
        NSString *newKid_KLID = [NSString stringWithFormat:@"%@",[self.person objectForKey:@"kl_id"]];
        [newKidStreamEmpty addObject:newKid_KLID];
        
        [[NSUserDefaults standardUserDefaults] setObject:newKidStreamEmpty forKey:@"NewKidStreamEmptyData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (sender.tag == 0)
    {
        
        if(IDIOM == IPAD)
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            AddPostViewController *post = [storyBoard instantiateViewControllerWithIdentifier:@"AddPostViewController"];
            post.profileId = [self.person valueForKey:@"kid_klid"];
            if(isFromFirstAddedChild)
            {
                post.isFromFirstAddedChild = YES;
            }
            isKidTocView = YES;
            post.index = 1;
            [self.navigationController pushViewController:post animated:YES];
            
        }
        else {
            
            NSDictionary *dict = @{@"profileId":[self.person valueForKey:@"kid_klid"]};
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ADD_MOMENT" object:dict];
            
        }
  
  
    }
    else if (sender.tag == 1)
    {
        //gray button tapped
    }
}

//DM: called from the StreamDisplayView delegate
- (void)tableScrolled:(float)index
{
    DebugLog(@"Did Scroll in TOC %f", index);
    /*
    if (index > 25 && animated == FALSE)
    {
        animated = TRUE;
        [self animateTop];
    }
     */
    if (index < -20 && animated == TRUE)
    {
        [self animateTopDown];
        animated = FALSE;
        return;
    }
    
    if (index > 0)
    {
        if (currentIndex < index) //going back down
        {
            upstart = 0;
            
            if (downstart == 0)
            {
                downstart = currentIndex;
                //DebugLog(@"downstart = %f", currentIndex);
                //[self animateTopDown];
            }
            else
            {
                float distance = currentIndex - downstart;
                //DebugLog(@"down distance %f", distance);
                if (distance > 20 && animated == FALSE)
                {
                    //DebugLog(@"Make it go up");
                    [self animateTopUp];
                    animated = TRUE;
                }
            }
        }
    
        
        if (currentIndex > index) //going back up
        {
            downstart = 0;
            
            if (upstart == 0)
            {
                upstart = currentIndex;
            }
            else
            {
                float distance = upstart - currentIndex;
                if (distance > 300 && animated == TRUE)
                {
                    //DebugLog(@"Pull it down");
                    //[self animateTopDown];
                    //animated = FALSE;
                }
            }
        }
        
        currentIndex = index;
    }
}

//The event handling method
- (void)animateTopUp
{

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
   // originalPosition = streamView.frame;
    if ( IDIOM == IPAD ) {
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect frame = animatedTopView.frame;
            frame.origin.y = -125-40-20;
            animatedTopView.frame = frame;
            [animatedBackView setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
            
            float y = frame.origin.y+frame.size.height+32.5;
            streamView.frame = CGRectMake(0, y, Devicewidth, Deviceheight-y);
            
            streamView.streamTableView.frame = streamView.bounds;

            
        }
                         completion:^(BOOL finished){
                             
                         }
         ];
        

    
    } else {

    
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            animatedTopView.frame = CGRectMake(0, -125-40, screenWidth, 220+42.5);
            [animatedBackView setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:1]];
            streamView.frame = CGRectMake(0, 220-110, Devicewidth, screenHeight-110 - appDelegate.bottomSafeAreaInset);
            streamView.streamTableView.frame = CGRectMake(0, 0, Devicewidth, streamView.frame.size.height);
            
        }
                         completion:^(BOOL finished){
                             
                         }
         ];
        

    }
    // is set to true to let the status bar animate the topDown if up
    self.isScrolledWithAnimation = true;
    
    
}

- (void)animateTopDown
{

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if ( IDIOM == IPAD ) {

        [UIView animateWithDuration:0.5f
                         animations:^{
                             
                             

                             
                             animatedTopView.frame = CGRectMake(0, 0, screenWidth, 220+42.5+20);
                             [animatedBackView setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:0]];
                             streamView.frame = originalPosition;
                             
                             streamView.streamTableView.frame = streamView.bounds;
                             
                         }
         ];

    
    } else {

        [UIView animateWithDuration:0.5f
                         animations:^{
                             
                             
                             animatedTopView.frame = CGRectMake(0, 0, screenWidth, 220+42.5);
                             [animatedBackView setBackgroundColor:[UIColor colorWithRed:(255/255.f) green:(255/255.f) blue:(255/255.f) alpha:0]];
                             streamView.frame = originalPosition;
                             
                             streamView.streamTableView.frame = CGRectMake(0, 0, Devicewidth, screenHeight-135 - appDelegate.bottomSafeAreaInset);
                             
                         }
         ];

    }
    
    self.isScrolledWithAnimation = false;

    
    
}


#pragma mark - 
#pragma mark Stream Api

- (void)commentClick:(int)index
{
    streamView.commemtIndex = index;
    CommentViewController *commentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentViewController"];
     commentViewController.streamView = streamView;
    commentViewController.selectedStoryDetails = [[NSMutableDictionary alloc]initWithDictionary:[streamView.storiesArray objectAtIndex:index]];
    [self.navigationController pushViewController:commentViewController animated:YES];
   
}
- (void)readArticleClicked:(NSString *)index
{
    //ReadArticleViewController *readArticleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReadArticleViewController"];
    //readArticleViewController.html = index;
    //[self.navigationController pushViewController:readArticleViewController animated:YES];
    
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:index]];
    webViewController.isHide = YES;
    webViewController.title = @"Article";
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HIDE_TABS" object:nil];
    [self.navigationController pushViewController:webViewController animated:YES];
}
- (void)heartersClick:(int)index
{
   streamView.commemtIndex = index;
    streamView.isCommented = YES;
    HeartersViewController *heartersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HeartersViewController"];
    heartersViewController.selectedStoryDetails = [[NSMutableDictionary alloc]initWithDictionary:[streamView.storiesArray objectAtIndex:index]];
    [self.navigationController pushViewController:heartersViewController animated:YES];
 
}
- (void)addHeartClick:(int)index withCommand:(NSString *)commandName
{
    streamView.commemtIndex = index;
    
    NSString *kl_id = [NSString stringWithFormat:@"%@",[[streamView.storiesArray objectAtIndex:index] objectForKey:@"kl_id"]];
    sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    // NSString* postCommand = @"add_heart";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": commandName,
                               };
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,kl_id];
    
    DebugLog(@"URL:%@",urlAsString);
    DebugLog(@"postData:%@",postData);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:postData options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         //DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             NSString *command = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"command"]];
             if ([command isEqualToString:@"add_heart"])
             {
                 NSMutableDictionary *dict = [[streamView.storiesArray objectAtIndex:streamView.commemtIndex] mutableCopy];
                 
                 [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"asset_base_url"]  forKey:@"asset_base_url"];
                 
                 [dict setObject:[NSNumber numberWithBool:NO] forKey:@"local_change"];

                     [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"heart_icon"]  forKey:@"heart_icon"];
                     
                     [dict setObject:[NSNumber numberWithBool:YES]  forKey:@"hearted"];
                 
                 [streamView.storiesArray replaceObjectAtIndex:streamView.commemtIndex withObject:dict];
                 [streamView.streamTableView reloadData];
             }
             else if ([command isEqualToString:@"remove_heart"])
             {
                 NSMutableDictionary *dict = [[streamView.storiesArray objectAtIndex:streamView.commemtIndex] mutableCopy];
                 
                 [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"asset_base_url"]  forKey:@"asset_base_url"];
                 
                 [dict setObject:[NSNumber numberWithBool:NO] forKey:@"local_change"];

                     [dict setObject:[[responseObject objectForKey:@"body"] objectForKey:@"heart_icon"]  forKey:@"heart_icon"];
                     
                     [dict setObject:[NSNumber numberWithBool:NO]  forKey:@"hearted"];
                 
                 [streamView.storiesArray replaceObjectAtIndex:streamView.commemtIndex withObject:dict];
                 [streamView.streamTableView reloadData];
             }
             
         }
         else
         {
             //[HUD hide:YES];
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (error.code == -1005)
         {
             
             [self addHeartClick:index withCommand:commandName];
             return ;
         }
         DebugLog(@"add heart failure");
         DebugLog(@"error:%@",error.description);
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at server while hearting a post"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
         
     }];
    
    [operation start];
}

- (IBAction)backButtonTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)detailsButtonTapped:(id)sender
{
  
    
    [self.view addSubview:profileView]; //to go over nav items
    [self openProfileControl];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"HIDE_TABS" object:nil];

}

- (IBAction)documentsButtonTapped:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    FormsDocsViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FormsDocsViewController"];
    vc.kid_klid = [self.person objectForKey:@"kid_klid"];
    [self.navigationController pushViewController:vc animated:YES];

    
}

-(void)openProfileControl
{
    if(self.profileDetails)
    {
        
        profileView.person = self.profileDetails;
        [profileView openControl];
    }
}

- (void)addPostButtonTapped:(id)sender
{
    {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *singin=[UIAlertAction actionWithTitle:@"Take photo" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                //action on click
                
                [self gotoAddpost];
                
            }];
            
            UIAlertAction *singout=[UIAlertAction actionWithTitle:@"Choose existing" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
                [self gotoAddpost];
                //action on click
                
            }];
            
            UIAlertAction *message=[UIAlertAction actionWithTitle:@"Text only" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
                [self gotoAddpost];
                //action on click
                
            }];
            
            
            UIAlertAction *cancel_action=[UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertController addAction:singin];
            [alertController addAction:singout];
            [alertController addAction:message];
            [alertController addAction:cancel_action];
            
            
            // Remove arrow from action sheet.
            [alertController.popoverPresentationController setPermittedArrowDirections:0];
            //For set action sheet to middle of view.
            CGRect rect = self.view.frame;
            rect.origin.x = self.view.frame.size.width / 20;
            rect.origin.y = self.view.frame.size.height / 20;
            alertController.popoverPresentationController.sourceView = self.view;
            alertController.popoverPresentationController.sourceRect = rect;
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        else {
            
            [self gotoAddpost];
            
        }
        
        
    }
  
}
-(void)gotoAddpost {
    
    if(IDIOM == IPAD)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddPostViewController *post = [storyBoard instantiateViewControllerWithIdentifier:@"AddPostViewController"];
        post.profileId = [self.person valueForKey:@"kid_klid"];
        if(isFromFirstAddedChild)
        {
            post.isFromFirstAddedChild = YES;
        }
        isKidTocView = YES;
        post.index = 1;
        [self.navigationController pushViewController:post animated:YES];
        
    }
    else {

        NSDictionary *dict = @{@"profileId":[self.person valueForKey:@"kid_klid"]};
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ADD_MOMENT" object:dict];
        
        streamView.isAddPostClicked = YES;

    }
    

    

}
-(void)AddPhotoToControl
{
    NSString *url = [self.person valueForKey:@"photograph_url"];
    
    if (url.length > 0)
    {
        
       UIImage *thumb = [photoUtils getImageFromCache:url];
        
        if (thumb == nil)
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void)
                       {
                           NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                           
                           UIImage* image = [[UIImage alloc] initWithData:imageData];
                           if (image) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [photoUtils saveImageToCache:url :image];
                                   profileImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(86.5, 86.5)] withRadious:0];
                                   [profileImageBackgroundView setHidden:FALSE];
                               });
                           }
                       });
        }
        else
        {
            profileImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:thumb scaledToSize:CGSizeMake(86.5, 86.5)] withRadious:0];
            [profileImageBackgroundView setHidden:FALSE];
        }
        
    }
    else
    {
        profileImage.image = [UIImage imageNamed:@"EmptyProfile.png"];

        NSMutableString *nicknameInitial = [[NSMutableString alloc] init];
        //get initials
        NSString *fname = [self.person valueForKey:@"fname"];
        NSString *lname = [self.person valueForKey:@"fname"];
        if(fname.length >0 && lname.length >0)
        {
            [nicknameInitial appendString:[[fname substringToIndex:1] uppercaseString]];
            [nicknameInitial appendString:[[lname substringToIndex:1] uppercaseString]];
        }
        else if (fname.length >0) {
         
            [nicknameInitial appendString:[[fname substringToIndex:1] uppercaseString]];

        }
        else if (lname.length >0) {
            
            [nicknameInitial appendString:[[lname substringToIndex:1] uppercaseString]];
            
        }
        else if ([self.person valueForKey:@"nickname"] >0) {
            
            [nicknameInitial appendString:[[[self.person valueForKey:@"nickname"] substringToIndex:1] uppercaseString]];
            
        }

        
        UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 56.5, 56.5)];
        initial.text = nicknameInitial;
        initial.font =[UIFont fontWithName:@"Archer-Bold" size:24]; //Archer-Bold
        initial.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        
        initial.textAlignment = NSTextAlignmentCenter;
        [profileImage addSubview:initial];
        
        // DebugLog(@"Row Initial %@", initial.text);
    }
    
}

-(void)organizationButtonClicked:(id)sender
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    NotesListViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NotesListViewController"];
    vc.kid_klid = [self.person objectForKey:@"kid_klid"];
    [self.navigationController pushViewController:vc animated:YES];
    

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//To remove delegate warnings
- (void)fetchinStoriesFailedWithError:(NSError *)error
{
}

-(void)showVerifiedPhone
{
}

- (void)receivedStories:(NSArray *)completeRegistration
{
}

-(void)postToFacebook
{
 
    /*// Here we are checking the post is Say something or not
    if([[sharedInstance.lastPost objectForKey:@"imageURL"] isEqualToString:@"saysomething"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:FACEBOOK_ALERT_TITLE_FOR_SAYSOMETHING_FIRST_POST
                                                       message:FACEBOOK_ALERT_BODY_FOR_SAYSOMETHING_FIRST_POST
                                                      delegate:nil cancelButtonTitle:FACEBOOK_ALERT_OK
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    [btnFacebook setImage:[UIImage imageNamed:@"facebook_on@2x.png"] forState:UIControlStateNormal];
    
    [addPopUpView removeFromSuperview];
    
    if(sharedInstance.lastPost != nil)
    {
        NSDictionary *currentMilestone = sharedInstance.lastPost;
        NSString *imageURL = [currentMilestone objectForKey:@"imageURL"];
        
        
        /// If title is there then consider as milestone else moment
        if([[currentMilestone objectForKey:@"title"] length] > 0)
        {
            FacebookShareController *fbc = [[FacebookShareController alloc] init];
            
            NSString *description = [currentMilestone objectForKey:@"additional_text"];
            
            if (![description isEqualToString:@""])
            {
                description = [NSString stringWithFormat:@"%@: %@",
                               [currentMilestone objectForKey:@"title"],
                               [currentMilestone objectForKey:@"additional_text"]];
            }
            else
            {
                description = [currentMilestone objectForKey:@"title"];
            }
            
            [fbc PostToFacebookViaAPI:imageURL:@"":description:@"milestone"];
        }
        else
        {
            FacebookShareController *fbc = [[FacebookShareController alloc] init];
            NSString *description = [currentMilestone objectForKey:@"otherDescription"];
            
            [fbc PostToFacebookViaAPI:imageURL:@"":description:@"moment"];
        }
    }
    
     */

    
}

-(void)postToInstagram
{
    // Here we are checking the post is Say something or not
    if([[sharedInstance.lastPost objectForKey:@"imageURL"] isEqualToString:@"saysomething"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:INSTAGRAM_ALERT_TITLE_FOR_SAYSOMETHING_FIRST_POST
                                                       message:INSTAGRAM_ALERT_BODY_FOR_SAYSOMETHING_FIRST_POST
                                                      delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    if ([[sharedInstance.lastPost valueForKey:@"imageURL"] length] >0)
    {
        [addPopUpView removeFromSuperview];
        [sharedInstance shareToInstagram];
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:INSTAGRAM_ALERT_TITLE
                                                       message:INSTAGRAM_ALERT_BODY_SHARE
                                                      delegate:nil cancelButtonTitle:INSTAGRAM_ALERT_OK
                              
                                             otherButtonTitles:nil,nil];
        self.globalAlert = alert;
        
        [alert show];
    }
}



-(void)callProfileDetailsAPI {
    
    
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"kid_info";
    NSDictionary *body = @{
                           @"kid_klid":[self.person objectForKey:@"kid_klid"]
                           };
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": body};
    NSString *urlAsString = [NSString stringWithFormat:@"%@teachers",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        if(weakSelf){
            weakSelf.profileDetails = [[json objectForKey:@"response"] objectForKey:@"body"];
        }
    } failure:^(NSDictionary *json) {
        
    }];
    

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

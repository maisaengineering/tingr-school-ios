//
//  MyClassViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/7/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MyClassViewController.h"
#import "ProfilePhotoUtils.h"
#import "AlertUtils.h"
#import "ProfileDateUtils.h"
#import "UITableViewCell+KeepSubviewBackground.h"
#import "ProfileKidsTOCV2ViewController.h"
#import "AddPostViewController.h"
#import "MessageToParentViewController.h"
#define KParentImageViewTag 201
#define KParentFnameLblTag 202
#define KParentLnameLblTag 203
#define KParentNameLblTag 204
#define KParentDetailsLblTag 205
#define KKidFnameViewTag 206
#define KMessageLblTag 207
#define KRemindersLblTag 208
#define KIconTag 209
#define KLastSignTag 210
#define KMessageBackImageTag 211
#define KRemindersBackIMageTag 212



@interface MyClassViewController ()
{
    UIView *addButtonsView;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *photoDateUtils;

    int selectedIndex;
    
    UIRefreshControl *refreshControl;
    BOOL plusButtonTapped;
}
@end

@implementation MyClassViewController
@synthesize appDelegate;
@synthesize schoolNameScrollView;
@synthesize pageControl;
@synthesize kidsArray;
@synthesize tableViewProfile;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    sharedInstance = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    photoDateUtils = [ProfileDateUtils alloc];
    
    
    [self.navigationController setNavigationBarHidden:YES];
    
    addButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, Devicewidth, 60)];
    [addButtonsView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:addButtonsView];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(5, 7, 49, 49)];
    [moreButton addTarget:self action:@selector(menuTapped) forControlEvents:UIControlEventTouchUpInside];
    [moreButton setTag:2];
    [moreButton setImage:[UIImage imageNamed:@"menu-button.png"] forState:UIControlStateNormal];
    [addButtonsView addSubview:moreButton];

    UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [plusButton setFrame:CGRectMake(Devicewidth-49, 7, 49, 49)];
    [plusButton addTarget:self action:@selector(plusTapped) forControlEvents:UIControlEventTouchUpInside];
    [plusButton setImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [addButtonsView addSubview:plusButton];

    
    UIImageView *lineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_icon.png"]];
    [lineImage setFrame:CGRectMake(0, 80, Devicewidth, 1)];
    [self.view addSubview:lineImage];
    
    schoolNameScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(55, 0, Devicewidth-110, 45)];
    [schoolNameScrollView setPagingEnabled:YES];
    schoolNameScrollView.showsHorizontalScrollIndicator = NO;
    schoolNameScrollView.delegate = self;
    [addButtonsView addSubview:schoolNameScrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(70, 45, Devicewidth-140, 10);
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = UIColorFromRGB(0x6fa8dc);
    pageControl.transform = CGAffineTransformMakeScale(0.7, 0.7);
    
    [addButtonsView addSubview:self.pageControl];
    
    
    
    if(sharedInstance.selecteRoom.count == 0 && sharedModel.userProfile.rooms.count > 0)
    {
        
        sharedInstance.selecteRoom = [sharedModel.userProfile.rooms objectAtIndex:0];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:sharedInstance.selecteRoom forKey:@"selecteRoom"];
        
    }
    
    
    [self showSchollName];

    tableViewProfile = [[UITableView alloc] initWithFrame:CGRectMake(0, 81, Devicewidth, Deviceheight-81)];
    tableViewProfile.delegate = self;
    tableViewProfile.dataSource = self;
    [self.view addSubview:tableViewProfile];
    tableViewProfile.tableFooterView = [[UIView alloc] init];
    
    refreshControl = [[UIRefreshControl alloc] init];
    // refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    refreshControl.backgroundColor= [UIColor colorWithRed:(229/255.f) green:(225/255.f) blue:(221/255.f) alpha:1];
    
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [tableViewProfile addSubview:refreshControl];

    [[SingletonClass sharedInstance] setPlusButtonTapped:NO];


    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidOpen)
                                                 name:@"SlideNavigationControllerDidOpen"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidClose)
                                                 name:@"SlideNavigationControllerDidClose"
                                               object:nil];
    
    
    
    [self.navigationController setNavigationBarHidden:YES];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        
        [alert show];
    }
    else
    {
        if(!sharedInstance.plusButtonTapped)
        {
            [self callKidsAPI];
        }

    }

    
    [super viewWillAppear: YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SlideNavigationControllerDidClose" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SlideNavigationControllerDidOpen" object:nil];
}
-(void)showSchollName {
    
    
    NSArray *schoolDetailsArray =  sharedModel.userProfile.rooms;
    
    //schoolDetailsArray =nil;
    
    NSArray *subViewArray = [schoolNameScrollView subviews];
    for (id obj in subViewArray)
    {
        [obj removeFromSuperview];
    }
    
    
    schoolNameScrollView.contentSize = CGSizeMake(schoolNameScrollView.frame.size.width*schoolDetailsArray.count, schoolNameScrollView.frame.size.height);
    for(int i=0; i<schoolDetailsArray.count;i++)
    {
        NSDictionary *schoolDict  = schoolDetailsArray[i];
        UILabel *nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(i*schoolNameScrollView.frame.size.width, 0, schoolNameScrollView.frame.size.width, schoolNameScrollView.frame.size.height)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.numberOfLines = 2;
        nameLabel.text = [schoolDict objectForKey:@"session_name"];
        nameLabel.textColor = UIColorFromRGB(0x6fa8dc);
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        [schoolNameScrollView addSubview:nameLabel];
        
    }
    
    if(schoolDetailsArray.count >1) {
        
        pageControl.numberOfPages = schoolDetailsArray.count;
        pageControl.currentPage = 0;
        pageControl.hidden = NO;
    }
    else {
        
        
        pageControl.hidden = YES;
    }
    
    if(schoolDetailsArray.count == 0)
    {
        // [streamView setHidden:YES];
        // [self showEmptyContentMessageView];
        
        UILabel *nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, schoolNameScrollView.frame.size.width, 45)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = @"TingrSCHOOL";
        nameLabel.textColor = UIColorFromRGB(0x6fa8dc);
        nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        [schoolNameScrollView addSubview:nameLabel];
        
    }
    
    if(sharedInstance.selecteRoom != nil && sharedInstance.selecteRoom.count > 0)
    {
        pageControl.currentPage = [sharedModel.userProfile.rooms indexOfObject:sharedInstance.selecteRoom];
        CGPoint offset = self.schoolNameScrollView.contentOffset;
        offset.x = schoolNameScrollView.frame.size.width*pageControl.currentPage;
        self.schoolNameScrollView.contentOffset = offset;
        
    }
    else {
        
        if(sharedModel.userProfile.rooms.count > 0)
        {
            
            sharedInstance.selecteRoom = [sharedModel.userProfile.rooms objectAtIndex:0];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:sharedInstance.selecteRoom forKey:@"selecteRoom"];
            
        }
        
        
    }
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if(scrollView == schoolNameScrollView)
    {
        
        CGFloat pageWidth = self.schoolNameScrollView.frame.size.width;
        float fractionalPage = self.schoolNameScrollView.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        self.pageControl.currentPage = page;
        
        NSDictionary *dict = [sharedModel.userProfile.rooms objectAtIndex:page];
        if(![dict isEqualToDictionary:sharedInstance.selecteRoom])
        {
            
            sharedInstance.selecteRoom = [sharedModel.userProfile.rooms objectAtIndex:page];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:sharedInstance.selecteRoom forKey:@"selecteRoom"];
            [self callKidsAPI];
            
        }
    }
}


-(void)handleRefresh:(id)sender
{

    [self callKidsAPI];
}

-(void)menuTapped {
    
    [sharedInstance getProfileDetails];
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
    
}
-(void)plusTapped {
    
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
-(void)menuDidOpen
{
    
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)menuDidClose
{
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


-(void)callKidsAPI {
    
    if(![refreshControl isRefreshing])
        [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"managed_kids";
    NSDictionary *body = @{
                           @"session_id":[sharedInstance.selecteRoom objectForKey:@"session_id"],
                           @"season_id":[sharedInstance.selecteRoom objectForKey:@"season_id"]
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
            
            [refreshControl endRefreshing];
            [weakSelf recieviedKids:[[json objectForKey:@"response"] objectForKey:@"body"]];

        }
        [Spinner showIndicator:NO];
        
    } failure:^(NSDictionary *json) {
        
        if(weakSelf){
            [refreshControl endRefreshing];
        }
     //   [AlertUtils errorAlert];
        [Spinner showIndicator:NO];
    }];

}
-(void)recieviedKids:(NSDictionary *)details {
    
    kidsArray = [[details objectForKey:@"managed_kids"] mutableCopy];
    
    sharedInstance.profileKids = [[details objectForKey:@"managed_kids"] mutableCopy];
    [tableViewProfile reloadData];
}

-(void)gotoAddpost {
    
    if(IDIOM == IPAD)
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        AddPostViewController *post = [storyBoard instantiateViewControllerWithIdentifier:@"AddPostViewController"];
        post.index = 1;
        
        [self.navigationController pushViewController:post animated:YES];

    }
    else {
        NSDictionary *dict = @{};
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ADD_MOMENT" object:dict];

    }
    


}
#pragma mark -
#pragma mark Tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kidsArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSDictionary *dict = kidsArray[indexPath.row];
    if([[dict objectForKey:@"in_or_out_time"] length] >0 )
        return 85;
    else
        return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"ParentProfileCell"];
    
    UIImageView *parentThumb;
    UIImageView *icon_Profile;
    UILabel *FInitial;
    UILabel *LInitial;
    
    UILabel *parentNameLabel;
    UILabel *parentDetailLabel;

    UILabel *messageLabel;
    UILabel *reminderlLabel;
    UILabel *lastSignLabel;

    UIImageView *messageBackImage;
    UIImageView *reminderBackImage;
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ParentProfileCell"];
      //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //if first row then add background
        parentThumb = [[UIImageView alloc]initWithFrame:CGRectMake(10,11, 43, 43)];
        
        //Create the image so I can move it around
        //parentThumb.image=[UIImage imageNamed:@"EmptyProfile.png"];
        parentThumb.tag = KParentImageViewTag;
        [cell.contentView addSubview:parentThumb];
        
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 0.5; //seconds
        [cell.contentView addGestureRecognizer:lpgr];

        
        int labelY = 17;
        
        FInitial = [[UILabel alloc] initWithFrame:CGRectMake(11, labelY, 30, 30)];
        FInitial.font =[UIFont fontWithName:@"Archer-Bold" size:20]; //Archer-Bold
        FInitial.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        FInitial.textAlignment = NSTextAlignmentCenter;
        FInitial.tag = KParentFnameLblTag;
        [cell.contentView addSubview:FInitial];
        [FInitial setHidden:YES];
        
        LInitial = [[UILabel alloc] initWithFrame:CGRectMake(24, labelY, 30, 30)];
        LInitial.font =[UIFont fontWithName:@"Archer-Light" size:20]; //Archer-Bold
        LInitial.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        LInitial.textAlignment = NSTextAlignmentCenter;
        LInitial.tag = KParentLnameLblTag;
        [cell.contentView addSubview:LInitial];
        [LInitial setHidden:YES];
        
        parentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 6, Devicewidth-65-20-28, 40)];
        parentNameLabel.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]; //Archer-Bold
        parentNameLabel.text  =  @"Me";
        parentNameLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        parentNameLabel.tag = KParentNameLblTag;
        [cell.contentView addSubview:parentNameLabel];
        
        parentDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 24, 215, 40)];
        parentDetailLabel.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:16]; //Archer-Bold
        parentDetailLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        parentDetailLabel.backgroundColor = [UIColor clearColor];
        [parentDetailLabel setAdjustsFontSizeToFitWidth:YES];
        parentDetailLabel.tag = KParentDetailsLblTag;
        [cell.contentView addSubview:parentDetailLabel];
        
        icon_Profile = [[UIImageView alloc] initWithFrame:CGRectMake(Devicewidth-28-20, 22, 28.5f, 21)];
        [icon_Profile setImage:[UIImage imageNamed:@"icon-profil.png"]];
        icon_Profile.tag = KIconTag;
        [cell.contentView addSubview:icon_Profile];
        
        messageBackImage = [[UIImageView alloc] init];
        messageBackImage.tag = KMessageBackImageTag;
        messageBackImage.backgroundColor = UIColorFromRGB(0x1B7EF9);
        messageBackImage.layer.cornerRadius = 10;
        [cell.contentView addSubview:messageBackImage];
        
        reminderBackImage = [[UIImageView alloc] init];
        reminderBackImage.tag = KRemindersBackIMageTag;
        reminderBackImage.backgroundColor = [UIColor orangeColor];
        reminderBackImage.layer.cornerRadius = 10;
        [cell.contentView addSubview:reminderBackImage];

        
        messageLabel = [[UILabel alloc] init];
        messageLabel.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:12]; //Archer-Bold
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.tag = KMessageLblTag;
        [cell.contentView addSubview:messageLabel];

        reminderlLabel = [[UILabel alloc] init];
        reminderlLabel.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:12]; //Archer-Bold
        reminderlLabel.backgroundColor = [UIColor clearColor];
        reminderlLabel.textAlignment = NSTextAlignmentCenter;
        reminderlLabel.textColor = [UIColor whiteColor];
        reminderlLabel.tag = KRemindersLblTag;
        [cell.contentView addSubview:reminderlLabel];
        
        lastSignLabel = [[UILabel alloc] init];
        lastSignLabel.font =[UIFont fontWithName:@"HelveticaNeue" size:14]; //Archer-Bold
        lastSignLabel.backgroundColor = UIColorFromRGB(0xADDFAD);
        lastSignLabel.layer.cornerRadius = 10;
        lastSignLabel.clipsToBounds = YES;

        lastSignLabel.textAlignment = NSTextAlignmentCenter;
        lastSignLabel.textColor = [UIColor darkGrayColor];
        lastSignLabel.tag = KLastSignTag;
        [cell.contentView addSubview:lastSignLabel];



        
    }
    else
    {
        parentThumb = (UIImageView *)[cell.contentView viewWithTag:KParentImageViewTag];
        reminderBackImage = (UIImageView *)[cell.contentView viewWithTag:KRemindersBackIMageTag];
        messageBackImage = (UIImageView *)[cell.contentView viewWithTag:KMessageBackImageTag];
        FInitial = (UILabel *)[cell.contentView viewWithTag:KParentFnameLblTag];
        LInitial = (UILabel *)[cell.contentView viewWithTag:KParentLnameLblTag];
        parentNameLabel = (UILabel *)[cell.contentView viewWithTag:KParentNameLblTag];
        reminderlLabel = (UILabel *)[cell.contentView viewWithTag:KRemindersLblTag];
        messageLabel = (UILabel *)[cell.contentView viewWithTag:KMessageLblTag];
        icon_Profile = (UIImageView *)[cell.contentView viewWithTag:KIconTag];
        lastSignLabel = (UILabel *)[cell.contentView viewWithTag:KLastSignTag];
        parentDetailLabel = (UILabel *)[cell.contentView viewWithTag:KParentDetailsLblTag];
        parentNameLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        parentDetailLabel.textColor = [UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1];
        parentNameLabel.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        parentDetailLabel.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:16]; //Archer-Bold
    }
    
        NSString *parentFname = [[kidsArray objectAtIndex:indexPath.row] valueForKey:@"fname"];
        NSString *parentLname = [[kidsArray objectAtIndex:indexPath.row] valueForKey:@"lname"];
#pragma mark parent pic
        
        UIImageView *profileImage = parentThumb;
        
        __weak UIImageView *weakSelf = profileImage;
        NSString *url = [[kidsArray objectAtIndex:indexPath.row]valueForKey:@"photograph_url"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            [FInitial setHidden:YES];
            
            [LInitial setHidden:YES];
            
            
            [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"EmptyProfile.png"] scaledToSize:CGSizeMake(43,43)] withRadious:0] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(43, 43)] withRadious:0];
                 
             }
                                         failure:nil];
        }
        else
        {
            profileImage.image = [UIImage imageNamed:@"EmptyProfile.png"];
            
            NSString *parentFnameInitial= @"";
            NSString *parentLnameInitial = @"";
            
            if(parentFname.length >0)
                parentFnameInitial = [[parentFname substringToIndex:1] uppercaseString];
            if(parentLname.length>0)
                parentLnameInitial = [[parentLname substringToIndex:1] uppercaseString];
            FInitial.text = parentFnameInitial;
            LInitial.text = parentLnameInitial;
            [FInitial setHidden:NO];
            [LInitial setHidden:NO];
        }
        
        
        
        NSString *displayName;
        
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
    else if([[[kidsArray objectAtIndex:indexPath.row] valueForKey:@"nickname"] length] >0)
    {
        displayName = [[kidsArray objectAtIndex:indexPath.row] valueForKey:@"nickname"];
    }
        
        
            parentNameLabel.text  = displayName;
    
    parentDetailLabel.text = [NSString stringWithFormat:@"%@ old",[[kidsArray objectAtIndex:indexPath.row] valueForKey:@"age"]];

    long int messageCount = [[[kidsArray objectAtIndex:indexPath.row] objectForKey:@"messages_count"] integerValue];
    long int remindersCount = [[[kidsArray objectAtIndex:indexPath.row] objectForKey:@"reminders_count"] integerValue];
    if( messageCount > 0 && remindersCount >0) {
        
        icon_Profile.frame = CGRectMake(Devicewidth-28.5-20, 12, 28.5f, 21);
        messageLabel.frame = CGRectMake(Devicewidth-12-20, 35.5f, 20, 20);
        reminderlLabel.frame = CGRectMake(Devicewidth-34-20, 35.5f, 20, 20);
        reminderBackImage.frame = reminderlLabel.frame;
        messageBackImage.frame = messageLabel.frame;
        messageLabel.hidden = NO;
        reminderlLabel.hidden = NO;
        messageBackImage.hidden = NO;
        reminderBackImage.hidden = NO;
        messageLabel.text = [NSString stringWithFormat:@"%li",messageCount];
        reminderlLabel.text = [NSString stringWithFormat:@"%li",remindersCount];
        
        
    }
    else if(remindersCount > 0 ){
        
        icon_Profile.frame = CGRectMake(Devicewidth-28.5-20, 12, 28.5f, 21);
        reminderlLabel.frame = CGRectMake(Devicewidth-23-20, 35.5f, 20, 20);
        reminderBackImage.frame = reminderlLabel.frame;
        messageBackImage.hidden = YES;
        reminderBackImage.hidden = NO;
        messageLabel.hidden = YES;
        reminderlLabel.hidden = NO;
        reminderlLabel.text = [NSString stringWithFormat:@"%li",remindersCount];
    }
    else if(messageCount > 0 ) {
        
        icon_Profile.frame = CGRectMake(Devicewidth-28.5-20, 12, 28.5f, 21);
        messageLabel.frame = CGRectMake(Devicewidth-23-20, 35.5f, 20, 20);
        messageBackImage.frame = messageLabel.frame;
        messageLabel.hidden = NO;
        reminderlLabel.hidden = YES;
        messageBackImage.hidden = NO;
        reminderBackImage.hidden = YES;
        messageLabel.text = [NSString stringWithFormat:@"%li",messageCount];
    }
    else {
        
        icon_Profile.frame = CGRectMake(Devicewidth-28.5-20, 22, 28.5f, 21);
        messageLabel.hidden = YES;
        reminderlLabel.hidden = YES;
        messageBackImage.hidden = YES;
        reminderBackImage.hidden = YES;
    }
    if([[[kidsArray objectAtIndex:indexPath.row] objectForKey:@"in_or_out_time"] length] >0) {
        
        lastSignLabel.text = [[kidsArray objectAtIndex:indexPath.row] objectForKey:@"in_or_out_time"];
        lastSignLabel.hidden = NO;
        
        lastSignLabel.text = [[kidsArray objectAtIndex:indexPath.row] objectForKey:@"in_or_out_time"];
        
        CGSize size = [lastSignLabel sizeThatFits:CGSizeMake(Devicewidth, 20)];
        
        lastSignLabel.frame = CGRectMake((Devicewidth - size.width - 10)/2, 60, size.width + 10, 20);
    }
    else {
        lastSignLabel.hidden  = YES;
    }
   
    cell.keepSubviewBackground = YES;

    
    
    return cell;
}

-(NSString *)getTodaysDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}
//Change the Height of the Cell [Default is 44]:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        NSMutableDictionary *kid =  [kidsArray objectAtIndex:indexPath.row];
   
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        ProfileKidsTOCV2ViewController *profileKidsTOCV2ViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ProfileKidsTOCV2ViewController"];
        
        profileKidsTOCV2ViewController.person = [kid mutableCopy];
        
        //[self performSegueWithIdentifier: @"ProfileKidTOCSegue" sender: self];
        [self.navigationController pushViewController:profileKidsTOCV2ViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateEnded) {
    
        

        
    } else if (longPress.state == UIGestureRecognizerStateBegan) {

        UITableViewCell *cell = (UITableViewCell *)[longPress.view superview];
        NSIndexPath *indexPath = [tableViewProfile indexPathForCell:cell];
        selectedIndex = (int)indexPath.row;
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *singin=[UIAlertAction actionWithTitle:@"Sign-in" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                //action on click
                
                [self callSign:@"Sign-in"];
                
            }];
            
            UIAlertAction *singout=[UIAlertAction actionWithTitle:@"Sign-out" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
                [self callSign:@"Sign-out"];
                //action on click
                
            }];

            UIAlertAction *message=[UIAlertAction actionWithTitle:@"Message to Parent" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
                [self messageToParent];
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
            
            UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                                  @"Sign-in", @"Sign-out",@"Message to Parent", nil];
            addImageActionSheet.tag = 1;
            [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

            
        }
    }
    


    

    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    [self callSign:@"Sign-in"];
                    break;
                }
                case 1:
                {
                    [self callSign:@"Sign-out"];
                    break;
                }
                case 2:
                {
                    [self messageToParent];
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
-(void)callSign:(NSString *)option {
    
    [Spinner showIndicator:YES];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSDictionary *dict = [kidsArray objectAtIndex:selectedIndex];
    NSString *command = @"signin_signout";
    NSDictionary *body = @{
                           @"session_id":[sharedInstance.selecteRoom objectForKey:@"session_id"],
                           @"season_id":[sharedInstance.selecteRoom objectForKey:@"season_id"],
                           @"kid_klid":[dict objectForKey:@"kid_klid"],
                           @"option":option
                           };
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": body};
    NSString *urlAsString = [NSString stringWithFormat:@"%@attendances",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    __weak __typeof(self)weakSelf = self;
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [weakSelf signSuccessful:[[json objectForKey:@"response"] objectForKey:@"body"]];
        [Spinner showIndicator:NO];
        
    } failure:^(NSDictionary *json) {
       // [AlertUtils errorAlert];
        [Spinner showIndicator:NO];
    }];

}
-(void)signSuccessful:(NSDictionary *)messageDict {
    
    if([[messageDict objectForKey:@"text"] length] >0)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL"
                                                   message:[messageDict objectForKey:@"text"]
                                                  delegate:self cancelButtonTitle:@"Ok"
                          
                                         otherButtonTitles:nil,nil];
    
        [alert show];
        
    }

    NSMutableDictionary *kidDict = [kidsArray[selectedIndex] mutableCopy];
    [kidDict setObject:[messageDict objectForKey:@"in_or_out_time"] forKey:@"in_or_out_time"];
    [kidsArray replaceObjectAtIndex:selectedIndex withObject:kidDict];
    [tableViewProfile reloadData];
}
-(void)messageToParent {
    
    NSMutableDictionary *kidDict = [kidsArray[selectedIndex] mutableCopy];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    MessageToParentViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MessageToParentViewController"];
    vc.kid_klid = [kidDict objectForKey:@"kid_klid"];
    [self.navigationController pushViewController:vc animated:YES];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

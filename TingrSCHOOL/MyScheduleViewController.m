//
//  MyScheduleViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/6/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MyScheduleViewController.h"
#import "ProfilePhotoUtils.h"
#import "EventsView.h"
#import "RemindersView.h"
#import "MessagesView.h"
#import "LSLDatePickerDialog.h"
#import "MessageDetailViewController.h"
@interface MyScheduleViewController ()<MessagesViewDelegate>
{
    UIView *addButtonsView;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    
    ProfilePhotoUtils *photoUtils;
    
    EventsView *eventsView;
    RemindersView *remindersView;
    MessagesView *messagesView;
}

@end

@implementation MyScheduleViewController
@synthesize appDelegate;
@synthesize schoolNameScrollView;
@synthesize pageControl;
@synthesize dateButton;
@synthesize selectedDate;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    sharedInstance = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];

    
    
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
    [self createView];
    
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
      [super viewWillAppear: YES];
    
    [self callEventAPI];
    
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
            [self callEventAPI];
        }
    }
}

-(void)createView {
    
    dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dateButton setFrame:CGRectMake(0, 80, Devicewidth, 40)];
    [dateButton setTitleColor:UIColorFromRGB(0x83C053) forState:UIControlStateNormal];
    [dateButton addTarget:self action:@selector(dateTapped) forControlEvents:UIControlEventTouchUpInside];
    
    NSDate *date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    selectedDate = [dateFormatter stringFromDate:date];
    dateFormatter.dateFormat = @"EEEE, MMMM dd";
    [dateButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    if ( IDIOM == IPAD ) {
        [dateButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
    }
    [dateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
    [self.view addSubview:dateButton];
    
    UIImageView *lineImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_icon.png"]];
    [lineImage setFrame:CGRectMake(0, dateButton.frame.origin.y+dateButton.frame.size.height-0.7, Devicewidth, 0.7f)];
    [self.view addSubview:lineImage];

    
    float remainingHeight = Deviceheight - 80 - 40;
    
    float eventHeight  = remainingHeight * 0.40;
    
    eventsView = [[EventsView alloc] initWithFrame:CGRectMake(0, lineImage.frame.origin.y+lineImage.frame.size.height, Devicewidth , eventHeight)];
    [self.view addSubview:eventsView];
    
    
    float reminderHeight  = remainingHeight * 0.25;
    
    remindersView = [[RemindersView alloc] initWithFrame:CGRectMake(0, eventsView.frame.origin.y+eventsView.frame.size.height, Devicewidth , reminderHeight)];
    [self.view addSubview:remindersView];

    float messagesHeight  = remainingHeight * 0.35;
    messagesView = [[MessagesView alloc] initWithFrame:CGRectMake(0, remindersView.frame.origin.y+remindersView.frame.size.height, Devicewidth , messagesHeight)];
    messagesView.delegate = self;
    [self.view addSubview:messagesView];
    
}
- (void)messageTapped:(NSDictionary *)detailsDict{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    MessageDetailViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MessageDetailViewController"];
    vc.messageDictFromLastPage = [detailsDict mutableCopy];
    [self.navigationController pushViewController:vc animated:YES];

}
-(void)dateTapped {
    
    LSLDatePickerDialog *dialog = [[LSLDatePickerDialog alloc] init];
    [dialog showWithTitle:@"Demo" doneButtonTitle:@"Done" cancelButtonTitle:@"Cancel" defaultDate:[NSDate date] minimumDate:nil maximumDate:nil datePickerMode:UIDatePickerModeDate callback:^(NSDate * _Nullable date) {
        if(date)
        {
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd/MM/yyyy";
            selectedDate = [dateFormatter stringFromDate:date];
            dateFormatter.dateFormat = @"EEEE, MMMM dd";
            [dateButton setTitle:[dateFormatter stringFromDate:date] forState:UIControlStateNormal];
            [self callEventAPI];

        }
    }];

    
}
-(void)menuTapped {
    
    [sharedInstance getProfileDetails];
    [[SlideNavigationController sharedInstance] toggleLeftMenu];
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

#pragma mark -
#pragma mark API Methods
-(void)callEventAPI {
    
    [Spinner showIndicator:YES];
    
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    SingletonClass *singletonShared = [SingletonClass sharedInstance];
    
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    
    [bodyRequest setValue:[[singletonShared selecteRoom] objectForKey:@"session_id"]                 forKey:@"session_id"];
    [bodyRequest setValue:[[singletonShared selecteRoom] objectForKey:@"season_id"]                  forKey:@"season_id"];
    [bodyRequest setValue:selectedDate                  forKey:@"date"];
    
    NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
    [postData setValue:token.access_token               forKey:@"access_token"];
    [postData setValue:_userProfile.auth_token          forKey:@"auth_token"];
    [postData setValue:@"all_events"            forKey:@"command"];
    [postData setValue:bodyRequest                      forKey:@"body"];
    
    NSDictionary *userInfo = @{@"command":@"all_events"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@teachers",BASE_URL];
    
    __weak __typeof(self)weakSelf = self;
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
    
        [weakSelf reloadViews:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
    } failure:^(NSDictionary *json) {
        
        [weakSelf failedToLoad];
    }];
}
-(void)reloadViews:(NSDictionary *)details {
    
/*    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"events" ofType:@"json"];
    NSString *myJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[myJSON dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    details = [jsonDict objectForKey:@"body"];
*/
    [eventsView refreshData:[details objectForKey:@"events"]];
    [remindersView refreshData:[details objectForKey:@"reminders"]];
    [messagesView refreshData:[details objectForKey:@"messages"]];
    [Spinner showIndicator:NO];
}
-(void)failedToLoad {
    
    [Spinner showIndicator:NO];
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

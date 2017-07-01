//
//  SettingsViewController.m
//  TingrSCHOOL
//
//  Created by Maisa Pride on 4/7/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "SettingsViewController.h"
#import "TourViewController.h"
#import "ChangePasswordViewController.h"
#import "LoginViewController.h"
#import "MySchoolViewController.h"
@import Firebase;
@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize tableView;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back_arrow.png"]];
    [imageView setTintColor:[UIColor redColor]];
    
    int space=6;
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView.frame.size.width+space, imageView.frame.size.height)];
    
    view.bounds=CGRectMake(view.bounds.origin.x+12, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    
    UIButton *button=[[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(bakButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    
    UIBarButtonItem *backButton =[[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = backButton;
    
    
    CGRect frame = tableView.frame;
    frame.size = CGSizeMake(Devicewidth, Deviceheight);
    tableView.frame = frame;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:YES];
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 44;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 4)
    {
        
        NSString *reuseIdentifier = @"VersionCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:reuseIdentifier];
        }
            cell.userInteractionEnabled = NO;
            [cell setBackgroundColor:[UIColor clearColor]];
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);

            UILabel *version;
            version = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, Devicewidth, 15)];
            [version setText:@"v1.1.1"];
            [version setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
            [version setTextColor:[UIColor darkGrayColor]];
            [version setTextAlignment:NSTextAlignmentCenter];
            [cell.contentView addSubview:version];
            
            return cell;

        
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel *txtLabel = (UILabel *)[cell viewWithTag:1];
    
    txtLabel.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    
    
    UIImageView *arrowImage = (UIImageView *)[cell viewWithTag:2];
    CGRect frame = arrowImage.frame;
    frame.origin.x = Devicewidth - 10-frame.size.width;
    arrowImage.frame =  frame;
    
    switch (indexPath.row)
    {
        case 0:
        {
            txtLabel.text = @"Tingr Tour";
        }
            break;
        case 1:
        {
            txtLabel.text = @"My School";
        }
            break;
            
        case 2:
        {
            txtLabel.text = @"Change Password";
        }
            break;
            
        case 3:
        {
            txtLabel.text = @"Logout";
        }
            break;
            
    }
    
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView1 deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TourViewController *_onboardingWellnessLogoViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TourViewController"];
            _onboardingWellnessLogoViewController.isFromMoreTab = YES;
            [self.navigationController pushViewController:_onboardingWellnessLogoViewController animated:YES];

        }
            break;
        case 1:
        {
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MySchoolViewController *_onboardingWellnessLogoViewController = [storyBoard instantiateViewControllerWithIdentifier:@"MySchoolViewController"];
            [self.navigationController pushViewController:_onboardingWellnessLogoViewController animated:YES];
            
        }
            break;
        case 2:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChangePasswordViewController *_onboardingWellnessLogoViewController = [storyBoard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
            [self.navigationController pushViewController:_onboardingWellnessLogoViewController animated:YES];
            
        }
            break;
        case 3:
        {
            [self logout];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma Logout Methods

- (void)logout
{
    
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
        [Spinner showIndicator:YES];
        ModelManager *sharedModel = [ModelManager sharedModel];
        AccessToken* token = sharedModel.accessToken;
        UserProfile *_userProfile = sharedModel.userProfile;
        
        //build an info object and convert to json
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token": _userProfile.auth_token,
                                   @"command": @"revoke_authentication",
                                   @"body": @""};
        
        NSDictionary *userInfo = @{@"command":@"revoke_authentication"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};

        [Spinner showIndicator:YES];
        __weak __typeof(self)weakSelf = self;
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            
            if(weakSelf){
                
                [Spinner showIndicator:NO];
                
                
                token.access_token     = @"";
                _userProfile.auth_token  = @"";
                
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                //[prefs setObject:@"" forKey:@"isRemember"];
                [prefs setBool:YES forKey:@"isRemember"];
                [prefs synchronize];
                
                NSString *string = [NSString stringWithFormat:@"/topics/tingr_%@",[[[ModelManager sharedModel] userProfile] teacher_klid]];
                [[FIRMessaging messaging] unsubscribeFromTopic:string];
                
                
                [self popToLogin];

            }
            
        } failure:^(NSDictionary *json) {
            
            if(weakSelf){
                
                [Spinner showIndicator:NO];
                if([json objectForKey:@"message"])
                {
                    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:[json objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [errorAlert show];
                }
                
            }
            
        }];

        
    }
}

-(void)popToLogin
{
    NSMutableArray *viewControllers = [[[SlideNavigationController sharedInstance] viewControllers] mutableCopy];
    BOOL isAvailable = NO;
    for(id class in viewControllers)
    {
        if([class isKindOfClass:[LoginViewController class]])
        {
            isAvailable = YES;
            [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil];
            break;
        }
    }
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

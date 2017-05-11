//
//  ChangePasswordViewController.m
//  KidsLink
//
//  Created by Maisa Solutions Pvt Ltd on 03/05/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface ChangePasswordViewController ()

@property (nonatomic, strong) UITextField *currentPasswordField;
@property (nonatomic, strong) UITextField *setNewPasswordField;
@property (nonatomic, strong) UITextField *confirmNewPasswordField;


@end

@implementation ChangePasswordViewController

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
#pragma mark - View Controller Life Cycle
#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Change Password";
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    int spacingBetween = 8;
    
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    
    //label
    UILabel *currentPassword = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 20)];
    currentPassword.text = @"Current Password";
    currentPassword.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:14];
    [currentPassword setTextAlignment:NSTextAlignmentLeft];
    currentPassword.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [scrollView addSubview:currentPassword];
    
    self.currentPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(20, currentPassword.frame.origin.y + currentPassword.frame.size.height, Devicewidth-40, 40)];
    self.currentPasswordField.font = [UIFont systemFontOfSize:15];
    [self.currentPasswordField setBackgroundColor:[UIColor whiteColor]];
    self.currentPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.currentPasswordField.returnKeyType = UIReturnKeyDone;
    self.currentPasswordField.delegate = self;
    self.currentPasswordField.secureTextEntry = YES;

    [scrollView addSubview:self.currentPasswordField];
    self.currentPasswordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    
    //horizontal line
    UIImageView *hrImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    hrImage1.frame = CGRectMake(20,self.currentPasswordField.frame.origin.y + self.currentPasswordField.frame.size.height + spacingBetween,screenWidth - 40,1);
    [scrollView addSubview:hrImage1];
    
    UILabel *newPassword = [[UILabel alloc] initWithFrame: CGRectMake(20, hrImage1.frame.origin.y + spacingBetween, 200, 20)];
    newPassword.text = @"New Password";
    newPassword.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:14];
    [newPassword setTextAlignment:NSTextAlignmentLeft];
    newPassword.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [scrollView addSubview:newPassword];
    
    self.setNewPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(20, newPassword.frame.origin.y + newPassword.frame.size.height, Devicewidth-40, 40)];
    [self.setNewPasswordField setBackgroundColor:[UIColor whiteColor]];
    self.setNewPasswordField.font = [UIFont systemFontOfSize:15];
    self.setNewPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.setNewPasswordField.keyboardType = UIKeyboardTypeDefault;
    self.setNewPasswordField.returnKeyType = UIReturnKeyDone;
    self.setNewPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.setNewPasswordField.delegate = self;
    self.setNewPasswordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.setNewPasswordField.secureTextEntry = YES;
    [scrollView addSubview:self.setNewPasswordField];
    
    //horizontal line
    UIImageView *hrImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    hrImage2.frame = CGRectMake(20,self.setNewPasswordField.frame.origin.y + self.setNewPasswordField.frame.size.height + spacingBetween,screenWidth - 40,1);
    [scrollView addSubview:hrImage2];
    
    UILabel *confirmNewPassword = [[UILabel alloc] initWithFrame: CGRectMake(20, hrImage2.frame.origin.y + hrImage2.frame.size.height + spacingBetween, 200, 20)];
    confirmNewPassword.text = @"Confim New Password";
    confirmNewPassword.font =[UIFont fontWithName:@"HelveticaNeueLTStd-Lt" size:14];
    [confirmNewPassword setTextAlignment:NSTextAlignmentLeft];
    confirmNewPassword.textColor = [UIColor colorWithRed:(113/255.f) green:(113/255.f) blue:(113/255.f) alpha:1];
    [scrollView addSubview:confirmNewPassword];
    
    self.confirmNewPasswordField = [[UITextField alloc] initWithFrame:CGRectMake(20, confirmNewPassword.frame.origin.y +confirmNewPassword.frame.size.height, Devicewidth-40, 40)];
    [self.confirmNewPasswordField setBackgroundColor:[UIColor whiteColor]];
    self.confirmNewPasswordField.font = [UIFont systemFontOfSize:15];
    self.confirmNewPasswordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.confirmNewPasswordField.keyboardType = UIKeyboardTypeDefault;
    self.confirmNewPasswordField.returnKeyType = UIReturnKeyDone;
    self.confirmNewPasswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.confirmNewPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.confirmNewPasswordField.delegate = self;
    self.confirmNewPasswordField.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    self.confirmNewPasswordField.secureTextEntry = YES;
    [scrollView addSubview:self.confirmNewPasswordField];
    
    [self.view addSubview:scrollView];
    
    
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
    
    
    UIImageView *imageView1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
    [imageView1 setTintColor:[UIColor redColor]];
    
    
    UIView *view1=[[UIView alloc] initWithFrame:CGRectMake(0, 0,imageView1.frame.size.width+space, imageView1.frame.size.height)];
    
    view1.bounds=CGRectMake(view1.bounds.origin.x-10, view1.bounds.origin.y-1, view1.bounds.size.width, view1.bounds.size.height);
    [view1 addSubview:imageView1];
    
    UIButton *button1=[[UIButton alloc] initWithFrame:view1.frame];
    [button1 addTarget:self action:@selector(submitButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [view1 addSubview:button1];
    
    
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:view1];
    self.navigationItem.rightBarButtonItem = rightButton;

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.globalAlert = nil;
}
-(void)bakButtonTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- Actions
#pragma mark-
- (IBAction)submitButtonTapped:(id)sender
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
        self.globalAlert = alert;
        [alert show];
    }
    else
    {
        if (self.currentPasswordField.text.length >0 && self.setNewPasswordField.text.length >0 && self.confirmNewPasswordField.text.length >0)
        {
            if(![self.setNewPasswordField.text isEqualToString:self.confirmNewPasswordField.text])
            {
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:@"Password did not match" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                self.globalAlert = errorAlert;
                [errorAlert show];
                return;
            }
            
            [self.currentPasswordField resignFirstResponder];
            [self.confirmNewPasswordField resignFirstResponder];
            [self.setNewPasswordField resignFirstResponder];
            
            ModelManager *sharedModel = [ModelManager sharedModel];
            AccessToken* token = sharedModel.accessToken;
            UserProfile *_userProfile = sharedModel.userProfile;
            
            NSMutableDictionary *changePasswordDetails = [[NSMutableDictionary alloc]init];
            [changePasswordDetails setValue:self.currentPasswordField.text    forKey:@"current_password"];
            [changePasswordDetails setValue:self.setNewPasswordField.text        forKey:@"password"];
            [changePasswordDetails setValue:self.confirmNewPasswordField.text forKey:@"password_confirmation"];
            
            NSDictionary* postData = @{@"access_token": token.access_token,
                                       @"auth_token": _userProfile.auth_token,
                                       @"command": @"change_password",
                                       @"body": changePasswordDetails};
            
            NSDictionary *userInfo = @{@"command":@"change_password"};
            
            NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
            NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
            [Spinner showIndicator:YES];
            __weak __typeof(self)weakSelf = self;
            API *api = [[API alloc] init];
            [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
                
                if(weakSelf){
                    
                [Spinner showIndicator:NO];
                [self.navigationController popViewControllerAnimated:YES];
                    
                }
                
            } failure:^(NSDictionary *json) {
                
                if(weakSelf){
                    
                [Spinner showIndicator:NO];
                if([json objectForKey:@"message"])
                {
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:[json objectForKey:@"message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                self.globalAlert = errorAlert;
                [errorAlert show];
                }
                    
                }
                
            }];
            
            
        }
        else
        {
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"TingrSCHOOL" message:@"Please fill the fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            self.globalAlert = errorAlert;
            [errorAlert show];
        }
    }
    }
#pragma mark- ChangePasswordManagerDelegate Methods
#pragma mark-
- (void)didReceiveChangePassword:(NSArray *)changePassword
{
    DebugLog(@"%@",changePassword);
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)fetchingChangePasswordFailedWithError:(NSError *)error
{
    DebugLog(@"Error %@; %@", error, [error localizedDescription]);
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    self.globalAlert = errorAlert;
    [errorAlert show];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
